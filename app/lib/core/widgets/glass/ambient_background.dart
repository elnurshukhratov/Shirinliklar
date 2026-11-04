import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';

/// Ilovaning yagona jonli foni. Faqat BITTA joyda (app.dart builder) turadi, sahifalar shaffof.
/// 4 ta yumshoq nur dog'i 20–30 soniyalik siklda juda sekin siljiydi (RepaintBoundary ichida),
/// ustida ~3% grain (bir marta chiziladi). Ranglar kun/tunda tokenlardan.
/// "Harakatni kamaytirish" yoqilganda nurlar qimirlamaydi.
class AmbientBackground extends StatefulWidget {
  const AmbientBackground({super.key, required this.child});

  final Widget child;

  @override
  State<AmbientBackground> createState() => _AmbientBackgroundState();
}

class _AmbientBackgroundState extends State<AmbientBackground> with SingleTickerProviderStateMixin {
  // Sikl: 26 s (20–30 s oralig'ida).
  late final AnimationController _drift = AnimationController(vsync: this, duration: const Duration(seconds: 26));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced = AppMotion.reduced(context);
    if (reduced) {
      _drift.stop();
    } else if (!_drift.isAnimating) {
      _drift.repeat();
    }
  }

  @override
  void dispose() {
    _drift.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Nurlar alohida qatlamda: faqat shu qatlam qayta chiziladi, sahifalar emas.
        RepaintBoundary(
          child: CustomPaint(
            painter: _OrbsPainter(
              progress: _drift,
              background: c.background,
              a: c.ambientA,
              b: c.ambientB,
              cc: c.ambientC,
              d: Color.lerp(c.ambientA, c.ambientC, 0.5)!,
              dark: dark,
            ),
            child: const SizedBox.expand(),
          ),
        ),
        // Grain: statik, bir marta chiziladi.
        const IgnorePointer(child: RepaintBoundary(child: _Grain())),
        widget.child,
      ],
    );
  }
}

class _OrbsPainter extends CustomPainter {
  _OrbsPainter({
    required this.progress,
    required this.background,
    required this.a,
    required this.b,
    required this.cc,
    required this.d,
    required this.dark,
  }) : super(repaint: progress);

  final Animation<double> progress;
  final Color background;
  final Color a;
  final Color b;
  final Color cc;
  final Color d;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = background);
    final t = progress.value * 2 * math.pi;
    final shortest = size.shortestSide;

    // (bazaviy nuqta, siljish amplitudasi, faza, radius, rang, shaffoflik)
    void orb(Offset base, Offset amp, double phase, double radius, Color color, double alpha) {
      final center = Offset(
        size.width * (base.dx + amp.dx * math.sin(t + phase)),
        size.height * (base.dy + amp.dy * math.cos(t + phase * 1.3)),
      );
      final r = shortest * radius;
      final paint = Paint()
        ..shader = ui.Gradient.radial(
          center,
          r,
          [color.withValues(alpha: alpha), color.withValues(alpha: 0)],
        );
      canvas.drawCircle(center, r, paint);
    }

    final k = dark ? 0.55 : 0.50;
    orb(const Offset(0.05, 0.05), const Offset(0.10, 0.06), 0.0, 1.00, a, k);
    orb(const Offset(0.98, 0.82), const Offset(0.08, 0.07), 2.1, 0.95, b, k * 0.9);
    orb(const Offset(0.90, 0.22), const Offset(0.09, 0.08), 4.2, 0.65, cc, k * (dark ? 0.55 : 0.60));
    orb(const Offset(0.12, 0.88), const Offset(0.10, 0.06), 5.3, 0.60, d, k * 0.45);
  }

  @override
  bool shouldRepaint(_OrbsPainter old) =>
      old.background != background || old.a != a || old.b != b || old.cc != cc || old.d != d || old.dark != dark;
}

/// ~3% shaffoflikdagi shovqin: kichik plitka bir marta yaratiladi va ImageShader bilan yopiladi.
class _Grain extends StatefulWidget {
  const _Grain();

  @override
  State<_Grain> createState() => _GrainState();
}

class _GrainState extends State<_Grain> {
  static ui.Image? _tile; // butun ilova bo'yicha bitta
  static Future<ui.Image>? _loading;

  @override
  void initState() {
    super.initState();
    if (_tile == null) {
      _loading ??= _build();
      _loading!.then((img) {
        _tile = img;
        if (mounted) setState(() {});
      });
    }
  }

  static Future<ui.Image> _build() async {
    const side = 96;
    final rnd = math.Random(7);
    final bytes = Uint8List(side * side * 4);
    for (var i = 0; i < side * side; i++) {
      final v = rnd.nextBool() ? 255 : 0;
      bytes[i * 4] = v;
      bytes[i * 4 + 1] = v;
      bytes[i * 4 + 2] = v;
      bytes[i * 4 + 3] = 8; // 8/255 ≈ 3%
    }
    final codec = await ui.ImageDescriptor.raw(
      await ui.ImmutableBuffer.fromUint8List(bytes),
      width: side,
      height: side,
      pixelFormat: ui.PixelFormat.rgba8888,
    ).instantiateCodec();
    return (await codec.getNextFrame()).image;
  }

  @override
  Widget build(BuildContext context) {
    final tile = _tile;
    if (tile == null) return const SizedBox.expand();
    return CustomPaint(painter: _GrainPainter(tile), child: const SizedBox.expand());
  }
}

class _GrainPainter extends CustomPainter {
  _GrainPainter(this.tile);

  final ui.Image tile;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = ImageShader(tile, TileMode.repeated, TileMode.repeated, Matrix4.identity().storage);
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(_GrainPainter old) => old.tile != tile;
}
