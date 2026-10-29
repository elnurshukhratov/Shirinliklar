import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/providers.dart';

class AppLocales {
  AppLocales._();

  static const uz = Locale('uz');
  static const en = Locale('en');
  static const ru = Locale('ru');

  static const supported = [uz, en, ru];

  /// Standart til — o'zbek.
  static const fallback = uz;
}

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier(this._prefs) : super(_read(_prefs));

  static const _key = 'locale';
  final SharedPreferences _prefs;

  static Locale _read(SharedPreferences prefs) {
    final code = prefs.getString(_key);
    return AppLocales.supported.firstWhere(
      (l) => l.languageCode == code,
      orElse: () => AppLocales.fallback,
    );
  }

  Future<void> setLocale(Locale locale) async {
    if (!AppLocales.supported.contains(locale)) return;
    state = locale;
    await _prefs.setString(_key, locale.languageCode);
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>(
  (ref) => LocaleNotifier(ref.watch(sharedPreferencesProvider)),
);
