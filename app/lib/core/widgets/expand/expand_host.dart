import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import 'expand_backdrop.dart';
import 'expand_origin.dart';
import 'expand_scope.dart';

/// Kengayuvchi sahifaning ichki qismi.
///
/// - Kontent HAR DOIM to'liq ekran o'lchamida quriladi; kadrlar bo'yicha faqat clip (to'rtburchak
///   va burchak radiusi: r0 -> 44 -> 0) va transform o'zgaradi, layout qayta hisoblanmaydi.
/// - Umumiy rasm ([ExpandOrigin.image]) karta joyidan [sharedTarget] ga o'sib boradi.
/// - Kontent [ExpandReveal] orqali 25–100% oralig'ida ketma-ket paydo bo'ladi.
/// - Kontent tepada bo'lganda pastga tortib yopiladi (ichidagi skroll `ClampingScrollPhysics` bo'lishi kerak).
/// - Android orqaga tugmasi / predictive back: [PopScope] orqali yig'ilish animatsiyasi.
class ExpandHost extends StatefulWidget {
  const ExpandHost({
    super.key,
    required this.controller,
    required this.child,
    this.origin,
    this.sharedTarget,
  });

  final AnimationController controller;
  final Widget child;
  final ExpandOrigin? origin;
  final Rect Function(Size screen)? sharedTarget;

  @override
  State<ExpandHost> createState() => _ExpandHostState();
}

class _ExpandHostState extends State<ExpandHost> {
  static final SpringDescription _closeSpring =
      SpringDescription.withDampingRatio(mass: 1, stiffness: 320, ratio: 1);

  /// Drag masofasi ekran balandligining shu ulushiga yetganda progress = 1.
  static const double _dragSpan = 0.5;

  /// Progress 1 bo'lganda sahifa ochilish qiymatining qancha qismigacha yig'iladi.
  static const double _dragDepth = 0.7;

  final ValueNotifier<double> _p = ValueNotifier<double>(0);
  final ValueNotifier<bool> _interactive = ValueNotifier<bool>(false);

  Size _size = Size.zero;
  bool _reduced = false;

