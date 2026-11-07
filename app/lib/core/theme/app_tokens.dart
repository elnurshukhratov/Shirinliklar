import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppSpacing {
  AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

class AppRadius {
  AppRadius._();

  /// Tugma, karta, kiritish maydoni va chiplar uchun yagona burchak (12–16 px oralig'ida).
  static const double base = 14;
  static const double small = 8;

  /// Liquid Glass ierarxiyasi: element kattalashgani sari burchak ham yumaloqlashadi.
  static const double chip = 14;
  static const double card = 24;

  /// Shisha radiuslari: bar 32, panel 28, chip 999 (pill).
  /// Ichki element radiusi = tashqi radius - padding (qarang: [inner]).
  static const double bar = 32;
  static const double panel = 28;
  static const double sheet = 28;
  static const double pill = 999;

  /// Ichma-ich joylashgan elementning radiusi: tashqi radius minus padding.
  static double inner(double outer, double padding) => (outer - padding).clamp(0, outer).toDouble();

  static BorderRadius get borderCard => BorderRadius.circular(card);
  static BorderRadius get borderBar => BorderRadius.circular(bar);
  static BorderRadius get borderPanel => BorderRadius.circular(panel);
  static BorderRadius get borderPill => BorderRadius.circular(pill);
  static const BorderRadius borderSheet =
      BorderRadius.vertical(top: Radius.circular(sheet));

  static BorderRadius get borderBase => BorderRadius.circular(base);
  static BorderRadius get borderSmall => BorderRadius.circular(small);
}

class AppShadows {
  AppShadows._();

  static List<BoxShadow> rest(AppColors c) => [
        BoxShadow(color: c.shadow, blurRadius: 24, spreadRadius: -4, offset: const Offset(0, 8)),
      ];

  static List<BoxShadow> lifted(AppColors c) => [
        BoxShadow(color: c.shadowStrong, blurRadius: 32, spreadRadius: -4, offset: const Offset(0, 14)),
      ];

  /// Rangli (CTA) soya: asosiy harakat tugmasi "yorug'lik sochib" turgandek.
  static List<BoxShadow> tinted(Color tint, {double strength = 0.38}) => [
        BoxShadow(
          color: tint.withValues(alpha: strength),
          blurRadius: 26,
          spreadRadius: -8,
          offset: const Offset(0, 12),
        ),
      ];

  /// Shisha soyasi: kunda 0/12/32 (shadow tokeni), tunda 0/16/40 qora 0.45.
  static List<BoxShadow> glass(AppColors c, {required bool dark}) => dark
      ? [BoxShadow(color: Colors.black.withValues(alpha: 0.45), blurRadius: 40, offset: const Offset(0, 16))]
      : [BoxShadow(color: c.shadow, blurRadius: 32, offset: const Offset(0, 12))];

  /// Tun mavzusida deyarli bilinmaydigan mayin yorug'lik.
  static List<BoxShadow> glow(AppColors c) => [
        BoxShadow(color: c.glow, blurRadius: 22, spreadRadius: 0),
      ];
}