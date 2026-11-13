import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:learno/app/router/app_router.dart';
import 'package:learno/app/router/app_routes.dart';
import 'package:learno/app/router/auth_refresh_listenable.dart';
import 'package:learno/core/di/injection.dart';
import 'package:learno/core/theme/theme.dart';
import 'package:learno/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:learno/features/home/presentation/bloc/home_bloc.dart';

/// Root application widget for Learno.
///
/// Sets up the light-only Material 3 theme, provides root [AuthBloc] with background
/// session restoration, and establishes GoRouter navigation with StatefulShellRoute.
class LearnoApp extends StatefulWidget {
  const LearnoApp({
    super.key,
    this.authBloc,
    this.homeBloc,
    this.initialLocation,
  });

  final AuthBloc? authBloc;
  final HomeBloc? homeBloc;
  final String? initialLocation;

  @override
  State<LearnoApp> createState() => _LearnoAppState();
}

class _LearnoAppState extends State<LearnoApp> {
  late final AuthBloc _authBloc;
  late final bool _isExternalAuthBloc;
  late final AuthRefreshListenable _authRefreshListenable;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    if (widget.authBloc != null) {
      _authBloc = widget.authBloc!;
      _isExternalAuthBloc = true;
    } else {
      _authBloc = getIt<AuthBloc>();
      _isExternalAuthBloc = false;
    }

    if (_authBloc.state is AuthInitial) {
      _authBloc.add(const AuthRestoreRequested());
    }

    _authRefreshListenable = AuthRefreshListenable(_authBloc);

    _router = createAppRouter(
      authBloc: _authBloc,
      authRefreshListenable: _authRefreshListenable,
      homeBloc: widget.homeBloc,
      initialLocation: widget.initialLocation ?? AppRoutes.homePath,
    );
  }

  @override
  void dispose() {
    _router.dispose();
    _authRefreshListenable.dispose();
    if (!_isExternalAuthBloc) {
      _authBloc.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>.value(
      value: _authBloc,
      child: MaterialApp.router(
        title: 'Learno',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: _router,
      ),
    );
  }
}
