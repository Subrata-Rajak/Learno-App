import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learno/core/network/errors/app_exception.dart';
import 'package:learno/features/auth/domain/usecases/login.dart';
import 'package:learno/features/auth/domain/usecases/logout.dart';
import 'package:learno/features/auth/domain/usecases/register.dart';
import 'package:learno/features/auth/domain/usecases/restore_session.dart';
import 'package:learno/features/auth/presentation/bloc/auth_event.dart';
import 'package:learno/features/auth/presentation/bloc/auth_state.dart';

export 'auth_event.dart';
export 'auth_state.dart';

/// Presentation state coordinator for Learno authentication and session management.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required this.login,
    required this.register,
    required this.restoreSession,
    required this.logout,
  }) : super(const AuthInitial()) {
    on<AuthRestoreRequested>(_onRestoreRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  final Login login;
  final Register register;
  final RestoreSession restoreSession;
  final Logout logout;

  Future<void> _onRestoreRequested(
    AuthRestoreRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final user = await restoreSession();
      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } catch (_) {
      // Any restoration issue gracefully defaults to guest mode
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Signing in...'));
    try {
      final user = await login(email: event.email, password: event.password);
      emit(AuthAuthenticated(user: user));
    } on AppException catch (e) {
      emit(AuthFailure(message: e.message, code: e.errorCode));
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Creating account...'));
    try {
      final user = await register(
        email: event.email,
        password: event.password,
        name: event.name,
      );
      emit(AuthRegistrationSuccess(user: user));
    } on AppException catch (e) {
      emit(AuthFailure(message: e.message, code: e.errorCode));
    } catch (e) {
      emit(AuthFailure(message: e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await logout();
    } finally {
      emit(const AuthUnauthenticated());
    }
  }
}
