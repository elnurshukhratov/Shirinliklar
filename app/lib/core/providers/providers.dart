import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../network/api_client.dart';

/// main.dart ichida haqiqiy qiymat bilan almashtiriladi.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider override qilinmagan'),
);

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final googleSignInProvider = Provider<GoogleSignIn>(
  (ref) => GoogleSignIn(
    scopes: const ['email'],
    serverClientId: AppConfig.googleServerClientId.isEmpty ? null : AppConfig.googleServerClientId,
  ),
);

/// Har so'rovda joriy Firebase ID token (muddati o'tsa avtomatik yangilanadi) yuboriladi.
final apiClientProvider = Provider<ApiClient>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return ApiClient(tokenProvider: () async => await auth.currentUser?.getIdToken());
});