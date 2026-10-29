import '../../../core/network/api_client.dart';
import '../../../core/network/token_store.dart';
import '../domain/app_user.dart';

class AuthRepository {
  AuthRepository(this._api, this._tokens);

  final ApiClient _api;
  final TokenStore _tokens;

  bool get hasSession => (_tokens.token ?? '').isNotEmpty;

  /// Ro'yxatdan o'tadi (kod yuborilmaydi) va darhol kiradi.
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
    final json = await _api.post<Map<String, dynamic>>('/auth/register', body: {
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'email': email,
      'phone': phone,
      'address': address,
      'password': password,
      'passwordConfirm': passwordConfirm,
    });
    return _startSession(json);
  }

  /// [login] — username yoki email.
  Future<AppUser> signInWithPassword({required String login, required String password}) async {
    final json = await _api.post<Map<String, dynamic>>('/auth/login', body: {
      'login': login.trim(),
      'password': password,
    });
    return _startSession(json);
  }

  Future<AppUser> _startSession(Map<String, dynamic> json) async {
    await _tokens.save(json['token'] as String);
    return AppUser.fromJson(json['user'] as Map<String, dynamic>);
  }

  Future<AppUser> fetchMe() async {
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

  /// Username va/yoki parolni o'zgartiradi (joriy parol shart).
  Future<AppUser> changeCredentials({
    required String currentPassword,
    String? username,
    String? newPassword,
  }) async {
    final json = await _api.patch<Map<String, dynamic>>('/me/credentials', body: {
      'currentPassword': currentPassword,
      if (username != null) 'username': username,
      if (newPassword != null) 'newPassword': newPassword,
    });
    return AppUser.fromJson(json);
  }

  Future<void> deleteAccount() async {
    await _api.delete<Map<String, dynamic>>('/me');
    await signOut();
  }

  Future<void> signOut() => _tokens.clear();
}