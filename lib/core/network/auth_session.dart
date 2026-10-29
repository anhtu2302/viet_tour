import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthSession {
  AuthSession._();

  static final AuthSession instance = AuthSession._();

  static const _accessTokenKey = 'viettour_access_token';
  static const _refreshTokenKey = 'viettour_refresh_token';
  static const _userKey = 'viettour_user';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> get accessToken => _storage.read(key: _accessTokenKey);
  Future<String?> get refreshToken => _storage.read(key: _refreshTokenKey);

  Future<Map<String, dynamic>?> readUser() async {
    final encoded = await _storage.read(key: _userKey);
    if (encoded == null) return null;
    final decoded = jsonDecode(encoded);
    if (decoded is Map<String, dynamic>) return decoded;
    return null;
  }

  Future<void> save({
    required String accessToken,
    required String refreshToken,
    required Map<String, dynamic> user,
  }) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
      _storage.write(key: _userKey, value: jsonEncode(user)),
    ]);
  }

  Future<void> saveUser(Map<String, dynamic> user) =>
      _storage.write(key: _userKey, value: jsonEncode(user));

  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userKey);
  }
}
