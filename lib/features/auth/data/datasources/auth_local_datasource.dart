import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Contract for securely persisting authentication tokens locally.
abstract interface class AuthLocalDataSource {
  /// Stores access and refresh tokens in secure storage.
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });

  /// Retrieves the persisted access token, if any.
  Future<String?> getAccessToken();

  /// Retrieves the persisted refresh token, if any.
  Future<String?> getRefreshToken();

  /// Clears all persisted authentication tokens.
  Future<void> clearTokens();
}

/// Implementation of [AuthLocalDataSource] backed by [FlutterSecureStorage].
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  const AuthLocalDataSourceImpl({required FlutterSecureStorage secureStorage})
    : _storage = secureStorage;

  final FlutterSecureStorage _storage;

  static const String _accessTokenKey = 'learno_auth_access_token';
  static const String _refreshTokenKey = 'learno_auth_refresh_token';

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  @override
  Future<String?> getAccessToken() async {
    return _storage.read(key: _accessTokenKey);
  }

  @override
  Future<String?> getRefreshToken() async {
    return _storage.read(key: _refreshTokenKey);
  }

  @override
  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
