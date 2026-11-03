import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Ikki shrift, ikkalasi ham lotin va kirill harflarini to'liq qo'llaydi:
/// - **Cormorant Garamond** — faqat yirik sarlavhalar (24 pt va undan katta): vitrina yozuvi kabi nafis.
/// - **Manrope** — qolgan hamma narsa (interfeys, narx, tugma): toza va kichik o'lchamda ham o'qiladi.
///
/// Ierarxiya 2–3 uslub + vazn bilan quriladi; o'lchamlar sp'da, shuning uchun tizimning
/// "matn o'lchami" sozlamasi bilan o'sadi (qarang: matn kattalashtirilganda ham kesilmaydi, o'raladi).
class AppTypography {
  AppTypography._();

  static const _tabular = [FontFeature.tabularFigures()];

  static TextTheme textTheme(AppColors c) {
    TextStyle display(double size, {double height = 1.08, double spacing = -0.2}) =>
        GoogleFonts.cormorantGaramond(
          fontSize: size,
          fontWeight: FontWeight.w700,
          height: height,
          letterSpacing: spacing,
        );

    TextStyle ui(
      double size,
      FontWeight weight, {
      double height = 1.4,
      double spacing = 0,
      bool numeric = false,
    }) =>
        GoogleFonts.manrope(
          fontSize: size,
          fontWeight: weight,
          height: height,
          letterSpacing: spacing,
          fontFeatures: numeric ? _tabular : null,
        );

    final theme = TextTheme(
      displayLarge: display(44),
      displayMedium: display(38),
      displaySmall: display(34),
      headlineLarge: display(32),
      headlineMedium: display(30),
      headlineSmall: display(26, height: 1.12),
      titleLarge: display(24, height: 1.15, spacing: 0),
      titleMedium: ui(16, FontWeight.w800, height: 1.3, numeric: true),
      titleSmall: ui(14.5, FontWeight.w700, height: 1.3),
      bodyLarge: ui(16, FontWeight.w500, height: 1.5),
      bodyMedium: ui(14, FontWeight.w500, height: 1.45),
      bodySmall: ui(12.5, FontWeight.w500, height: 1.4),
      labelLarge: ui(14, FontWeight.w700, height: 1.2, spacing: 0.1),
      labelMedium: ui(12.5, FontWeight.w700, height: 1.2, spacing: 0.1),
      labelSmall: ui(11.5, FontWeight.w700, height: 1.2, spacing: 0.2),
    );

    return theme.apply(bodyColor: c.textPrimary, displayColor: c.textPrimary);
  }
}
