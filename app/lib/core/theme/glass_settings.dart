import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/providers.dart';

/// «Shaffoflikni kamaytirish»: yoqilganda shisha xira (blur yo'q, deyarli to'q fill) bo'ladi.
/// Past quvvatli qurilmalar va ko'rish qulayligi uchun. Qurilmaning "yuqori kontrast"
/// sozlamasi yoqilgan bo'lsa ham shu rejim qo'llanadi (qarang: [GlassScope.reduced]).
class GlassReducedNotifier extends StateNotifier<bool> {
  GlassReducedNotifier(this._prefs) : super(_prefs.getBool(_key) ?? false);

  static const _key = 'glass_reduced';
  final SharedPreferences _prefs;

  Future<void> set(bool value) async {
    state = value;
    await _prefs.setBool(_key, value);
  }
}

final glassReducedProvider = StateNotifierProvider<GlassReducedNotifier, bool>(
  (ref) => GlassReducedNotifier(ref.watch(sharedPreferencesProvider)),
);

class GlassScope {
  GlassScope._();

  /// Shisha soddalashtirilishi kerakmi (foydalanuvchi sozlamasi yoki tizim kontrasti).
  static bool reduced(BuildContext context, WidgetRef ref) =>
      ref.watch(glassReducedProvider) || MediaQuery.highContrastOf(context);
}
