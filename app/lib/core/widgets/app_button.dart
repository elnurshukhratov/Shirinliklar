import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/l10n_extensions.dart';
import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_tokens.dart';
import 'glass/glass_container.dart';

enum AppButtonVariant { primary, secondary, text }

/// Asosiy harakat tugmasi.
/// - primary: tinted shisha (CTA rangi), secondary: oddiy shisha, text: yuzasiz.
/// - "Jelly" bosilish: eni ~1.04, bo'yi ~0.94, so'ng snappy prujinasi bilan qaytadi.
/// - [isLoading]: tugma doiraga qisqaradi, ichida spinner.
/// - [isSuccess]: doira ichida galochka chiziladi va atrofga 14 ta rangli kapsula ("sprinkles")
///   ~600 ms davomida sochiladi.
/// "Harakatni kamaytirish" yoqilganda jelly, qisqarish va sprinkles o'chadi (holat darhol almashadi).
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.isSuccess = false,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;

  /// Muvaffaqiyat holati: galochka + sprinkles. Bosish o'chiriladi.
  final bool isSuccess;
  final bool expanded;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> with TickerProviderStateMixin {
  static const double _minHeight = 54;
  static const Duration _sprinkleDuration = Duration(milliseconds: 600);

  bool _pressed = false;
  double? _restWidth; // o'lchangan tabiiy kenglik (faqat expanded: false bo'lganda kerak)
  final GlobalKey _restKey = GlobalKey();

  // Galochka chizilishi (prujina, 0..1) va sprinkles (600 ms, 0..1).
  late final AnimationController _check = AnimationController.unbounded(vsync: this, value: 0);
  late final AnimationController _sprinkles = AnimationController(vsync: this, duration: _sprinkleDuration);

  bool get _morphed => widget.isLoading || widget.isSuccess;

  @override
  void initState() {
    super.initState();
    if (widget.isSuccess) _check.value = 1;
  }

  @override
  void didUpdateWidget(AppButton old) {
    super.didUpdateWidget(old);
    if (old.label != widget.label || old.icon != widget.icon) _restWidth = null;
    if (widget.isSuccess && !old.isSuccess) {
      if (AppMotion.reduced(context)) {
        _check.value = 1;
      } else {
        _check.value = 0;
        _check.springTo(1, description: AppMotion.snappy);
        _sprinkles.forward(from: 0);
        HapticFeedback.mediumImpact();
      }
    } else if (!widget.isSuccess && old.isSuccess) {
      _check.value = 0;
      _sprinkles.value = 0;
    }
  }

  @override
  void dispose() {
    _check.dispose();
    _sprinkles.dispose();
    super.dispose();
  }

  void _measure() {
    if (!mounted || _morphed || widget.expanded) return;
    final box = _restKey.currentContext?.findRenderObject();
    if (box is RenderBox && box.hasSize && box.size.width != _restWidth) {
      setState(() => _restWidth = box.size.width);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final variant = widget.variant;
    final enabled = widget.onPressed != null && !_morphed;
    final reduced = AppMotion.reduced(context);

    final Color fg;
    switch (variant) {
      case AppButtonVariant.primary:
        fg = c.onCta;
      case AppButtonVariant.secondary:
        fg = c.textPrimary;
      case AppButtonVariant.text:
        fg = c.primary;
    }
    final checkColor = variant == AppButtonVariant.primary ? c.onCta : c.success;

    // Matn kattalashsa tugma ham o'sadi (kesilmaydi); doira shu balandlikda.
    final height = math.max(_minHeight, MediaQuery.textScalerOf(context).scale(15) * 1.25 + 28);

    final label = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, size: 20, color: fg),
          const SizedBox(width: AppSpacing.sm),
        ],
        Flexible(
          child: Text(
            widget.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: fg,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
          ),
        ),
      ],
    );

    final radius = AppRadius.borderPill;

    Widget surfaceFor(Widget child) {
      switch (variant) {
        case AppButtonVariant.primary:
          return GlassContainer(
            level: GlassLevel.chip,
            tint: c.cta,
            blur: false,
            strong: _pressed,
            shadow: widget.onPressed != null,
            borderRadius: radius,
            child: child,
          );
        case AppButtonVariant.secondary:
          return GlassContainer(
            level: GlassLevel.chip,
            blur: false,
            shadow: false,
            strong: _pressed,
            borderRadius: radius,
            child: child,
          );
        case AppButtonVariant.text:
          return child;
      }
    }

    // Bosiladigan qatlam: shisha sirt bilan bir xil shaklda (kenglik qisqarganda ham).
    Widget tapLayer() => Positioned.fill(
          child: Material(
            color: Colors.transparent,
            borderRadius: radius,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: enabled
                  ? () {
                      HapticFeedback.lightImpact();
                      widget.onPressed!();
                    }
                  : null,
              onHighlightChanged: enabled
                  ? (v) {
                      if (_pressed != v && mounted) setState(() => _pressed = v);
                    }
                  : null,
              splashColor: Colors.white.withValues(alpha: 0.18),
              highlightColor: Colors.white.withValues(alpha: 0.06),
            ),
          ),
        );

    // Tabiiy kenglik hali noma'lum (birinchi kadr, expanded: false): oddiy ko'rinish chiziladi
    // va o'lchanadi; keyingi kadrdan boshlab kenglik prujina bilan boshqariladi.
    Widget morphing(double restWidth) {
      return SpringBuilder(
        value: _morphed ? 1 : 0,
        description: AppMotion.smooth,
        builder: (context, m, _) {
          final t = m.clamp(0.0, 1.0);
          final width = math.max(height, restWidth + (height - restWidth) * m);
          final labelOpacity = (1 - t * 2.5).clamp(0.0, 1.0);
          final stateOpacity = ((t - 0.45) * 2).clamp(0.0, 1.0);

          return surfaceFor(
            SizedBox(
              width: width,
              height: height,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Yozuv: kenglik qisqarganda o'ralib/kesilib qolmasin deb OverflowBox ichida.
                  Opacity(
                    opacity: labelOpacity,
                    child: OverflowBox(
                      minWidth: 0,
                      maxWidth: restWidth,
                      minHeight: height,
                      maxHeight: height,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                        child: Center(widthFactor: 1, child: label),
                      ),
                    ),
                  ),
                  if (widget.isLoading)
                    Opacity(
                      opacity: stateOpacity,
                      child: Semantics(
                        label: l10n.commonLoading,
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.4, color: fg),
                        ),
                      ),
                    ),
                  if (widget.isSuccess)
                    Opacity(
                      opacity: stateOpacity,
                      child: AnimatedBuilder(
                        animation: _check,
                        builder: (context, _) => CustomPaint(
                          size: const Size(26, 26),
                          painter: _CheckPainter(progress: _check.value, color: checkColor),
                        ),
                      ),
                    ),
                  tapLayer(),
                ],
              ),
            ),
          );
        },
      );
    }

    Widget visual;
    if (widget.expanded) {
      visual = LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth.isFinite ? constraints.maxWidth : 240.0;
          return Center(child: morphing(w));
        },
      );
    } else {
      final rest = _restWidth;
      if (rest == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
        visual = KeyedSubtree(
          key: _restKey,
          child: surfaceFor(
            ConstrainedBox(
              constraints: BoxConstraints(minHeight: height),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 14),
                    child: Center(widthFactor: 1, child: label),
                  ),
                  tapLayer(),
                ],
              ),
            ),
          ),
        );
      } else {
        visual = morphing(rest);
      }
    }

    // Jelly: eni ~1.04, bo'yi ~0.94; snappy prujinasi qaytishda sal sakratadi.
    final jelly = SpringBuilder(
      value: _pressed && enabled && !reduced ? 1 : 0,
      description: AppMotion.snappy,
      child: visual,
      builder: (context, v, child) => Transform(
        alignment: Alignment.center,
        transform: Matrix4.diagonal3Values(1 + 0.04 * v, 1 - 0.06 * v, 1),
        child: child,
      ),
    );

    final stack = Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        jelly,
        if (widget.isSuccess && !reduced)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _sprinkles,
                builder: (context, _) => CustomPaint(
                  painter: _SprinklesPainter(
                    progress: _sprinkles.value,
                    colors: [c.cta, c.accent, c.mint, c.ambientA, c.ambientB, c.ambientC],
                    innerRadius: height / 2,
                  ),
                ),
              ),
            ),
          ),
      ],
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.isSuccess ? l10n.commonDone : widget.label,
      excludeSemantics: true,
      child: AnimatedOpacity(
        duration: AppMotion.of(context, AppMotion.fast),
        opacity: widget.onPressed == null && !_morphed ? 0.5 : 1,
        child: widget.expanded ? SizedBox(width: double.infinity, child: stack) : stack,
      ),
    );
  }
}

