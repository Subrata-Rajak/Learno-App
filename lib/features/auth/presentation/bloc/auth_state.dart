import 'package:equatable/equatable.dart';
import 'package:learno/features/auth/domain/entities/auth_user.dart';

/// Base state class for [AuthBloc].
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial resting state while verifying or restoring persisted session.
final class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Unauthenticated / Guest state.
///
/// Learno operates in a guest-first model: the user can explore Home and mock tracks
/// without being forced to authenticate.
final class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// State emitted while an authentication operation (login/register) is executing.
final class AuthLoading extends AuthState {
  const AuthLoading({this.message});

  final String? message;

  @override
  List<Object?> get props => [message];
}

/// State emitted when the user is successfully authenticated.
final class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({required this.user});

  final AuthUser user;

  @override
  List<Object?> get props => [user];
}

/// State emitted when registration succeeds.
///
/// According to the Learno backend contract, registration creates the account
/// without issuing tokens, requiring the user to sign in.
final class AuthRegistrationSuccess extends AuthState {
  const AuthRegistrationSuccess({
    required this.user,
    this.message = 'Account created successfully! Please sign in.',
  });

  final AuthUser user;
  final String message;

  @override
  List<Object?> get props => [user, message];
}

/// State emitted when an authentication request fails.
final class AuthFailure extends AuthState {
  const AuthFailure({required this.message, this.code});

  final String message;
  final String? code;

  @override
  List<Object?> get props => [message, code];
}
