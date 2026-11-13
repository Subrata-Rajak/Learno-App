import 'package:flutter_test/flutter_test.dart';
import 'package:learno/core/network/errors/app_exception.dart';
import 'package:learno/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:learno/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:learno/features/auth/data/models/auth_user_model.dart';
import 'package:learno/features/auth/data/models/login_response_model.dart';
import 'package:learno/features/auth/data/models/token_refresh_response_model.dart';
import 'package:learno/features/auth/data/repositories/auth_repository_impl.dart';

class FakeAuthLocalDataSource implements AuthLocalDataSource {
  String? accessToken;
  String? refreshToken;

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
  }

  @override
  Future<String?> getAccessToken() async => accessToken;

  @override
  Future<String?> getRefreshToken() async => refreshToken;

  @override
  Future<void> clearTokens() async {
    accessToken = null;
    refreshToken = null;
  }
}

class FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  LoginResponseModel? mockLoginResponse;
  AuthUserModel? mockRegisterResponse;
  TokenRefreshResponseModel? mockRefreshResponse;
  AuthUserModel? mockGetMeResponse;
  bool shouldThrowOnLogout = false;
  AppException? getMeException;
  AppException? refreshException;

  @override
  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) async {
    if (mockLoginResponse != null) return mockLoginResponse!;
    throw const BadRequestException(message: 'Invalid credentials');
  }

  @override
  Future<AuthUserModel> register({
    required String email,
    required String password,
    String? name,
  }) async {
    if (mockRegisterResponse != null) return mockRegisterResponse!;
    throw const BadRequestException(message: 'Registration failed');
  }

  @override
  Future<TokenRefreshResponseModel> refresh({
    required String refreshToken,
  }) async {
    if (refreshException != null) throw refreshException!;
    if (mockRefreshResponse != null) return mockRefreshResponse!;
    throw const UnauthorizedException(message: 'Invalid refresh token');
  }

  @override
  Future<void> logout({required String refreshToken}) async {
    if (shouldThrowOnLogout) {
      throw const ServerException(message: 'Logout failed remotely');
    }
  }

  int getMeCallCount = 0;

  @override
  Future<AuthUserModel> getMe() async {
    getMeCallCount++;
    if (getMeException != null && getMeCallCount == 1) throw getMeException!;
    if (mockGetMeResponse != null) return mockGetMeResponse!;
    throw const UnauthorizedException(message: 'Unauthorized');
  }
}

