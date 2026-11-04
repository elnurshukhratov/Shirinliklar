import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'glass/glass_container.dart';

/// Brend belgisi: rangli shisha plitka ichida makaron (ikki qobiq va mint krem).
/// Standart "tort" ikonkasi o'rniga ishlatiladi — butun ilovada bitta yagona belgi.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 96, this.shadow = true});

  final double size;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      image: true,
      excludeSemantics: true,
      child: GlassContainer(
        level: GlassLevel.floating,
        tint: c.cta,
        blur: false,
        shadow: shadow,
        borderRadius: BorderRadius.circular(size * 0.32),
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(painter: _MacaronPainter(cream: c.mint, glint: c.primary)),
        ),
      ),
    );
  }
}

class _MacaronPainter extends CustomPainter {
  _MacaronPainter({required this.cream, required this.glint});

  final Color cream;
  final Color glint;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final big = Radius.circular(s * 0.36);
    final small = Radius.circular(s * 0.08);

    final top = RRect.fromLTRBAndCorners(
      s * 0.20, s * 0.24, s * 0.80, s * 0.47,
      topLeft: big, topRight: big, bottomLeft: small, bottomRight: small,
    );
    final bottom = RRect.fromLTRBAndCorners(
      s * 0.20, s * 0.57, s * 0.80, s * 0.78,
      topLeft: small, topRight: small, bottomLeft: big, bottomRight: big,
    );
    final filling = RRect.fromLTRBR(s * 0.24, s * 0.46, s * 0.76, s * 0.58, Radius.circular(s * 0.06));

    Paint shell(Rect r) => Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white, Colors.white.withValues(alpha: 0.82)],
      ).createShader(r);

    canvas.drawRRect(top, shell(top.outerRect));
    canvas.drawRRect(bottom, shell(bottom.outerRect));
    canvas.drawRRect(filling, Paint()..color = cream);

    // Yuqori qobiqdagi kichik yaltirash.
    final glintPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = s * 0.028;
    canvas.drawArc(
      Rect.fromLTWH(s * 0.30, s * 0.29, s * 0.18, s * 0.16),
      3.4,
      1.2,
      false,
      glintPaint..color = glint.withValues(alpha: 0.28),
    );
  }

  @override
  bool shouldRepaint(_MacaronPainter old) => old.cream != cream || old.glint != glint;
}
