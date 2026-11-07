import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../theme/app_motion.dart';
import 'expand_origin.dart';

/// Kengayuvchi sahifa ichidagi vidjetlar uchun: ochilish progressi (0..1, prujinali) va manba.
class ExpandScope extends InheritedWidget {
  const ExpandScope({
    super.key,
    required this.progress,
    required this.hasOrigin,
    required this.origin,
    required super.child,
  });

  final ValueListenable<double> progress;

  /// Kartadan kengayish bormi (deep link va "harakatni kamaytirish"da false).
  final bool hasOrigin;
  final ExpandOrigin? origin;

  static ExpandScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ExpandScope>();

  @override
  bool updateShouldNotify(ExpandScope old) =>
      old.progress != progress || old.hasOrigin != hasOrigin || old.origin != origin;
}

/// Kontentni kengayish progressining 25–100% oralig'ida ketma-ket paydo qiladi
/// (pastdan ko'tarilib, xiralikdan chiqadi). [index] kattalashgani sari kechroq boshlanadi.
/// Sahifa yig'ilganda teskari tartibda yo'qoladi. ExpandScope yo'q bo'lsa — kontentning o'zi.
class ExpandReveal extends StatelessWidget {
  const ExpandReveal({
    super.key,
    required this.child,
    this.index = 0,
    this.start,
    this.end,
    this.offset = 18,
    this.fade = true,
  });

  final Widget child;
  final int index;

  /// Progressning qaysi qiymatida boshlanishi/tugashi (berilmasa [index] dan hisoblanadi).
  final double? start;
  final double? end;

  /// Boshlang'ich pastga siljish (dp).
  final double offset;

  /// false bo'lsa faqat siljiydi (ichida BackdropFilter bo'lgan shisha uchun).
  final bool fade;

  @override
  Widget build(BuildContext context) {
    final scope = ExpandScope.maybeOf(context);
    if (scope == null || AppMotion.reduced(context)) return child;

    final s = start ?? (0.25 + 0.07 * index.clamp(0, 6));
    final e = end ?? (s + 0.4 > 1.0 ? 1.0 : s + 0.4);

    return ValueListenableBuilder<double>(
      valueListenable: scope.progress,
      child: child,
      builder: (context, p, child) {
        final t = Curves.easeOutCubic.transform(((p - s) / (e - s)).clamp(0.0, 1.0).toDouble());
        Widget w = Transform.translate(offset: Offset(0, offset * (1 - t)), child: child);
        if (fade) w = Opacity(opacity: t, child: w);
        return w;
      },
    );
  }
}