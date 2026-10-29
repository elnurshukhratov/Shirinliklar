import 'package:flutter/material.dart';

/// «Shokolad va olcha» palitrasi (Liquid Glass ruhida). Barcha ranglar shu yerda.
/// Dark rejimda [primary] — matn/ikonka uchun och atirgul-olcha, tugma to'ldirishi esa [cta].
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.success,
    required this.error,
    required this.border,
    required this.skeletonBase,
    required this.skeletonHighlight,
    required this.shadow,
    required this.shadowStrong,
    required this.glow,
    required this.cta,
    required this.onCta,
    required this.ambientA,
    required this.ambientB,
  });

  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color primary;
  final Color onPrimary;
  final Color secondary;
  final Color success;
  final Color error;
  final Color border;
  final Color skeletonBase;
  final Color skeletonHighlight;
  final Color shadow;
  final Color shadowStrong;
  final Color glow;

  /// Asosiy harakat (CTA) tugmasining yarim shaffof olcha tinti va uning ustidagi matn.
  final Color cta;
  final Color onCta;

  /// Umumiy fon (AmbientBackground) uchun ikki yumshoq yorug'lik dog'i.
  final Color ambientA;
  final Color ambientB;

  static const light = AppColors(
    background: Color(0xFFFAF3EC),
    surface: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF2B1810),
    textSecondary: Color(0xFF6B5549),
    primary: Color(0xFF9E1F43),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFFEBD9CE),
    success: Color(0xFF4F7F55),
    error: Color(0xFFB3303A),
    border: Color(0xFFE6D6C9),
    skeletonBase: Color(0xFFEFE2D6),
    skeletonHighlight: Color(0xFFF8EEE6),
    shadow: Color(0x1A2B1810),
    shadowStrong: Color(0x332B1810),
    glow: Color(0x00000000),
    cta: Color(0xFF9E1F43),
    onCta: Color(0xFFFFFFFF),
    ambientA: Color(0xFFE9C3CC),
    ambientB: Color(0xFFF0D9BE),
  );

  static const dark = AppColors(
    background: Color(0xFF1C1210),
    surface: Color(0xFF2A1B17),
    textPrimary: Color(0xFFF6EBE2),
    textSecondary: Color(0xFFC9B5A8),
    primary: Color(0xFFF08AA2),
    onPrimary: Color(0xFF1C1210),
    secondary: Color(0xFF4A2E27),
    success: Color(0xFF7FC48C),
    error: Color(0xFFEF7A86),
    border: Color(0xFF3B2822),
    skeletonBase: Color(0xFF33231E),
    skeletonHighlight: Color(0xFF402D27),
    shadow: Color(0x4D000000),
    shadowStrong: Color(0x80000000),
    glow: Color(0x33B0264A),
    cta: Color(0xFFB0264A),
    onCta: Color(0xFFFFFFFF),
    ambientA: Color(0xFF5C0F25),
    ambientB: Color(0xFF6B3A22),
  );

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
    Color? primary,
    Color? onPrimary,
    Color? secondary,
    Color? success,
    Color? error,
    Color? border,
    Color? skeletonBase,
    Color? skeletonHighlight,
    Color? shadow,
    Color? shadowStrong,
    Color? glow,
    Color? cta,
    Color? onCta,
    Color? ambientA,
    Color? ambientB,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      secondary: secondary ?? this.secondary,
      success: success ?? this.success,
      error: error ?? this.error,
      border: border ?? this.border,
      skeletonBase: skeletonBase ?? this.skeletonBase,
      skeletonHighlight: skeletonHighlight ?? this.skeletonHighlight,
      shadow: shadow ?? this.shadow,
      shadowStrong: shadowStrong ?? this.shadowStrong,
      glow: glow ?? this.glow,
      cta: cta ?? this.cta,
      onCta: onCta ?? this.onCta,
      ambientA: ambientA ?? this.ambientA,
      ambientB: ambientB ?? this.ambientB,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      background: l(background, other.background),
      surface: l(surface, other.surface),
      textPrimary: l(textPrimary, other.textPrimary),
      textSecondary: l(textSecondary, other.textSecondary),
      primary: l(primary, other.primary),
      onPrimary: l(onPrimary, other.onPrimary),
      secondary: l(secondary, other.secondary),
      success: l(success, other.success),
      error: l(error, other.error),
      border: l(border, other.border),
      skeletonBase: l(skeletonBase, other.skeletonBase),
      skeletonHighlight: l(skeletonHighlight, other.skeletonHighlight),
      shadow: l(shadow, other.shadow),
      shadowStrong: l(shadowStrong, other.shadowStrong),
      glow: l(glow, other.glow),
      cta: l(cta, other.cta),
      onCta: l(onCta, other.onCta),
      ambientA: l(ambientA, other.ambientA),
      ambientB: l(ambientB, other.ambientB),
    );
  }
}

extension AppColorsContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
