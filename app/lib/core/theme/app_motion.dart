import 'package:flutter/material.dart';

class AppMotion {
  AppMotion._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 300);
  static const Curve curve = Curves.easeOutCubic;

  /// M3 Expressive: tez boshlanib, yumshoq to'xtaydi (sahifa va katta yuzalar uchun).
  static const Curve emphasized = Cubic(0.2, 0.0, 0.0, 1.0);

  /// Yengil "sakrash": faqat bosilishga javob beradigan kichik elementlar uchun (indikator, belgi).
  static const Curve spring = Cubic(0.34, 1.32, 0.64, 1.0);

  /// Qurilmada "harakatni kamaytirish" yoqilganmi.
  static bool reduced(BuildContext context) => MediaQuery.disableAnimationsOf(context);

  /// Harakat kamaytirilgan bo'lsa nol, aks holda berilgan davomiylik.
  static Duration of(BuildContext context, [Duration d = normal]) =>
      reduced(context) ? Duration.zero : d;
}
