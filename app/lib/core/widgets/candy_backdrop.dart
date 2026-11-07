import 'dart:math' as math;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart' show SpringDescription;

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';

enum _CandyKind { macaron, lollipop, donut }

class _Candy {
  const _Candy(this.x, this.y, this.size, this.rotation, this.depth, this.kind, this.tone, this.phase);

  /// Ekran bo'yicha nisbiy joy (0..1).
  final double x;
  final double y;

  /// Eng qisqa tomonga nisbatan radius.
  final double size;
  final double rotation;

  /// Parallax chuqurligi: kattasi yaqinroq (ko'proq siljiydi, to'qroq).
  final double depth;
  final _CandyKind kind;
  final int tone;
  final double phase;
}

const List<_Candy> _candies = [
  _Candy(0.14, 0.09, 0.17, -0.5, 1.0, _CandyKind.lollipop, 0, 0.0),
  _Candy(0.84, 0.07, 0.15, 0.6, 0.55, _CandyKind.donut, 1, 1.3),
  _Candy(0.62, 0.20, 0.10, 0.3, 0.35, _CandyKind.macaron, 2, 2.6),
  _Candy(0.06, 0.30, 0.12, 0.8, 0.7, _CandyKind.macaron, 3, 3.9),
  _Candy(0.92, 0.36, 0.18, -0.7, 1.1, _CandyKind.lollipop, 4, 5.1),
  _Candy(0.32, 0.17, 0.09, 0.4, 0.3, _CandyKind.donut, 5, 0.7),
  // Pastdagilar shisha varaq ortida: shisha ularni sindirib ko'rsatadi.
  _Candy(0.20, 0.62, 0.16, 0.5, 0.9, _CandyKind.donut, 2, 1.9),
  _Candy(0.80, 0.70, 0.19, -0.4, 1.2, _CandyKind.macaron, 0, 3.3),
  _Candy(0.50, 0.86, 0.14, 0.9, 0.8, _CandyKind.lollipop, 3, 4.4),
  _Candy(0.10, 0.90, 0.12, -0.8, 0.6, _CandyKind.macaron, 1, 5.8),
];

/// Sekin suzuvchi shirinliklar (makaron, lolipop, donut) — CustomPainter bilan chizilgan.
/// Hamma narsa bitta painter'da; ranglar tokenlardan. [parallax] (-1..1) qiymatiga qarab
/// har bir shirinlik o'z chuqurligiga mos siljiydi. "Harakatni kamaytirish" yoqilganda qotib turadi.
class CandyBackdrop extends StatefulWidget {
  const CandyBackdrop({super.key, this.parallax = Offset.zero, this.calm = false});

  final Offset parallax;

  /// Splash kabi joylarda: biroz xiraroq va kichikroq.
  final bool calm;

  @override
  State<CandyBackdrop> createState() => _CandyBackdropState();
}

class _CandyBackdropState extends State<CandyBackdrop> with TickerProviderStateMixin {
  static const SpringDescription _floaty = SpringDescription(mass: 1.4, stiffness: 70, damping: 16);

