import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learno/app/learno_app.dart';
import 'package:learno/app/router/app_routes.dart';
import 'package:learno/core/di/injection.dart';
import 'package:learno/features/auth/domain/entities/auth_user.dart';
import 'package:learno/features/auth/domain/repositories/auth_repository.dart';
import 'package:learno/features/auth/domain/usecases/login.dart';
import 'package:learno/features/auth/domain/usecases/logout.dart';
import 'package:learno/features/auth/domain/usecases/register.dart';
import 'package:learno/features/auth/domain/usecases/restore_session.dart';
import 'package:learno/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:learno/features/auth/presentation/screens/login_screen.dart';
import 'package:learno/features/auth/presentation/screens/register_screen.dart';
import 'package:learno/features/home/presentation/screens/home_screen.dart';
import 'package:learno/features/protected_sample/presentation/screens/protected_sample_screen.dart';

class TestAuthRepository implements AuthRepository {
  AuthUser? currentUser;

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    return currentUser ??
        const AuthUser(
          id: 'test-user',
          email: 'test@example.com',
          name: 'Test User',
          role: 'USER',
          status: 'ACTIVE',
        );
  }

  @override
  Future<AuthUser> register({
    required String email,
    required String password,
    String? name,
  }) async {
    return const AuthUser(
      id: 'test-user',
      email: 'test@example.com',
      name: 'Test User',
      role: 'USER',
      status: 'ACTIVE',
    );
  }

  @override
  Future<AuthUser?> restoreSession() async => currentUser;

  @override
  Future<void> logout() async {
    currentUser = null;
  }

  @override
  Future<String?> getAccessToken() async =>
      currentUser != null ? 'test_token' : null;

  @override
  Future<bool> refreshSession() async => true;
}

