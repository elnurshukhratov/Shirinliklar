import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// O'rtacha bahoni tilga mos ko'rinishda (4.5 yoki 4,5) chiqaradi.
String formatRating(BuildContext context, double value) {
  final tag = Localizations.localeOf(context).toLanguageTag();
  return NumberFormat('0.0', tag).format(value);
}