  late final AnimationController _drift =
      AnimationController(vsync: this, duration: const Duration(seconds: 40));
  late final AnimationController _px = AnimationController.unbounded(vsync: this, value: widget.parallax.dx);
  late final AnimationController _py = AnimationController.unbounded(vsync: this, value: widget.parallax.dy);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduced(context)) {
      _drift.stop();
    } else if (!_drift.isAnimating) {
      _drift.repeat();
    }
  }

  @override
  void didUpdateWidget(CandyBackdrop old) {
    super.didUpdateWidget(old);
    if (old.parallax == widget.parallax) return;
    if (AppMotion.reduced(context)) {
      _px.value = widget.parallax.dx;
      _py.value = widget.parallax.dy;
    } else {
      _px.springTo(widget.parallax.dx, description: _floaty);
      _py.springTo(widget.parallax.dy, description: _floaty);
    }
  }

  @override
  void dispose() {
    _drift.dispose();
    _px.dispose();
    _py.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final palette = <Color>[c.cta, c.ambientB, c.mint, c.accent, c.ambientA, c.ambientC];

    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _CandyPainter(
            drift: _drift,
            px: _px,
            py: _py,
            palette: palette,
            dough: Color.lerp(c.accent, c.textPrimary, 0.12)!,
            sprinkle: c.mint,
            dark: dark,
            calm: widget.calm,
          ),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _CandyPainter extends CustomPainter {
  _CandyPainter({
    required this.drift,
    required this.px,
    required this.py,
    required this.palette,
    required this.dough,
    required this.sprinkle,
    required this.dark,
    required this.calm,
  }) : super(repaint: Listenable.merge([drift, px, py]));

  final Animation<double> drift;
  final Animation<double> px;
  final Animation<double> py;
  final List<Color> palette;
  final Color dough;
  final Color sprinkle;
  final bool dark;
  final bool calm;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final t = drift.value * 2 * math.pi;
    final shortest = size.shortestSide;

    for (final s in _candies) {
      final z = s.depth;
      // Sikl butun sonli garmonikalardan: 40 soniyada uzilishsiz takrorlanadi.
      final cx = size.width * (s.x + 0.014 * math.sin(t + s.phase)) + px.value * size.width * 0.07 * z;
      final cy = size.height * (s.y + 0.012 * math.cos(2 * t + s.phase)) + py.value * size.height * 0.06 * z;
      final r = shortest * s.size * (calm ? 0.9 : 1.0);
      final alpha =
          ((0.50 + 0.40 * (z / 1.2)) * (dark ? 0.9 : 1.0) * (calm ? 0.8 : 1.0)).clamp(0.0, 1.0).toDouble();
      final tone = palette[s.tone % palette.length];

      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(s.rotation + 0.14 * math.sin(t + s.phase * 1.7));
      switch (s.kind) {
        case _CandyKind.macaron:
          _macaron(canvas, r, tone, alpha);
        case _CandyKind.lollipop:
          _lollipop(canvas, r, tone, alpha);
        case _CandyKind.donut:
          _donut(canvas, r, tone, alpha);
      }
      canvas.restore();
    }
  }

  void _macaron(Canvas canvas, double r, Color tone, double alpha) {
    final w = r * 2.0;
    final shellH = r * 0.62;
    final gap = r * 0.42;
    final big = Radius.circular(shellH * 0.95);
    final small = Radius.circular(shellH * 0.25);

    final top = RRect.fromLTRBAndCorners(
      -w / 2, -gap / 2 - shellH, w / 2, -gap / 2,
      topLeft: big, topRight: big, bottomLeft: small, bottomRight: small,
    );
    final bottom = RRect.fromLTRBAndCorners(
      -w / 2, gap / 2, w / 2, gap / 2 + shellH,
      topLeft: small, topRight: small, bottomLeft: big, bottomRight: big,
    );
    final cream = RRect.fromLTRBR(-w * 0.45, -gap / 2 - 1, w * 0.45, gap / 2 + 1, Radius.circular(gap * 0.4));

    Paint shell(RRect rr) => Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.lerp(tone, Colors.white, 0.35)!.withValues(alpha: alpha),
          tone.withValues(alpha: alpha),
        ],
      ).createShader(rr.outerRect);

    canvas.drawRRect(cream, Paint()..color = Color.lerp(tone, Colors.white, 0.85)!.withValues(alpha: alpha));
    canvas.drawRRect(top, shell(top));
    canvas.drawRRect(bottom, shell(bottom));

    canvas.drawArc(
      Rect.fromLTWH(-w * 0.34, -gap / 2 - shellH * 0.92, w * 0.34, shellH * 0.7),
      3.4,
      1.2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = r * 0.06
        ..color = Colors.white.withValues(alpha: alpha * 0.55),
    );
  }

  void _lollipop(Canvas canvas, double r, Color tone, double alpha) {
    final stick = RRect.fromLTRBR(-r * 0.09, r * 0.7, r * 0.09, r * 2.4, Radius.circular(r * 0.09));
    canvas.drawRRect(stick, Paint()..color = Colors.white.withValues(alpha: alpha * 0.85));

    final head = Rect.fromCircle(center: Offset.zero, radius: r);
    canvas.drawCircle(
      Offset.zero,
      r,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.35),
          colors: [
            Color.lerp(tone, Colors.white, 0.4)!.withValues(alpha: alpha),
            tone.withValues(alpha: alpha),
          ],
        ).createShader(head),
    );

    // Spiral.
    final spiral = Path();
    const turns = 3.0;
    const steps = 90;
    for (var i = 0; i <= steps; i++) {
      final f = i / steps;
      final angle = f * turns * 2 * math.pi;
      final radius = r * 0.88 * f;
      final p = Offset(math.cos(angle) * radius, math.sin(angle) * radius);
      if (i == 0) {
        spiral.moveTo(p.dx, p.dy);
      } else {
        spiral.lineTo(p.dx, p.dy);
      }
    }
    canvas.drawPath(
      spiral,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = r * 0.16
        ..color = Colors.white.withValues(alpha: alpha * 0.8),
    );

    canvas.drawArc(
      Rect.fromCircle(center: Offset.zero, radius: r * 0.78),
      3.5,
      0.9,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = r * 0.07
        ..color = Colors.white.withValues(alpha: alpha * 0.55),
    );
  }

  void _donut(Canvas canvas, double r, Color glaze, double alpha) {
    final outer = Path()..addOval(Rect.fromCircle(center: Offset.zero, radius: r));
    final hole = Path()..addOval(Rect.fromCircle(center: Offset.zero, radius: r * 0.36));
    canvas.drawPath(
      Path.combine(PathOperation.difference, outer, hole),
      Paint()..color = dough.withValues(alpha: alpha),
    );

    final glazeOuter = Path()..addOval(Rect.fromCircle(center: Offset(0, -r * 0.04), radius: r * 0.9));
    final glazeHole = Path()..addOval(Rect.fromCircle(center: Offset.zero, radius: r * 0.43));
    canvas.drawPath(
      Path.combine(PathOperation.difference, glazeOuter, glazeHole),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(glaze, Colors.white, 0.3)!.withValues(alpha: alpha),
            glaze.withValues(alpha: alpha),
          ],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: r)),
    );

    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = r * 0.085;
    for (var i = 0; i < 9; i++) {
      final angle = i * 2 * math.pi / 9 + 0.3;
      final radius = r * (0.62 + 0.06 * (i % 3));
      final o = Offset(math.cos(angle) * radius, math.sin(angle) * radius);
      final dir = angle + i;
      paint.color = (i.isEven ? Colors.white : sprinkle).withValues(alpha: alpha);
      canvas.drawLine(o, o + Offset(math.cos(dir), math.sin(dir)) * r * 0.11, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CandyPainter old) =>
      old.dark != dark ||
      old.calm != calm ||
      old.dough != dough ||
      old.sprinkle != sprinkle ||
      !listEquals(old.palette, palette);
}