import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import '../../theme/glass_settings.dart';

/// Shisha darajalari. Faqat Regular turi ishlatiladi: u istalgan fon ustida o'qiladi.
enum GlassLevel {
  /// Yuqori/pastki panellar, navigatsiya.
  bar,

  /// Suzuvchi tugmalar va qidiruv.
  floating,

  /// Bottom sheet va katta yuzalar.
  sheet,
}

/// Qayta ishlatiladigan shisha qatlam: blur + yarim shaffof gradient + nozik chegara
/// (yuqori chapdan yorug'lik aksi) + yumshoq soya.
///
/// Qoidalar: faqat boshqaruv qatlamida ishlating (panel, tugma, sheet); kontent
/// kartalariga bermang; shisha ustiga shisha qo'ymang. Ro'yxat ichida ko'p nusxa
/// kerak bo'lsa [blur] ni `false` qiling (faqat yarim shaffof fill chiziladi).
class GlassContainer extends ConsumerWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.level = GlassLevel.floating,
    this.borderRadius,
    this.padding,
    this.tint,
    this.blur = true,
    this.shadow = true,
    this.strong = false,
    this.overMedia = false,
  });

  final Widget child;
  final GlassLevel level;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;

  /// Faqat asosiy harakat uchun: yarim shaffof rang (masalan, [AppColors.cta]).
  final Color? tint;
  final bool blur;
  final bool shadow;

  /// Bosilgan holat: shisha biroz yorqinroq.
  final bool strong;

  /// Fotosurat ustida turadigan shisha: fon rasmning yorqinligiga bog'liq bo'lmasligi uchun
  /// to'liqroq qoplaydi (matn va ikonka har qanday rasm ustida o'qiladi).
  final bool overMedia;

  double get _sigma => switch (level) {
        GlassLevel.bar => 18,
        GlassLevel.floating => 14,
        GlassLevel.sheet => 28,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final reduced = GlassScope.reduced(context, ref);
    final radius = borderRadius ?? AppRadius.borderBar;
    final boost = strong ? 0.06 : 0.0;

    final List<Color> fill;
    if (reduced) {
      final base = tint ?? (dark ? Color.lerp(c.surface, Colors.white, 0.06)! : c.surface);
      fill = [base, base];
    } else if (tint != null) {
      fill = [tint!.withOpacity(0.95), tint!.withOpacity(0.84 + boost)];
    } else if (overMedia) {
      final base = dark ? c.background : c.surface;
      fill = [
        base.withOpacity(dark ? 0.80 : 0.92),
        base.withOpacity((dark ? 0.70 : 0.84) + boost),
      ];
    } else if (dark) {
      fill = [
        Colors.white.withOpacity(0.16 + boost),
        Colors.white.withOpacity(0.07 + boost),
      ];
    } else {
      fill = [
        Colors.white.withOpacity(0.74 + boost / 2),
        Colors.white.withOpacity(0.50 + boost / 2),
      ];
    }

    Widget body = CustomPaint(
      foregroundPainter: _GlassStrokePainter(
        radius: radius,
        highlight: Colors.white.withOpacity(dark ? 0.34 : 0.95),
        edge: reduced ? c.border : Colors.white.withOpacity(dark ? 0.06 : 0.55),
        width: reduced ? 1.2 : 1,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: fill,
          ),
        ),
        child: padding == null ? child : Padding(padding: padding!, child: child),
      ),
    );

    if (blur && !reduced) {
      body = BackdropFilter(
        filter: ImageFilter.blur(sigmaX: _sigma, sigmaY: _sigma),
        child: body,
      );
    }

    final shadows = !shadow
        ? null
        : [
            BoxShadow(
              color: c.shadow,
              blurRadius: level == GlassLevel.sheet ? 40 : 24,
              spreadRadius: -6,
              offset: Offset(0, level == GlassLevel.sheet ? -8 : 10),
            ),
          ];

    return RepaintBoundary(
      child: DecoratedBox(
        decoration: BoxDecoration(borderRadius: radius, boxShadow: shadows),
        child: ClipRRect(borderRadius: radius, child: body),
      ),
    );
  }
}

/// Nozik gradient chegara: yuqori chapda yorqin (yorug'lik aksi), pastda so'nadi.
class _GlassStrokePainter extends CustomPainter {
  _GlassStrokePainter({
    required this.radius,
    required this.highlight,
    required this.edge,
    required this.width,
  });

  final BorderRadius radius;
  final Color highlight;
  final Color edge;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(width / 2);
    final rrect = radius.toRRect(rect);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [highlight, edge, edge, highlight.withOpacity(highlight.opacity * 0.4)],
        stops: const [0, 0.35, 0.7, 1],
      ).createShader(rect);
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(_GlassStrokePainter old) =>
      old.radius != radius || old.highlight != highlight || old.edge != edge || old.width != width;
}
