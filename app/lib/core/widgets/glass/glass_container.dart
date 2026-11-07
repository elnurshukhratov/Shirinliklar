import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_tokens.dart';
import '../../theme/glass_settings.dart';

/// Shisha darajalari. Har birining sigma, radius va shaffofligi spetsifikatsiyadan:
///
/// | daraja | blur sigma | radius | fill (kun / tun) |
/// |--------|-----------|--------|------------------|
/// | bar    | 28        | 32     | 0.58 / 0.09      |
/// | panel  | 24        | 28     | 0.66 / 0.12      |
/// | chip   | 18        | 999    | 0.50 / 0.07      |
///
/// [floating] = chip, [sheet] = panel: eski nomlar saqlangan (ularni ishlatadigan fayllar buzilmasin).
enum GlassLevel {
  /// Yuqori/pastki panellar, navigatsiya.
  bar,

  /// Guruhlangan boshqaruv qatorlari, dialog va sheet.
  panel,

  /// Kichik suzuvchi elementlar: tugma, qidiruv, ikonka tugmasi.
  chip,

  /// Eski nom: [chip] bilan bir xil.
  floating,

  /// Eski nom: [panel] bilan bir xil.
  sheet,
}

extension GlassLevelSpec on GlassLevel {
  double get sigma => switch (this) {
        GlassLevel.bar => 28,
        GlassLevel.panel || GlassLevel.sheet => 24,
        GlassLevel.chip || GlassLevel.floating => 18,
      };

  BorderRadius get radius => switch (this) {
        GlassLevel.bar => BorderRadius.circular(AppRadius.bar),
        GlassLevel.panel || GlassLevel.sheet => BorderRadius.circular(AppRadius.panel),
        GlassLevel.chip || GlassLevel.floating => BorderRadius.circular(AppRadius.pill),
      };

  /// Kunda oq fill shaffofligi (o'rtacha).
  double get lightAlpha => switch (this) {
        GlassLevel.bar => 0.58,
        GlassLevel.panel || GlassLevel.sheet => 0.66,
        GlassLevel.chip || GlassLevel.floating => 0.50,
      };

  /// Tunda oq fill shaffofligi (o'rtacha).
  double get darkAlpha => switch (this) {
        GlassLevel.bar => 0.09,
        GlassLevel.panel || GlassLevel.sheet => 0.12,
        GlassLevel.chip || GlassLevel.floating => 0.07,
      };
}

/// To'yinganlikni oshiruvchi rang matritsasi (orqa fon shisha ortida biroz "jonlanadi").
List<double> _saturationMatrix(double s) {
  const r = 0.2126, g = 0.7152, b = 0.0722;
  return [
    r * (1 - s) + s, g * (1 - s), b * (1 - s), 0, 0, //
    r * (1 - s), g * (1 - s) + s, b * (1 - s), 0, 0,
    r * (1 - s), g * (1 - s), b * (1 - s) + s, 0, 0,
    0, 0, 0, 1, 0,
  ];
}

final ColorFilter _saturate = ColorFilter.matrix(_saturationMatrix(1.35));

