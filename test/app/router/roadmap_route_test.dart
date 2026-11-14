import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:learno/app/router/app_router.dart';
import 'package:learno/app/router/app_routes.dart';
import 'package:learno/app/router/auth_refresh_listenable.dart';
import 'package:learno/core/di/injection.dart';
import 'package:learno/features/auth/domain/entities/auth_user.dart';
import 'package:learno/features/auth/domain/repositories/auth_repository.dart';
import 'package:learno/features/auth/domain/usecases/login.dart';
import 'package:learno/features/auth/domain/usecases/logout.dart';
import 'package:learno/features/auth/domain/usecases/register.dart';
import 'package:learno/features/auth/domain/usecases/restore_session.dart';
import 'package:learno/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:learno/features/roadmap/presentation/screens/roadmap_detail_screen.dart';

class FakeAuthRepository implements AuthRepository {
  @override
  Future<AuthUser> login({required String email, required String password}) =>
      throw UnimplementedError();

  @override
  Future<AuthUser> register({
    required String email,
    required String password,
    String? name,
  }) =>
      throw UnimplementedError();

  @override
  Future<AuthUser?> restoreSession() async => const AuthUser(
        id: 'u1',
        email: 'user@learno.app',
        role: 'USER',
        status: 'ACTIVE',
      );

  @override
  Future<void> logout() async {}

  @override
  Future<bool> refreshSession() async => true;

  @override
  Future<String?> getAccessToken() async => 'token';
}

void main() {
  group('Roadmap Route Navigation', () {
    late FakeAuthRepository authRepository;
    late AuthBloc authBloc;
    late AuthRefreshListenable listenable;
    late GoRouter router;

    setUp(() async {
      await resetDependencies();
      await configureDependencies();

      authRepository = FakeAuthRepository();
      authBloc = AuthBloc(
        login: Login(authRepository),
        register: Register(authRepository),
        restoreSession: RestoreSession(authRepository),
        logout: Logout(authRepository),
      );
      authBloc.emit(
        const AuthAuthenticated(
          user: AuthUser(
            id: 'u1',
            email: 'user@learno.app',
            role: 'USER',
            status: 'ACTIVE',
          ),
        ),
      );

      listenable = AuthRefreshListenable(authBloc);
      router = createAppRouter(
        authBloc: authBloc,
        authRefreshListenable: listenable,
        initialLocation: AppRoutes.homePath,
      );
    });

    tearDown(() async {
      listenable.dispose();
      authBloc.close();
      await resetDependencies();
    });

    testWidgets('navigating to /roadmap/:roadmapId mounts RoadmapDetailScreen with path parameter', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      // Push roadmap route
      router.push(AppRoutes.roadmapDetail('rm-test-456'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      final detailFinder = find.byType(RoadmapDetailScreen);
      expect(detailFinder, findsOneWidget);

      final screen = tester.widget<RoadmapDetailScreen>(detailFinder);
      expect(screen.roadmapId, equals('rm-test-456'));
      expect(find.text('Learning Roadmap'), findsOneWidget);

      // Verify back navigation
      await tester.tap(find.byTooltip('Back'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(RoadmapDetailScreen), findsNothing);
    });
  });
}
