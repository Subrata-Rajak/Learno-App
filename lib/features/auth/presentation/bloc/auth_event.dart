import 'package:equatable/equatable.dart';

/// Base event class for [AuthBloc].
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched on application launch to restore an existing session.
final class AuthRestoreRequested extends AuthEvent {
  const AuthRestoreRequested();
}

/// Dispatched when a user submits their login credentials.
final class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

/// Dispatched when a user submits registration information.
final class AuthRegisterRequested extends AuthEvent {
  const AuthRegisterRequested({
    required this.email,
    required this.password,
    this.name,
  });

  final String email;
  final String password;
  final String? name;

  @override
  List<Object?> get props => [email, password, name];
}

/// Dispatched when a user requests to log out.
final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
