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

  /// Email + parol bilan ro'yxatdan o'tadi (kod yuborilmaydi) va darhol kiradi.
  Future<AppUser> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String phone,
    required String address,
    required String password,
    required String passwordConfirm,
  }) async {
    await _api.post<Map<String, dynamic>>('/auth/register', body: {
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'email': email,
      'phone': phone,
      'address': address,
      'password': password,
      'passwordConfirm': passwordConfirm,
    });
    await _signInWithEmail(email, password);
    return _loadMeOrSignOut();
  }

  /// [login] — username yoki email.
  Future<AppUser> signInWithPassword({required String login, required String password}) async {
    final value = login.trim();
    final email = value.contains('@') ? value.toLowerCase() : await _emailForUsername(value);
    await _signInWithEmail(email, password);
    return _loadMeOrSignOut();
  }

  Future<String> _emailForUsername(String username) async {
    final json = await _api.post<Map<String, dynamic>>('/auth/lookup', body: {'username': username});
    return json['email'] as String;
  }

  Future<void> _signInWithEmail(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'network-request-failed':
          throw const ApiException(code: 'NETWORK_ERROR', message: 'NETWORK_ERROR');
        case 'too-many-requests':
          throw const ApiException(code: 'TOO_MANY_REQUESTS', message: 'TOO_MANY_REQUESTS', status: 429);
        default:
          throw const ApiException(code: 'BAD_REQUEST', message: 'INVALID_CREDENTIALS', status: 400);
      }
    }
  }

  Future<AppUser> _loadMeOrSignOut() async {
    try {
      return await fetchMe();
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