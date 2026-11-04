import 'dart:ui' show FontFeature, FontVariation;

import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Ikki shrift, ikkalasi ham assets/fonts ichida (internetsiz ham ishlaydi) va
/// lotin, kirill hamda oʻzbek ʻ ʼ belgilarini to'liq qo'llaydi:
/// - **Unbounded** — sarlavha, narx, dock yorlig'i (w600–700).
/// - **Onest** — qolgan hamma matn.
///
/// Ierarxiya: 3 o'lcham × 2 vazn (title/body/caption × regular/bold).
/// O'lchamlar sp'da, shuning uchun tizim matn o'lchami bilan o'sadi (o'raladi, kesilmaydi).
class AppTypography {
  AppTypography._();

  static const String displayFamily = 'Unbounded';
  static const String bodyFamily = 'Onest';

  static const _tabular = [FontFeature.tabularFigures()];

  /// Sinov matni: ʻ ʼ va kirill harflari to'g'ri chiqishini tekshirish uchun.
  static const String glyphTest = 'Oʻzbekiston Gʻisht Ўзбекистон Привет';

  /// Sarlavha va narx uchun (Unbounded). Narxlarda [numeric] = tabularFigures.
  static TextStyle display(
    double size, {
    FontWeight weight = FontWeight.w700,
    double height = 1.2,
    double spacing = 0,
    bool numeric = false,
  }) =>
      TextStyle(
        fontFamily: displayFamily,
        fontSize: size,
        fontWeight: weight,
        fontVariations: [FontVariation('wght', weight.value.toDouble())],
        height: height,
        letterSpacing: spacing,
        fontFeatures: numeric ? _tabular : null,
      );

  /// Interfeys matni (Onest).
  static TextStyle ui(
    double size,
    FontWeight weight, {
    double height = 1.4,
    double spacing = 0,
    bool numeric = false,
  }) =>
      TextStyle(
        fontFamily: bodyFamily,
        fontSize: size,
        fontWeight: weight,
        fontVariations: [FontVariation('wght', weight.value.toDouble())],
        height: height,
        letterSpacing: spacing,
        fontFeatures: numeric ? _tabular : null,
      );

  /// Narx uchun tayyor uslub (Unbounded + tabularFigures).
  static TextStyle price(double size, {FontWeight weight = FontWeight.w700}) =>
      display(size, weight: weight, height: 1.25, numeric: true);

  /// Dock yorlig'i (Unbounded, kichik).
  static TextStyle dockLabel({double size = 11}) =>
      display(size, weight: FontWeight.w600, height: 1.2, spacing: 0.1);

  static TextTheme textTheme(AppColors c) {
    // Kattalar: 3 o'lcham (titleL 24 / titleM 17 / titleS 14.5) x 2 vazn (w600 / w700).
    final theme = TextTheme(
      displayLarge: display(34, height: 1.15),
      displayMedium: display(30, height: 1.15),
      displaySmall: display(26, height: 1.18),
      headlineLarge: display(24, height: 1.2),
      headlineMedium: display(22, height: 1.2),
      headlineSmall: display(20, weight: FontWeight.w600, height: 1.22),
      titleLarge: display(20, weight: FontWeight.w600, height: 1.25),
      titleMedium: display(15, weight: FontWeight.w600, height: 1.3, numeric: true),
      titleSmall: ui(14.5, FontWeight.w700, height: 1.3),
      bodyLarge: ui(16, FontWeight.w400, height: 1.5),
      bodyMedium: ui(14, FontWeight.w400, height: 1.45),
      bodySmall: ui(12.5, FontWeight.w400, height: 1.4),
      labelLarge: ui(14, FontWeight.w700, height: 1.2, spacing: 0.1),
      labelMedium: ui(12.5, FontWeight.w700, height: 1.2, spacing: 0.1),
      labelSmall: ui(11.5, FontWeight.w700, height: 1.2, spacing: 0.2),
    );

    return theme.apply(bodyColor: c.textPrimary, displayColor: c.textPrimary);
  }
}
