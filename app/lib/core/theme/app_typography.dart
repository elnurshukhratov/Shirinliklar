import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Sarlavha: Lora (yumshoq serif), matn: Nunito. Ikkalasi ham lotin va kirill harflarini to'liq qo'llaydi.
class AppTypography {
  AppTypography._();

  static TextTheme textTheme(AppColors c) {
    final base = GoogleFonts.nunitoTextTheme();

    TextStyle? heading(TextStyle? s) =>
        GoogleFonts.lora(textStyle: s, fontWeight: FontWeight.w700, height: 1.25);

    final themed = base.copyWith(
      displayLarge: heading(base.displayLarge),
      displayMedium: heading(base.displayMedium),
      displaySmall: heading(base.displaySmall),
      headlineLarge: heading(base.headlineLarge),
      headlineMedium: heading(base.headlineMedium),
      headlineSmall: heading(base.headlineSmall),
      titleLarge: heading(base.titleLarge),
      titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      titleSmall: base.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w700),
    );

    return themed.apply(bodyColor: c.textPrimary, displayColor: c.textPrimary);
  }
}
