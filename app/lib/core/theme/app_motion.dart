import 'package:flutter/material.dart';

class AppMotion {
  AppMotion._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration slow = Duration(milliseconds: 300);
  static const Curve curve = Curves.easeOutCubic;

  /// Qurilmada "harakatni kamaytirish" yoqilganmi.
  static bool reduced(BuildContext context) => MediaQuery.disableAnimationsOf(context);

  /// Harakat kamaytirilgan bo'lsa nol, aks holda berilgan davomiylik.
  static Duration of(BuildContext context, [Duration d = normal]) =>
      reduced(context) ? Duration.zero : d;
}
