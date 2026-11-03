import 'package:flutter/material.dart';

/// «Vitrina» palitrasi: olcha (asosiy harakat), pistachio (yorug'lik) va karamel (baho/urg'u).
/// Liquid Glass ruhida: fon qorong'u-iliq emas, balki shisha ortidan nur o'tayotgandek. Barcha ranglar shu yerda.
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
    required this.ambientC,
    required this.accent,
    required this.mint,
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
  final Color ambientC;

  /// Karamel: baho yulduzchasi va kichik urg'ular uchun (asosiy harakat rangi emas).
  final Color accent;

  /// Pistachio: ikkilamchi "yangi/mavjud" ohangi va fon yorug'ligi.
  final Color mint;

  static const light = AppColors(
    background: Color(0xFFF8F3F5),
    surface: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF26151B),
    textSecondary: Color(0xFF6A5760),
    primary: Color(0xFFA3173F),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFFEFE3E7),
    success: Color(0xFF3F7A53),
    error: Color(0xFFB3303A),
    border: Color(0xFFE8DADF),
    skeletonBase: Color(0xFFEDE2E6),
    skeletonHighlight: Color(0xFFFAF5F7),
    shadow: Color(0x1A26151B),
    shadowStrong: Color(0x3326151B),
    glow: Color(0x00000000),
    cta: Color(0xFFA3173F),
    onCta: Color(0xFFFFFFFF),
    ambientA: Color(0xFFF1B8C7),
    ambientB: Color(0xFFC8E0C2),
    ambientC: Color(0xFFF6DDB4),
    accent: Color(0xFFB9731D),
    mint: Color(0xFF5E9B6E),
  );

  static const dark = AppColors(
    background: Color(0xFF140D11),
    surface: Color(0xFF241820),
    textPrimary: Color(0xFFF7ECF0),
    textSecondary: Color(0xFFCDB8C1),
    primary: Color(0xFFF28DA8),
    onPrimary: Color(0xFF140D11),
    secondary: Color(0xFF3B2630),
    success: Color(0xFF86CC98),
    error: Color(0xFFEF7A86),
    border: Color(0xFF38252E),
    skeletonBase: Color(0xFF2E1F27),
    skeletonHighlight: Color(0xFF3B2A34),
    shadow: Color(0x59000000),
    shadowStrong: Color(0x8C000000),
    glow: Color(0x33B0264A),
    cta: Color(0xFFB0264A),
    onCta: Color(0xFFFFFFFF),
    ambientA: Color(0xFF6A1030),
    ambientB: Color(0xFF1F4A3B),
    ambientC: Color(0xFF5A3A1E),
    accent: Color(0xFFE5A85A),
    mint: Color(0xFF8FD1A0),
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
    Color? ambientC,
    Color? accent,
    Color? mint,
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
      ambientC: ambientC ?? this.ambientC,
      accent: accent ?? this.accent,
      mint: mint ?? this.mint,
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
      ambientC: l(ambientC, other.ambientC),
      accent: l(accent, other.accent),
      mint: l(mint, other.mint),
    );
  }
}

extension AppColorsContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