void main() {
  late TestAuthRepository testRepo;
  late AuthBloc authBloc;

  const testUser = AuthUser(
    id: 'user-789',
    email: 'learner@example.com',
    name: 'Ada Lovelace',
    role: 'USER',
    status: 'ACTIVE',
  );

  setUp(() async {
    await resetDependencies();
    await configureDependencies();

    testRepo = TestAuthRepository();
    authBloc = AuthBloc(
      login: Login(testRepo),
      register: Register(testRepo),
      restoreSession: RestoreSession(testRepo),
      logout: Logout(testRepo),
    );
  });

  tearDown(() async {
    await authBloc.close();
    await resetDependencies();
  });

  group('Authentication-Aware Routing', () {
    testWidgets(
      'guest can freely access public destinations (Home, Login, Register)',
      (WidgetTester tester) async {
        await tester.pumpWidget(LearnoApp(authBloc: authBloc));
        await tester.pumpAndSettle();

        expect(find.byType(HomeScreen), findsOneWidget);

        // Open Login
        await tester.tap(find.text('Profile'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Sign in'));
        await tester.pumpAndSettle();
        expect(find.byType(LoginScreen), findsOneWidget);

        // Navigate to Register
        await tester.tap(find.text('Create account'));
        await tester.pumpAndSettle();
        expect(find.byType(RegisterScreen), findsOneWidget);

        // Go back to Login
        await tester.tap(find.text('Sign in'));
        await tester.pumpAndSettle();
        expect(find.byType(LoginScreen), findsOneWidget);

        // Close Login to return to shell
        await tester.tap(find.byIcon(Icons.close_rounded));
        await tester.pumpAndSettle();
        expect(
          find.byType(HomeScreen),
          findsNothing,
        ); // We were on Profile branch
      },
    );

    testWidgets(
      'guest attempting to access protected route is redirected to Login with from query param',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          LearnoApp(
            authBloc: authBloc,
            initialLocation: AppRoutes.protectedSamplePath,
          ),
        );
        await tester.pumpAndSettle();

        // Redirected to LoginScreen
        expect(find.byType(LoginScreen), findsOneWidget);
        expect(find.byType(ProtectedSampleScreen), findsNothing);
      },
    );

    testWidgets(
      'authenticated user can access protected destination directly',
      (WidgetTester tester) async {
        testRepo.currentUser = testUser;

        await tester.runAsync(() async {
          authBloc.add(
            const AuthLoginRequested(
              email: 'learner@example.com',
              password: 'Password123!',
            ),
          );
          await authBloc.stream.firstWhere((s) => s is AuthAuthenticated);
        });

        await tester.pumpWidget(
          LearnoApp(
            authBloc: authBloc,
            initialLocation: AppRoutes.protectedSamplePath,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(ProtectedSampleScreen), findsOneWidget);
        expect(find.text('Welcome, Ada Lovelace!'), findsOneWidget);
      },
    );

    testWidgets('authenticated user visiting login is redirected to Home', (
      WidgetTester tester,
    ) async {
      testRepo.currentUser = testUser;

      await tester.runAsync(() async {
        authBloc.add(
          const AuthLoginRequested(
            email: 'learner@example.com',
            password: 'Password123!',
          ),
        );
        await authBloc.stream.firstWhere((s) => s is AuthAuthenticated);
      });

      await tester.pumpWidget(
        LearnoApp(authBloc: authBloc, initialLocation: AppRoutes.loginPath),
      );
      await tester.pumpAndSettle();

      // Redirected to Home
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
    });

    testWidgets(
      'successful login returns user to requested protected destination',
      (WidgetTester tester) async {
        testRepo.currentUser = testUser;

        await tester.pumpWidget(
          LearnoApp(
            authBloc: authBloc,
            initialLocation:
                '${AppRoutes.loginPath}?${AppRoutes.redirectParam}=%2Fprotected-sample',
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(LoginScreen), findsOneWidget);

        // Enter valid credentials and submit
        await tester.enterText(
          find.byType(TextFormField).at(0),
          'learner@example.com',
        );
        await tester.enterText(
          find.byType(TextFormField).at(1),
          'Password123!',
        );
        await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
        await tester.runAsync(() async {
          await authBloc.stream.firstWhere((s) => s is AuthAuthenticated);
        });
        await tester.pumpAndSettle();

        // Successfully redirected to the protected sample destination
        expect(find.byType(ProtectedSampleScreen), findsOneWidget);
        expect(find.text('Welcome, Ada Lovelace!'), findsOneWidget);
      },
    );

    testWidgets(
      'invalid redirect values (e.g. external evil URL) are rejected safely',
      (WidgetTester tester) async {
        testRepo.currentUser = testUser;

        await tester.pumpWidget(
          LearnoApp(
            authBloc: authBloc,
            initialLocation:
                '${AppRoutes.loginPath}?${AppRoutes.redirectParam}=https%3A%2F%2Fevil.com',
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(LoginScreen), findsOneWidget);

        await tester.enterText(
          find.byType(TextFormField).at(0),
          'learner@example.com',
        );
        await tester.enterText(
          find.byType(TextFormField).at(1),
          'Password123!',
        );
        await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
        await tester.runAsync(() async {
          await authBloc.stream.firstWhere((s) => s is AuthAuthenticated);
        });
        await tester.pumpAndSettle();

        // Must default back to Home, not evil.com
        expect(find.byType(HomeScreen), findsOneWidget);
      },
    );

    testWidgets(
      'logging out from a protected destination returns user to a public route',
      (WidgetTester tester) async {
        testRepo.currentUser = testUser;

        await tester.runAsync(() async {
          authBloc.add(
            const AuthLoginRequested(
              email: 'learner@example.com',
              password: 'Password123!',
            ),
          );
          await authBloc.stream.firstWhere((s) => s is AuthAuthenticated);
        });

        await tester.pumpWidget(
          LearnoApp(
            authBloc: authBloc,
            initialLocation: AppRoutes.protectedSamplePath,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(ProtectedSampleScreen), findsOneWidget);

        // Tap log out button inside protected screen
        await tester.tap(find.text('Log out and verify redirect'));
        await tester.runAsync(() async {
          await authBloc.stream.firstWhere((s) => s is AuthUnauthenticated);
        });
        await tester.pumpAndSettle();

        // User should not remain on the protected route; redirected to login
        expect(find.byType(ProtectedSampleScreen), findsNothing);
        expect(find.byType(LoginScreen), findsOneWidget);
      },
    );
  });
}
