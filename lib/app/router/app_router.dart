import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learno/app/router/app_routes.dart';
import 'package:learno/app/router/app_shell.dart';
import 'package:learno/app/router/auth_refresh_listenable.dart';
import 'package:learno/features/ask_learno/presentation/screens/ask_learno_screen.dart';
import 'package:learno/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:learno/features/auth/presentation/screens/login_screen.dart';
import 'package:learno/features/auth/presentation/screens/register_screen.dart';
import 'package:learno/features/home/presentation/bloc/home_bloc.dart';
import 'package:learno/features/home/presentation/screens/home_screen.dart';
import 'package:learno/features/my_learning/presentation/screens/my_learning_screen.dart';
import 'package:learno/features/profile/presentation/screens/profile_screen.dart';
import 'package:learno/features/progress/presentation/screens/progress_screen.dart';
import 'package:learno/features/protected_sample/presentation/screens/protected_sample_screen.dart';

/// Global root navigator key for full-screen dialogs and auth routes.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'rootNavigator',
);

/// Factory for configuring the application [GoRouter].
GoRouter createAppRouter({
  required AuthBloc authBloc,
  required AuthRefreshListenable authRefreshListenable,
  HomeBloc? homeBloc,
  String initialLocation = AppRoutes.homePath,
}) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLocation,
    refreshListenable: authRefreshListenable,
    redirect: (context, state) {
      final authState = authBloc.state;
      final matchedLocation = state.matchedLocation;
      final isProtected = AppRoutes.isProtectedPath(matchedLocation);
      final isAuthRoute =
          matchedLocation == AppRoutes.loginPath ||
          matchedLocation == AppRoutes.registerPath;

      // 1. During active auth operations, never disrupt navigation
      if (authState is AuthLoading) {
        return null;
      }

      // 2. If authenticated, redirect away from login/register
      if (authState is AuthAuthenticated) {
        if (isAuthRoute) {
          final from = state.uri.queryParameters[AppRoutes.redirectParam];
          final safeTarget = AppRoutes.sanitizeRedirectPath(from);
          return safeTarget ?? AppRoutes.homePath;
        }
        return null;
      }

      // 3. If unauthenticated, redirect from protected destinations to login
      if (isProtected) {
        final safeFrom = AppRoutes.sanitizeRedirectPath(matchedLocation);
        if (safeFrom != null) {
          return '${AppRoutes.loginPath}?${AppRoutes.redirectParam}=${Uri.encodeComponent(safeFrom)}';
        }
        return AppRoutes.loginPath;
      }

      // 4. All other destinations (Home, Ask Learno, My Learning, Progress, Profile, Login, Register) are accessible
      return null;
    },
    routes: [
      // 1. Primary Stateful Navigation Shell (5 branches)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.homePath,
                name: AppRoutes.homeName,
                builder: (context, state) => HomeScreen(homeBloc: homeBloc),
              ),
            ],
          ),

          // Branch 1: My Learning
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.myLearningPath,
                name: AppRoutes.myLearningName,
                builder: (context, state) => const MyLearningScreen(),
              ),
            ],
          ),

          // Branch 2: Ask Learno (Prominent Central Action)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.askLearnoPath,
                name: AppRoutes.askLearnoName,
                builder: (context, state) => const AskLearnoScreen(),
              ),
            ],
          ),

          // Branch 3: Progress
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.progressPath,
                name: AppRoutes.progressName,
                builder: (context, state) => const ProgressScreen(),
              ),
            ],
          ),

          // Branch 4: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profilePath,
                name: AppRoutes.profileName,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // 2. Full-Screen Auth Routes (Outside Shell)
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.loginPath,
        name: AppRoutes.loginName,
        builder: (context, state) {
          final redirectTo = state.uri.queryParameters[AppRoutes.redirectParam];
          return LoginScreen(redirectTo: redirectTo);
        },
      ),

      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.registerPath,
        name: AppRoutes.registerName,
        builder: (context, state) => const RegisterScreen(),
      ),

      // 3. Test Protected Route (Outside Shell)
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRoutes.protectedSamplePath,
        name: AppRoutes.protectedSampleName,
        builder: (context, state) => const ProtectedSampleScreen(),
      ),
    ],
  );
}