/// Galochka: [progress] 0..1 (prujinadan; 1 dan oshsa kesiladi) bo'yicha chiziladi.
class _CheckPainter extends CustomPainter {
  _CheckPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = progress.clamp(0.0, 1.0);
    if (p <= 0) return;
    final path = Path()
      ..moveTo(size.width * 0.14, size.height * 0.54)
      ..lineTo(size.width * 0.40, size.height * 0.78)
      ..lineTo(size.width * 0.86, size.height * 0.26);
    final metric = path.computeMetrics().first;
    canvas.drawPath(
      metric.extractPath(0, metric.length * p),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_CheckPainter old) => old.progress != progress || old.color != color;
}

/// Sprinkles: 14 ta rangli kapsula doiradan atrofga sochiladi, aylanib, ~600 ms ichida so'nadi.
/// Joylashuv va ranglar deterministik (har safar bir xil naqsh), shuning uchun tasodifiy emas.
class _SprinklesPainter extends CustomPainter {
  _SprinklesPainter({required this.progress, required this.colors, required this.innerRadius});

  static const int _count = 14;

  final double progress;
  final List<Color> colors;
  final double innerRadius;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    final center = size.center(Offset.zero);
    final travel = AppMotion.smoothCurve.transform(progress);
    // Dastlabki 55% da to'liq ko'rinadi, keyin so'nadi.
    final fade = progress < 0.55 ? 1.0 : (1 - (progress - 0.55) / 0.45).clamp(0.0, 1.0);

    for (var i = 0; i < _count; i++) {
      // Burchak: teng taqsimot + kichik deterministik og'ish.
      final jitter = math.sin(i * 12.9898) * 0.16;
      final angle = (i / _count) * math.pi * 2 + jitter;
      final reach = 20 + (i % 3) * 7.0; // 20 / 27 / 34 px
      final dist = innerRadius + 4 + reach * travel;
      final len = 9.0 - (i % 2) * 2.5;
      final thick = 4.0;
      final pos = center + Offset(math.cos(angle), math.sin(angle)) * dist;

      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      // Kapsula yo'nalishi: markazdan tashqariga, harakat bilan biroz buriladi.
      canvas.rotate(angle + (i.isEven ? 1 : -1) * travel * 0.9);
      final scale = 1 - 0.35 * progress;
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: len * scale, height: thick * scale),
        Radius.circular(thick),
      );
      canvas.drawRRect(
        rect,
        Paint()..color = colors[i % colors.length].withValues(alpha: fade),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_SprinklesPainter old) =>
      old.progress != progress || old.colors != colors || old.innerRadius != innerRadius;
}