/// Haqiqiy "suyuq shisha" qatlami. To'rt qatlamdan iborat:
/// 1. **Material** — orqa fonni blur + to'yinganlikni oshirish (`ImageFilter.compose`),
///    ustida chap-yuqoridan o'ng-pastga so'nadigan yarim shaffof fill.
/// 2. **Yaltirash (specular)** — yuqori chetda yupqa oq chiziq va balandlikning ~24% qismida
///    yumshoq oq gradient.
/// 3. **Chekka** — 1 px: kunda oq 0.9 -> 0.25, tunda oq 0.28 -> 0.06.
/// 4. **Soya** — kunda 0/12/32 (shadow tokeni), tunda 0/16/40 qora 0.45.
///
/// [tint] berilsa (asosiy tugmalar): CTA rangi ~0.85 shaffoflikda, ustida yaltirash.
/// "Shaffoflikni kamaytirish" yoqilganda: blur yo'q, qattiq surface rangi + chekka.
///
/// Qoidalar: ro'yxat elementlarida [blur] ni `false` qiling; bir ekranda ko'pi bilan 3-4 ta
/// BackdropFilter bo'lsin; shisha ustiga shisha qo'ymang.
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

  /// Berilmasa, darajaning radiusi olinadi (bar 32, panel 28, chip 999).
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final reduced = GlassScope.reduced(context, ref);
    final radius = borderRadius ?? level.radius;
    final boost = strong ? 0.06 : 0.0;

    // ---- Fill --------------------------------------------------------------------------------
    final List<Color> fill;
    double specular;
    if (reduced) {
      final base = tint ?? (dark ? Color.lerp(c.surface, Colors.white, 0.06)! : c.surface);
      fill = [base, base];
      specular = 0;
    } else if (tint != null) {
      // Tinted: CTA ~0.85 (tepasi biroz yorug', pastga to'yinadi). Kunda oq matn kontrasti
      // 4.5:1 dan pastga tushmasligi uchun qoplash kuchliroq (shisha baribir yarim shaffof).
      final topAlpha = dark ? 0.89 : 0.93;
      final bottomAlpha = dark ? 0.81 : 0.88;
      fill = [
        Color.lerp(tint, Colors.white, 0.10)!.withValues(alpha: topAlpha + boost / 2),
        tint!.withValues(alpha: bottomAlpha + boost / 2),
      ];
      specular = 1;
    } else if (overMedia) {
      final base = dark ? c.background : c.surface;
      fill = [
        base.withValues(alpha: dark ? 0.80 : 0.92),
        base.withValues(alpha: (dark ? 0.70 : 0.84) + boost),
      ];
      specular = dark ? 0.5 : 0.8;
    } else if (dark) {
      final a = level.darkAlpha + boost;
      fill = [
        Colors.white.withValues(alpha: a * 1.35),
        Colors.white.withValues(alpha: a * 0.65),
      ];
      specular = 0.7;
    } else {
      // Kun: gradient chap-yuqorida ~0.75 dan o'ng-pastda ~0.35 gacha (bar uchun; boshqalarida mos).
      final a = level.lightAlpha + boost / 2;
      fill = [
        Colors.white.withValues(alpha: (a * 1.29).clamp(0.0, 1.0)),
        Colors.white.withValues(alpha: a * 0.60),
      ];
      specular = 1;
    }

    // ---- Chekka ------------------------------------------------------------------------------
    final Color rimStart;
    final Color rimEnd;
    if (reduced) {
      rimStart = c.border;
      rimEnd = c.border;
    } else if (dark) {
      rimStart = Colors.white.withValues(alpha: 0.28);
      rimEnd = Colors.white.withValues(alpha: 0.06);
    } else {
      // Kunda o'ng-pastki chekka oq emas, mayin to'q: och fonda shisha shakli yo'qolib qolmasin.
      rimStart = Colors.white.withValues(alpha: 0.90);
      rimEnd = c.textPrimary.withValues(alpha: 0.10);
    }

    Widget inner = padding == null ? child : Padding(padding: padding!, child: child);
    if (specular > 0) {
      inner = CustomPaint(
        painter: _SpecularPainter(radius: radius, strength: specular),
        child: inner,
      );
    }

    Widget body = CustomPaint(
      foregroundPainter: _RimPainter(
        radius: radius,
        start: rimStart,
        end: rimEnd,
        width: reduced ? 1.2 : 1,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: fill,
          ),
        ),
        child: inner,
      ),
    );

    if (blur && !reduced) {
      body = BackdropFilter(
        filter: ImageFilter.compose(
          outer: _saturate,
          inner: ImageFilter.blur(sigmaX: level.sigma, sigmaY: level.sigma),
        ),
        child: body,
      );
    }

    final List<BoxShadow>? shadows;
    if (!shadow) {
      shadows = null;
    } else if (tint != null && !reduced) {
      shadows = AppShadows.tinted(tint!, strength: dark ? 0.34 : 0.32);
    } else {
      shadows = AppShadows.glass(c, dark: dark);
    }

    return RepaintBoundary(
      child: DecoratedBox(
        decoration: BoxDecoration(borderRadius: radius, boxShadow: shadows),
        child: ClipRRect(borderRadius: radius, child: body),
      ),
    );
  }
}

/// Yaltirash: yuqori chetdagi yupqa oq chiziq (chetlarida so'nadi) va balandlikning ~24% qismida
/// yumshoq oq gradient.
class _SpecularPainter extends CustomPainter {
  _SpecularPainter({required this.radius, required this.strength});

  final BorderRadius radius;
  final double strength;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    canvas.save();
    canvas.clipRRect(radius.toRRect(Offset.zero & size));

    // Yumshoq gradient: balandlikning 24% i.
    final h = size.height * 0.24;
    final softRect = Rect.fromLTWH(0, 0, size.width, h);
    canvas.drawRect(
      softRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.38 * strength),
            Colors.white.withValues(alpha: 0),
          ],
        ).createShader(softRect),
    );

    // Yupqa chiziq: yuqori chetdan 1 px pastda, ikki chetda so'nadi.
    final lineRect = Rect.fromLTWH(0, 1, size.width, 1);
    canvas.drawRect(
      lineRect,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: 0.85 * strength),
            Colors.white.withValues(alpha: 0.85 * strength),
            Colors.white.withValues(alpha: 0),
          ],
          stops: const [0.04, 0.22, 0.78, 0.96],
        ).createShader(lineRect),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SpecularPainter old) => old.radius != radius || old.strength != strength;
}

/// 1 px chekka: chap-yuqorida yorqin, o'ng-pastda so'nadi.
class _RimPainter extends CustomPainter {
  _RimPainter({required this.radius, required this.start, required this.end, required this.width});

  final BorderRadius radius;
  final Color start;
  final Color end;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final rect = (Offset.zero & size).deflate(width / 2);
    canvas.drawRRect(
      radius.toRRect(rect),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [start, end],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_RimPainter old) =>
      old.radius != radius || old.start != start || old.end != end || old.width != width;
}