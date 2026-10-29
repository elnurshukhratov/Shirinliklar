import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../l10n/gen/app_localizations.dart';

/// Matn va formatlar joriy tilga qarab chiqadi.
extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  String get _tag => Localizations.localeOf(this).toLanguageTag();

  String formatNumber(num value) => NumberFormat.decimalPattern(_tag).format(value);

  /// Narx so'mda: 125 000 so'm / 125,000 UZS / 125 000 сум.
  String formatPrice(num sum) => l10n.priceSum(formatNumber(sum.round()));

  String formatDate(DateTime date) => DateFormat.yMMMd(_tag).format(date);

  String formatTime(DateTime date) => DateFormat.Hm(_tag).format(date);

  String formatDateTime(DateTime date) => '${formatDate(date)}, ${formatTime(date)}';
}
