import 'package:flutter_test/flutter_test.dart';
import 'package:learno/core/network/errors/app_exception.dart';
import 'package:learno/features/auth/domain/entities/auth_user.dart';
import 'package:learno/features/auth/domain/repositories/auth_repository.dart';
import 'package:learno/features/auth/domain/usecases/login.dart';
import 'package:learno/features/auth/domain/usecases/logout.dart';
import 'package:learno/features/auth/domain/usecases/register.dart';
import 'package:learno/features/auth/domain/usecases/restore_session.dart';
import 'package:learno/features/auth/presentation/bloc/auth_bloc.dart';

class MockAuthRepository implements AuthRepository {
  AuthUser? mockUser;
  bool shouldThrowLogin = false;
  bool shouldThrowRegister = false;
  AppException? customException;

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    if (shouldThrowLogin) {
      throw customException ??
          const UnauthorizedException(
            message: 'Invalid email or password',
            errorCode: 'INVALID_CREDENTIALS',
          );
    }
    return mockUser!;
  }

  @override
  Future<AuthUser> register({
    required String email,
    required String password,
    String? name,
  }) async {
    if (shouldThrowRegister) {
      throw customException ??
          const BadRequestException(
            message: 'Email already exists',
            errorCode: 'EMAIL_ALREADY_EXISTS',
          );
    }
    return mockUser!;
  }

  @override
  Future<AuthUser?> restoreSession() async => mockUser;

  @override
  Future<void> logout() async {
    mockUser = null;
  }

  @override
  Future<String?> getAccessToken() async => 'mock_token';

  @override
  Future<bool> refreshSession() async => true;
}

void main() {
  late MockAuthRepository mockRepo;
  late AuthBloc authBloc;

  const testUser = AuthUser(
    id: 'user-456',
    email: 'sarah@example.com',
    name: 'Sarah Connor',
    role: 'USER',
    status: 'ACTIVE',
  );

  setUp(() {
    mockRepo = MockAuthRepository();
    authBloc = AuthBloc(
      login: Login(mockRepo),
      register: Register(mockRepo),
      restoreSession: RestoreSession(mockRepo),
      logout: Logout(mockRepo),
    );
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc', () {
    test('initial state is AuthInitial', () {
      expect(authBloc.state, equals(const AuthInitial()));
    });

    test(
      'emits AuthUnauthenticated when restoreSession finds no credentials',
      () async {
        mockRepo.mockUser = null;

        final expectedStates = [const AuthUnauthenticated()];

        expectLater(authBloc.stream, emitsInOrder(expectedStates));

        authBloc.add(const AuthRestoreRequested());
      },
    );

    test('emits AuthAuthenticated when restoreSession succeeds', () async {
      mockRepo.mockUser = testUser;

      final expectedStates = [const AuthAuthenticated(user: testUser)];

      expectLater(authBloc.stream, emitsInOrder(expectedStates));

      authBloc.add(const AuthRestoreRequested());
    });

    test(
      'emits [AuthLoading, AuthAuthenticated] upon successful login',
      () async {
        mockRepo.mockUser = testUser;

        final expectedStates = [
          isA<AuthLoading>(),
          const AuthAuthenticated(user: testUser),
        ];

        expectLater(authBloc.stream, emitsInOrder(expectedStates));

        authBloc.add(
          const AuthLoginRequested(
            email: 'sarah@example.com',
            password: 'secretPassword',
          ),
        );
      },
    );

    test('emits [AuthLoading, AuthFailure] upon failed login', () async {
      mockRepo.shouldThrowLogin = true;

      final expectedStates = [
        isA<AuthLoading>(),
        predicate<AuthState>((state) {
          return state is AuthFailure &&
              state.message == 'Invalid email or password' &&
              state.code == 'INVALID_CREDENTIALS';
        }),
      ];

      expectLater(authBloc.stream, emitsInOrder(expectedStates));

      authBloc.add(
        const AuthLoginRequested(
          email: 'sarah@example.com',
          password: 'wrongPassword',
        ),
      );
    });

    test(
      'emits [AuthLoading, AuthRegistrationSuccess] upon successful register',
      () async {
        mockRepo.mockUser = testUser;

        final expectedStates = [
          isA<AuthLoading>(),
          const AuthRegistrationSuccess(user: testUser),
        ];

        expectLater(authBloc.stream, emitsInOrder(expectedStates));

        authBloc.add(
          const AuthRegisterRequested(
            email: 'sarah@example.com',
            password: 'newPassword123',
            name: 'Sarah Connor',
          ),
        );
      },
    );

    test('emits AuthUnauthenticated upon logout', () async {
      mockRepo.mockUser = testUser;

      final expectedStates = [const AuthUnauthenticated()];

      expectLater(authBloc.stream, emitsInOrder(expectedStates));

      authBloc.add(const AuthLogoutRequested());
    });
  });
}
