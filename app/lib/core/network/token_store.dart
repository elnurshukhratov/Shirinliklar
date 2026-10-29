import 'package:shared_preferences/shared_preferences.dart';

/// Kirish tokeni (JWT) qurilmada saqlanadi, shuning uchun ilovani qayta ochganda qayta kirish shart emas.
class TokenStore {
  TokenStore(this._prefs);

  static const _key = 'auth_token';

  final SharedPreferences _prefs;

  String? get token => _prefs.getString(_key);

  Future<void> save(String token) => _prefs.setString(_key, token);

  Future<void> clear() => _prefs.remove(_key);
}