import 'package:equatable/equatable.dart';

/// Pure domain-level failure abstraction.
///
/// Domain models and use cases communicate error states through Failures,
/// keeping business logic free from network client or protocol dependencies.
abstract class Failure extends Equatable {
  const Failure({required this.message, this.code});

  /// User-friendly, localized or contextual error message.
  final String message;

  /// Optional machine-readable failure identifier.
  final String? code;

  @override
  List<Object?> get props => [message, code];

  @override
  String toString() => '$runtimeType: $message (code: $code)';
}

/// Domain failure representing loss of network connectivity.
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Unable to connect. Please check your internet connection.',
    super.code = 'NETWORK_FAILURE',
  });
}

/// Domain failure representing connection or response timeout.
class TimeoutFailure extends Failure {
  const TimeoutFailure({
    super.message = 'Connection timed out. Please try again.',
    super.code = 'TIMEOUT_FAILURE',
  });
}

/// Domain failure representing remote server errors (5xx).
class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'Server error occurred. Please try again later.',
    super.code = 'SERVER_FAILURE',
  });
}

/// Domain failure representing unauthorized access or expired authentication.
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    super.message = 'Session expired or unauthorized. Please sign in again.',
    super.code = 'UNAUTHORIZED_FAILURE',
  });
}

/// Domain failure representing requested resource nonexistence (404).
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'The requested resource was not found.',
    super.code = 'NOT_FOUND_FAILURE',
  });
}

/// Domain failure representing invalid user input or client validation errors.
class ValidationFailure extends Failure {
  const ValidationFailure({
    super.message = 'Invalid request. Please check your input.',
    super.code = 'VALIDATION_FAILURE',
  });
}

/// Domain failure representing a cancelled operation.
class CancellationFailure extends Failure {
  const CancellationFailure({
    super.message = 'The operation was cancelled.',
    super.code = 'REQUEST_CANCELLED',
  });
}

/// Domain failure for unclassified or unexpected exceptions.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    super.message = 'An unexpected error occurred. Please try again.',
    super.code = 'UNEXPECTED_FAILURE',
  });
}
