import 'dart:math' as math;
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

/// Qayta ishlatiladigan shisha qatlam. Uch qatlamdan iborat:
/// 1. **Material** — blur + yarim shaffof gradient fill (pastga qarab shaffoflashadi).
/// 2. **Yorug'lik** — yuqori chekkadagi nozik "specular" yaltirash (shisha nurni ushlab turgandek).
/// 3. **Chekka** — yuqori chapda yorqin, pastki o'ngda so'nadigan rim + pastda ichki soya.
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
        GlassLevel.bar => 22,
        GlassLevel.floating => 16,
        GlassLevel.sheet => 30,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final reduced = GlassScope.reduced(context, ref);
    final radius = borderRadius ?? AppRadius.borderBar;
    final boost = strong ? 0.06 : 0.0;

    final List<Color> fill;
    double sheenAlpha;
    if (reduced) {
      final base = tint ?? (dark ? Color.lerp(c.surface, Colors.white, 0.06)! : c.surface);
      fill = [base, base];
      sheenAlpha = 0;
    } else if (tint != null) {
      // Rangli shisha: tepasi biroz yorug', pastga qarab to'yinadi.
      final top = Color.lerp(tint, Colors.white, 0.16)!;
      fill = [top.withValues(alpha: 0.97), tint!.withValues(alpha: 0.88 + boost)];
      sheenAlpha = 0.26;
    } else if (overMedia) {
      final base = dark ? c.background : c.surface;
      fill = [
        base.withValues(alpha: dark ? 0.80 : 0.92),
        base.withValues(alpha: (dark ? 0.70 : 0.84) + boost),
      ];
      sheenAlpha = dark ? 0.08 : 0.35;
    } else if (dark) {
      fill = [
        Colors.white.withValues(alpha: 0.15 + boost),
        Colors.white.withValues(alpha: 0.06 + boost),
      ];
      sheenAlpha = 0.12;
    } else {
      fill = [
        Colors.white.withValues(alpha: 0.78 + boost / 2),
        Colors.white.withValues(alpha: 0.46 + boost / 2),
      ];
      sheenAlpha = 0.55;
    }

    Widget inner = padding == null ? child : Padding(padding: padding!, child: child);
    if (sheenAlpha > 0) {
      inner = CustomPaint(
        painter: _SheenPainter(radius: radius, alpha: sheenAlpha),
        child: inner,
      );
    }

    Widget body = CustomPaint(
      foregroundPainter: _RimPainter(
        radius: radius,
        highlight: Colors.white.withValues(alpha: dark ? 0.36 : 0.98),
        edge: reduced ? c.border : Colors.white.withValues(alpha: dark ? 0.05 : 0.5),
        shade: reduced ? Colors.transparent : (dark ? Colors.black : c.textPrimary).withValues(alpha: dark ? 0.35 : 0.07),
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
        child: inner,
      ),
    );

    if (blur && !reduced) {
      body = BackdropFilter(
        filter: ImageFilter.blur(sigmaX: _sigma, sigmaY: _sigma),
        child: body,
      );
    }

    final List<BoxShadow>? shadows;
    if (!shadow) {
      shadows = null;
    } else if (tint != null && !reduced) {
      shadows = AppShadows.tinted(tint!, strength: dark ? 0.34 : 0.32);
    } else {
      shadows = [
        BoxShadow(
          color: c.shadow,
          blurRadius: level == GlassLevel.sheet ? 44 : 26,
          spreadRadius: -6,
          offset: Offset(0, level == GlassLevel.sheet ? -8 : 10),
        ),
      ];
    }

    return RepaintBoundary(
      child: DecoratedBox(
        decoration: BoxDecoration(borderRadius: radius, boxShadow: shadows),
        child: ClipRRect(borderRadius: radius, child: body),
      ),
    );
  }
}

/// Yuqori chekkadagi yorug'lik: balandligi cheklangan (katta sheetda ham faqat tepada), pastga so'nadi.
class _SheenPainter extends CustomPainter {
  _SheenPainter({required this.radius, required this.alpha});

  final BorderRadius radius;
  final double alpha;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final h = math.min(size.height * 0.55, 84.0);
    final rect = Rect.fromLTWH(0, 0, size.width, h);
    canvas.save();
    canvas.clipRRect(radius.toRRect(Offset.zero & size));
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white.withValues(alpha: alpha), Colors.white.withValues(alpha: 0)],
        ).createShader(rect),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SheenPainter old) => old.radius != radius || old.alpha != alpha;
}

/// Chekka: yuqori chapda yorqin, markazda deyarli ko'rinmas, pastki o'ngda yana biroz yorqin
/// (nur shisha ichidan o'tib chiqqandek) + pastki ichki soya (qalinlik hissi).
class _RimPainter extends CustomPainter {
  _RimPainter({
    required this.radius,
    required this.highlight,
    required this.edge,
    required this.shade,
    required this.width,
  });

  final BorderRadius radius;
  final Color highlight;
  final Color edge;
  final Color shade;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rect = (Offset.zero & size).deflate(width / 2);
    final rrect = radius.toRRect(rect);

    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [highlight, edge, edge, highlight.withValues(alpha: highlight.a * 0.45)],
          stops: const [0, 0.35, 0.7, 1],
        ).createShader(rect),
    );

    if (shade.a > 0) {
      final inner = radius.toRRect((Offset.zero & size).deflate(width + 0.6));
      canvas.drawRRect(
        inner,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [shade.withValues(alpha: 0), shade.withValues(alpha: 0), shade],
            stops: const [0, 0.6, 1],
          ).createShader(Offset.zero & size),
      );
    }
  }

  @override
  bool shouldRepaint(_RimPainter old) =>
      old.radius != radius ||
      old.highlight != highlight ||
      old.edge != edge ||
      old.shade != shade ||
      old.width != width;
}
