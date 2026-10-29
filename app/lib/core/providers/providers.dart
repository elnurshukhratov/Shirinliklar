import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/api_client.dart';
import '../network/token_store.dart';

/// main.dart ichida haqiqiy qiymat bilan almashtiriladi.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider override qilinmagan'),
);

final tokenStoreProvider = Provider<TokenStore>(
  (ref) => TokenStore(ref.watch(sharedPreferencesProvider)),
);

/// Har so'rovga saqlangan kirish tokeni qo'shiladi.
final apiClientProvider = Provider<ApiClient>((ref) {
  final tokens = ref.watch(tokenStoreProvider);
  return ApiClient(tokenProvider: () async => tokens.token);
});