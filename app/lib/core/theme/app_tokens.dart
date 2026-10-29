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
  static const double card = 22;
  static const double bar = 30;
  static const double sheet = 32;
  static const double pill = 999;

  static BorderRadius get borderCard => BorderRadius.circular(card);
  static BorderRadius get borderBar => BorderRadius.circular(bar);
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

  /// Tun mavzusida deyarli bilinmaydigan mayin yorug'lik.
  static List<BoxShadow> glow(AppColors c) => [
        BoxShadow(color: c.glow, blurRadius: 22, spreadRadius: 0),
      ];
}
