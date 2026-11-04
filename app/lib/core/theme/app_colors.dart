import 'package:flutter/material.dart';

/// Ikki alohida muhit: KUN «Shirin tong» va TUN «Neon shirinlik». Barcha ranglar shu yerda —
/// vidjetlarda qattiq kodlangan rang bo'lmasin.
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
    required this.mintStrong,
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

  /// Asosiy harakat (CTA) tugmasining rangi va uning ustidagi matn.
  final Color cta;
  final Color onCta;

  /// Umumiy fon (AmbientBackground) uchun uchta yumshoq nur dog'i.
  final Color ambientA;
  final Color ambientB;
  final Color ambientC;

  /// Yulduzcha: baho yulduzchasi va kichik urg'ular uchun (asosiy harakat rangi emas).
  final Color accent;

  /// Mint: ikkilamchi "yangi/mavjud" ohangi va fon yorug'ligi.
  final Color mint;

  /// Mint'ning matn sifatida ishlatiladigan to'qroq varianti (kunda 4.5:1 kontrast uchun).
  final Color mintStrong;

  /// KUN — «Shirin tong»: iliq krem fon, qulupnay-pushti urg'u.
  static const light = AppColors(
    background: Color(0xFFFFFDF8),
    surface: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF1E1B3A),
    textSecondary: Color(0xFF5E5A7A),
    primary: Color(0xFFC8245A),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFFFFE9EF),
    success: Color(0xFF1A8050), // 1F8F5A dan to'qroq: matn kontrasti >= 4.5:1
    error: Color(0xFFD13535), // D93B3B dan to'qroq: matn kontrasti >= 4.5:1
    border: Color(0xFFEFE6EA),
    skeletonBase: Color(0xFFF3EBEE),
    skeletonHighlight: Color(0xFFFFFFFF),
    shadow: Color(0x1A1E1B3A),
    shadowStrong: Color(0x331E1B3A),
    glow: Color(0x00000000),
    cta: Color(0xFFD92A62),
    onCta: Color(0xFFFFFFFF),
    ambientA: Color(0xFFFF6B8B), // qulupnay
    ambientB: Color(0xFF7CC8FF), // osmon
    ambientC: Color(0xFFFFC247), // mango
    accent: Color(0xFFFFB020), // yulduzcha
    mint: Color(0xFF12B3A0), // mavjud / yangi
    mintStrong: Color(0xFF0B7A6D),
  );

  /// TUN — «Neon shirinlik»: chuqur binafsha fon, laym-neon urg'u.
  static const dark = AppColors(
    background: Color(0xFF0B0A14),
    surface: Color(0xFF17152A),
    textPrimary: Color(0xFFF4F1FF),
    textSecondary: Color(0xFFB8B2D6),
    primary: Color(0xFFB8FF6B),
    onPrimary: Color(0xFF10230A),
    secondary: Color(0xFF26223F),
    success: Color(0xFF5BE3A0),
    error: Color(0xFFFF6B7A),
    border: Color(0xFF2A2646),
    skeletonBase: Color(0xFF1D1A33),
    skeletonHighlight: Color(0xFF2B2748),
    shadow: Color(0x66000000),
    shadowStrong: Color(0x99000000),
    glow: Color(0x2EB8FF6B),
    cta: Color(0xFFB8FF6B),
    onCta: Color(0xFF10230A),
    ambientA: Color(0xFF6D3BFF), // uzum
    ambientB: Color(0xFFFF3EA5), // magenta
    ambientC: Color(0xFF19D3C5), // firuza
    accent: Color(0xFFFFC247),
    mint: Color(0xFF19D3C5),
    mintStrong: Color(0xFF19D3C5),
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
    Color? mintStrong,
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
      mintStrong: mintStrong ?? this.mintStrong,
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
      mintStrong: l(mintStrong, other.mintStrong),
    );
  }
}

extension AppColorsContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}