  bool _selfDriven = false;
  bool _opened = false;
  bool _closing = false;
  bool _finished = false;
  double _dragPx = 0;
  Rect? _closeRect;
  bool _fadeDown = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_sync);
    _p.value = _compute();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_sync);
    WidgetsBinding.instance.addPostFrameCallback((_) => clearExpandBackdrop(this));
    _p.dispose();
    _interactive.dispose();
    super.dispose();
  }

  /// Ko'rinadigan progress: ochilishda prujina egri chizig'i, o'zimiz boshqarganda (drag, yig'ilish) — to'g'ridan-to'g'ri.
  double _compute() {
    final c = widget.controller;
    final t = c.value.clamp(0.0, 1.0).toDouble();
    if (_selfDriven) return t;
    if (c.status == AnimationStatus.forward) {
      return AppMotion.smoothCurve.transform(t).clamp(0.0, 1.0).toDouble();
    }
    return t;
  }

  void _sync() {
    final p = _compute();
    _p.value = p;
    if (p >= 0.9) _opened = true;
    _interactive.value = _opened && !_closing;
    if (!_reduced) setExpandBackdrop(this, p);
    if (_closing && !_finished && widget.controller.value <= 0.002) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _finish());
    }
  }

  // ---- Pastga tortib yopish ------------------------------------------------------------------

  bool _onScroll(ScrollNotification n) {
    if (n.depth != 0 || n.metrics.axis != Axis.vertical) return false;
    if (!_opened || _closing || _finished || _reduced) return false;

    if (n is OverscrollNotification) {
      if (n.overscroll < 0 && n.dragDetails != null) _dragBy(-n.overscroll);
    } else if (n is ScrollUpdateNotification) {
      final delta = n.scrollDelta ?? 0;
      if (_dragPx > 0 && delta > 0) _dragBy(-delta);
    } else if (n is ScrollEndNotification) {
      if (_dragPx > 0) _release(n.dragDetails?.primaryVelocity ?? 0);
    }
    return false;
  }

  void _dragBy(double dy) {
    if (_dragPx <= 0) {
      if (dy <= 0) return;
      _selfDriven = true;
    }
    final limit = _size.height * _dragSpan * 1.5;
    _dragPx = (_dragPx + dy).clamp(0.0, limit).toDouble();
    final prog = (_dragPx / (_size.height * _dragSpan)).clamp(0.0, 1.0).toDouble();
    widget.controller.value = 1 - _dragDepth * prog;
    if (_dragPx <= 0) _selfDriven = false;
  }

  void _release(double velocityY) {
    final prog = (_dragPx / (_size.height * _dragSpan)).clamp(0.0, 1.0).toDouble();
    _dragPx = 0;
    if (velocityY > 700 || prog > 0.25) {
      _collapse(velocityY: velocityY);
    } else {
      _springBack(velocityY);
    }
  }

  double _controllerVelocity(double velocityY) =>
      -(velocityY / (_size.height * _dragSpan)) * _dragDepth;

  Future<void> _springBack(double velocityY) async {
    final v = _controllerVelocity(velocityY).clamp(-6.0, 6.0).toDouble();
    _selfDriven = true;
    await widget.controller.animateWith(
      AppMotion.spring(from: widget.controller.value, to: 1, velocity: v),
    );
    if (!mounted || _closing) return;
    _selfDriven = false;
    _sync();
  }

  /// Karta joyiga qaytib yig'iladi. Manba joyi qayta o'lchanadi; karta ekrandan chiqib ketgan
  /// bo'lsa (yoki manba yo'q) — pastga fade-down.
  Future<void> _collapse({double velocityY = 0}) async {
    if (_closing || _finished) return;
    _closing = true;
    _interactive.value = false;

    final origin = _reduced ? null : widget.origin;
    final measured = origin?.measureNow(_size);
    final visible = measured != null && measured.overlaps(Offset.zero & _size);
    _closeRect = visible ? measured : null;
    _fadeDown = !visible;
    _selfDriven = true;

    final v = _controllerVelocity(velocityY).clamp(-6.0, 0.0).toDouble();
    await widget.controller.animateWith(
      AppMotion.spring(desc: _closeSpring, from: widget.controller.value, to: 0, velocity: v),
    );
    _finish();
  }

  void _requestClose() {
    if (_closing || _finished) return;
    if (_reduced) {
      _closing = true;
      _finish();
      return;
    }
    _collapse();
  }

  void _finish() {
    if (_finished || !mounted) return;
    _finished = true;
    Navigator.of(context).pop();
  }

  // ---- Chizish -------------------------------------------------------------------------------

  double _radiusAt(double g, double r0) {
    const peak = 44.0;
    if (g < 0.4) return lerpDouble(r0, peak, Curves.easeOut.transform(g / 0.4))!;
    return lerpDouble(peak, 0, Curves.easeInOut.transform((g - 0.4) / 0.6))!;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final bg = context.colors.background;
    final reduced = AppMotion.reduced(context);
    _size = size;
    _reduced = reduced;

    final origin = reduced ? null : widget.origin;
    final screen = Offset.zero & size;
    final target = origin == null ? null : widget.sharedTarget?.call(size);

    final scoped = ExpandScope(
      progress: _p,
      hasOrigin: origin != null,
      origin: origin,
      child: NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: RepaintBoundary(
          child: ValueListenableBuilder<bool>(
            valueListenable: _interactive,
            child: widget.child,
            builder: (context, on, child) => IgnorePointer(ignoring: !on, child: child),
          ),
        ),
      ),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _requestClose();
      },
      child: AnimatedBuilder(
        animation: _p,
        child: scoped,
        builder: (context, child) {
          final g = _p.value;
          final start = _closeRect ?? origin?.rect ?? screen;
          final useOrigin = origin != null && !_fadeDown;

          final Rect window;
          final double radius;
          final double alpha;
          Color surface = bg;
          if (useOrigin) {
            window = Rect.lerp(start, screen, g)!;
            radius = _radiusAt(g, origin!.radius);
            alpha = 1;
            surface = Color.lerp(origin.surfaceColor ?? bg, bg, (g * 3).clamp(0.0, 1.0).toDouble())!;
          } else {
            window = reduced ? screen : screen.shift(Offset(0, (1 - g) * size.height * 0.07));
            radius = reduced ? 0 : 44 * (1 - g);
            alpha = Curves.easeOut.transform(g);
          }

          Widget? shared;
          final image = origin?.image;
          if (useOrigin && image != null && target != null && g < 0.99) {
            shared = Positioned.fromRect(
              rect: Rect.lerp(start, target, g)!,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: Image(image: image, fit: BoxFit.cover, gaplessPlayback: true),
              ),
            );
          }

          return Opacity(
            opacity: alpha.clamp(0.0, 1.0).toDouble(),
            child: ClipRRect(
              clipper: _WindowClipper(window, radius),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(color: surface),
                  Transform.scale(scale: useOrigin ? 0.94 + 0.06 * g : 1.0, child: child),
                  if (shared != null) shared,
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WindowClipper extends CustomClipper<RRect> {
  _WindowClipper(this.rect, this.radius);

  final Rect rect;
  final double radius;

  @override
  RRect getClip(Size size) => RRect.fromRectAndRadius(rect, Radius.circular(radius));

  @override
  bool shouldReclip(_WindowClipper old) => old.rect != rect || old.radius != radius;
}