void main() {
  late FakeAuthLocalDataSource fakeLocal;
  late FakeAuthRemoteDataSource fakeRemote;
  late AuthRepositoryImpl repository;

  const testUser = AuthUserModel(
    id: 'user-123',
    email: 'alex@example.com',
    name: 'Alex Johnson',
    role: 'USER',
    status: 'ACTIVE',
  );

  setUp(() {
    fakeLocal = FakeAuthLocalDataSource();
    fakeRemote = FakeAuthRemoteDataSource();
    repository = AuthRepositoryImpl(
      remoteDataSource: fakeRemote,
      localDataSource: fakeLocal,
    );
  });

  group('AuthRepositoryImpl', () {
    test(
      'login saves tokens locally and returns authenticated domain user',
      () async {
        fakeRemote.mockLoginResponse = const LoginResponseModel(
          accessToken: 'access_123',
          refreshToken: 'refresh_123',
          user: testUser,
        );

        final result = await repository.login(
          email: 'alex@example.com',
          password: 'password123',
        );

        expect(result.id, equals('user-123'));
        expect(result.email, equals('alex@example.com'));
        expect(fakeLocal.accessToken, equals('access_123'));
        expect(fakeLocal.refreshToken, equals('refresh_123'));
      },
    );

    test(
      'register returns created domain user without setting tokens',
      () async {
        fakeRemote.mockRegisterResponse = testUser;

        final result = await repository.register(
          email: 'alex@example.com',
          password: 'password123',
          name: 'Alex Johnson',
        );

        expect(result.id, equals('user-123'));
        expect(result.name, equals('Alex Johnson'));
        expect(fakeLocal.accessToken, isNull);
        expect(fakeLocal.refreshToken, isNull);
      },
    );

    test(
      'restoreSession returns null when no tokens are stored (guest mode)',
      () async {
        final user = await repository.restoreSession();
        expect(user, isNull);
      },
    );

    test(
      'restoreSession validates and returns user when access token is valid',
      () async {
        fakeLocal.accessToken = 'valid_access_token';
        fakeRemote.mockGetMeResponse = testUser;

        final user = await repository.restoreSession();

        expect(user, equals(testUser));
        expect(fakeLocal.accessToken, equals('valid_access_token'));
      },
    );

    test(
      'restoreSession refreshes tokens when access token is expired',
      () async {
        fakeLocal.accessToken = 'expired_access_token';
        fakeLocal.refreshToken = 'valid_refresh_token';

        fakeRemote.getMeException = const UnauthorizedException();
        fakeRemote.mockRefreshResponse = const TokenRefreshResponseModel(
          accessToken: 'new_access_token',
          refreshToken: 'new_refresh_token',
        );

        // After refresh succeeds, getMe returns testUser
        fakeRemote.mockGetMeResponse = testUser;

        final user = await repository.restoreSession();

        expect(fakeLocal.accessToken, equals('new_access_token'));
        expect(fakeLocal.refreshToken, equals('new_refresh_token'));
        expect(user, equals(testUser));
      },
    );

    test(
      'restoreSession purges local tokens when refresh token has expired',
      () async {
        fakeLocal.accessToken = 'expired_access_token';
        fakeLocal.refreshToken = 'expired_refresh_token';

        fakeRemote.getMeException = const UnauthorizedException();
        fakeRemote.refreshException = const UnauthorizedException(
          errorCode: 'REFRESH_TOKEN_EXPIRED',
        );

        final user = await repository.restoreSession();

        expect(user, isNull);
        expect(fakeLocal.accessToken, isNull);
        expect(fakeLocal.refreshToken, isNull);
      },
    );

    test(
      'restoreSession preserves credentials when /auth/me encounters TimeoutException',
      () async {
        fakeLocal.accessToken = 'valid_access_token';
        fakeLocal.refreshToken = 'valid_refresh_token';

        fakeRemote.getMeException = const TimeoutException(
          message: 'Connection timed out',
        );

        final user = await repository.restoreSession();

        expect(user, isNull);
        expect(fakeLocal.accessToken, equals('valid_access_token'));
        expect(fakeLocal.refreshToken, equals('valid_refresh_token'));
      },
    );

    test(
      'restoreSession preserves credentials when /auth/me encounters ServerException (HTTP 500)',
      () async {
        fakeLocal.accessToken = 'valid_access_token';
        fakeLocal.refreshToken = 'valid_refresh_token';

        fakeRemote.getMeException = const ServerException(
          statusCode: 500,
          message: 'Internal server error',
        );

        final user = await repository.restoreSession();

        expect(user, isNull);
        expect(fakeLocal.accessToken, equals('valid_access_token'));
        expect(fakeLocal.refreshToken, equals('valid_refresh_token'));
      },
    );

    test(
      'restoreSession preserves credentials when refresh encounters TimeoutException',
      () async {
        fakeLocal.accessToken = 'expired_access_token';
        fakeLocal.refreshToken = 'stored_refresh_token';

        fakeRemote.getMeException = const UnauthorizedException();
        fakeRemote.refreshException = const TimeoutException(
          message: 'Refresh request timed out',
        );

        final user = await repository.restoreSession();

        expect(user, isNull);
        expect(fakeLocal.accessToken, equals('expired_access_token'));
        expect(fakeLocal.refreshToken, equals('stored_refresh_token'));
      },
    );

    test(
      'restoreSession preserves credentials when refresh encounters ServerException (HTTP 500)',
      () async {
        fakeLocal.accessToken = 'expired_access_token';
        fakeLocal.refreshToken = 'stored_refresh_token';

        fakeRemote.getMeException = const UnauthorizedException();
        fakeRemote.refreshException = const ServerException(
          statusCode: 500,
          message: 'Server error during refresh',
        );

        final user = await repository.restoreSession();

        expect(user, isNull);
        expect(fakeLocal.accessToken, equals('expired_access_token'));
        expect(fakeLocal.refreshToken, equals('stored_refresh_token'));
      },
    );

    test(
      'restoreSession clears credentials when refresh encounters confirmed 401 UnauthorizedException',
      () async {
        fakeLocal.accessToken = 'expired_access_token';
        fakeLocal.refreshToken = 'revoked_refresh_token';

        fakeRemote.getMeException = const UnauthorizedException();
        fakeRemote.refreshException = const UnauthorizedException(
          statusCode: 401,
          message: 'Refresh token expired or revoked',
        );

        final user = await repository.restoreSession();

        expect(user, isNull);
        expect(fakeLocal.accessToken, isNull);
        expect(fakeLocal.refreshToken, isNull);
      },
    );

    test(
      'logout clears local credentials even when remote logout fails',
      () async {
        fakeLocal.accessToken = 'token_to_clear';
        fakeLocal.refreshToken = 'refresh_to_clear';
        fakeRemote.shouldThrowOnLogout = true;

        await repository.logout();

        expect(fakeLocal.accessToken, isNull);
        expect(fakeLocal.refreshToken, isNull);
      },
    );
  });
}
