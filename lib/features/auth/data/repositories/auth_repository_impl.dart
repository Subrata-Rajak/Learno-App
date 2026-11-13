import 'package:learno/core/network/errors/app_exception.dart';
import 'package:learno/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:learno/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:learno/features/auth/domain/entities/auth_user.dart';
import 'package:learno/features/auth/domain/repositories/auth_repository.dart';

/// Implementation of [AuthRepository] coordinating remote API operations
/// and local secure token persistence.
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final response = await remoteDataSource.login(
      email: email,
      password: password,
    );

    await localDataSource.saveTokens(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
    );

    return response.user;
  }

  @override
  Future<AuthUser> register({
    required String email,
    required String password,
    String? name,
  }) async {
    return remoteDataSource.register(
      email: email,
      password: password,
      name: name,
    );
  }

  @override
  Future<AuthUser?> restoreSession() async {
    final accessToken = await localDataSource.getAccessToken();
    final refreshToken = await localDataSource.getRefreshToken();

    // 1. If no credentials exist at all, remain in guest mode
    if (accessToken == null && refreshToken == null) {
      return null;
    }

    // 2. If access token exists, verify session with backend
    if (accessToken != null) {
      try {
        final user = await remoteDataSource.getMe();
        return user;
      } on UnauthorizedException {
        // Access token likely expired (401); attempt refresh flow below
      } on NetworkException {
        // Device offline or backend unreachable; do not clear credentials
        return null;
      } on TimeoutException {
        // Connection or receive timeout; preserve credentials
        return null;
      } on ServerException {
        // HTTP 5xx server error; preserve credentials
        return null;
      } catch (_) {
        // Unexpected transient failure; preserve credentials
        return null;
      }
    }

    // 3. Attempt token refresh using stored refresh token
    if (refreshToken != null) {
      final refreshSuccess = await refreshSession();
      if (refreshSuccess) {
        try {
          return await remoteDataSource.getMe();
        } on UnauthorizedException {
          await localDataSource.clearTokens();
          return null;
        } catch (_) {
          return null;
        }
      }

      // If refresh failed, do not blindly clear tokens.
      // refreshSession() already cleared tokens if the failure was definitively
      // UnauthorizedException (confirmed 401: invalid or revoked refresh token).
      // For transient failures (network, timeout, 5xx), credentials are preserved.
      return null;
    }

    // 4. Access token was invalid (401) and no refresh token is available
    await localDataSource.clearTokens();
    return null;
  }

  @override
  Future<void> logout() async {
    final refreshToken = await localDataSource.getRefreshToken();

    try {
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await remoteDataSource.logout(refreshToken: refreshToken);
      }
    } catch (_) {
      // Remote logout failures should never prevent local credentials from being purged
    } finally {
      await localDataSource.clearTokens();
    }
  }

  @override
  Future<String?> getAccessToken() async {
    return localDataSource.getAccessToken();
  }

  @override
  Future<bool> refreshSession() async {
    final refreshToken = await localDataSource.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    try {
      final tokenResponse = await remoteDataSource.refresh(
        refreshToken: refreshToken,
      );

      await localDataSource.saveTokens(
        accessToken: tokenResponse.accessToken,
        refreshToken: tokenResponse.refreshToken,
      );

      return true;
    } on UnauthorizedException {
      // Refresh token is expired, revoked, or invalid
      await localDataSource.clearTokens();
      return false;
    } catch (_) {
      // Temporary network or server failure; do not wipe tokens yet
      return false;
    }
  }
}
