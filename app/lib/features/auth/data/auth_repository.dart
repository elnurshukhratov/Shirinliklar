import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../domain/app_user.dart';

class AuthRepository {
  AuthRepository(this._api, this._auth, this._google);

  final ApiClient _api;
  final FirebaseAuth _auth;
  final GoogleSignIn _google;

  bool get hasSession => _auth.currentUser != null;

  /// Foydalanuvchi oynani yopib qo'ysa null qaytaradi.
  Future<AppUser?> signInWithGoogle() async {
    final account = await _google.signIn();
    if (account == null) return null;

    final tokens = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: tokens.idToken,
      accessToken: tokens.accessToken,
    );
    await _auth.signInWithCredential(credential);

    try {
      final json = await _api.post<Map<String, dynamic>>('/auth/google');
      return AppUser.fromJson(json);
    } catch (_) {
      await signOut();
      rethrow;
    }
  }

  Future<AppUser> fetchMe() async {
    await _ensureToken();
    final json = await _api.get<Map<String, dynamic>>('/me');
    return AppUser.fromJson(json);
  }

  Future<AppUser> updateProfile({
    required String firstName,
    required String lastName,
    required String phone,
    required String address,
    String? landmark,
  }) async {
    final json = await _api.patch<Map<String, dynamic>>('/me', body: {
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'address': address,
      'landmark': landmark ?? '',
    });
    return AppUser.fromJson(json);
  }

  Future<void> deleteAccount() async {
    await _api.delete<Map<String, dynamic>>('/me');
    await signOut();
  }

  Future<void> signOut() async {
    try {
      await _google.signOut();
    } catch (_) {}
    await _auth.signOut();
  }

  Future<void> _ensureToken() async {
    try {
      await _auth.currentUser?.getIdToken();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'network-request-failed') {
        throw const ApiException(code: 'NETWORK_ERROR', message: 'NETWORK_ERROR');
      }
      throw const ApiException(code: 'UNAUTHORIZED', message: 'UNAUTHORIZED', status: 401);
    }
  }
}