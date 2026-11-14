import 'package:equatable/equatable.dart';

/// Base exception class for data and network layer exceptions.
abstract class AppException extends Equatable implements Exception {
  const AppException({
    required this.message,
    this.statusCode,
    this.errorCode,
    this.details,
  });

  final String message;
  final int? statusCode;
  final String? errorCode;
  final dynamic details;

  @override
  List<Object?> get props => [message, statusCode, errorCode, details];

  @override
  String toString() =>
      '$runtimeType: $message (code: $errorCode, status: $statusCode)';
}

/// Occurs when device has no connectivity, DNS failure, or socket connection fails.
class NetworkException extends AppException {
  const NetworkException({
    super.message =
        'Network connection failed. Please check your internet connection.',
    super.statusCode,
    super.errorCode = 'NETWORK_ERROR',
  });
}

/// Occurs when an HTTP request or response exceeds configured timeouts.
class TimeoutException extends AppException {
  const TimeoutException({
    super.message = 'The connection timed out. Please try again.',
    super.statusCode,
    super.errorCode = 'TIMEOUT_ERROR',
  });
}

/// Occurs when the server returns a 5xx response code.
class ServerException extends AppException {
  const ServerException({
    super.message = 'A server error occurred. Please try again later.',
    super.statusCode = 500,
    super.errorCode = 'SERVER_ERROR',
    super.details,
  });
}

/// Occurs when the server returns a 401 Unauthorized response code.
class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message = 'Unauthorized access. Please log in again.',
    super.statusCode = 401,
    super.errorCode = 'UNAUTHORIZED',
    super.details,
  });
}

/// Occurs when the server returns a 404 Not Found response code.
class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'The requested resource was not found.',
    super.statusCode = 404,
    super.errorCode = 'NOT_FOUND',
    super.details,
  });
}

/// Occurs when the server returns a 400 Bad Request or validation failure.
class BadRequestException extends AppException {
  const BadRequestException({
    super.message = 'Invalid request parameters.',
    super.statusCode = 400,
    super.errorCode = 'BAD_REQUEST',
    super.details,
  });
}

/// Occurs when an ongoing request or stream is explicitly cancelled by the caller.
class CancellationException extends AppException {
  const CancellationException({
    super.message = 'The operation was cancelled.',
    super.errorCode = 'REQUEST_CANCELLED',
    super.details,
  });
}

/// Occurs on unanticipated client errors, parsing bugs, or untyped exceptions.
class UnexpectedException extends AppException {
  const UnexpectedException({
    super.message = 'An unexpected error occurred.',
    super.statusCode,
    super.errorCode = 'UNEXPECTED_ERROR',
    super.details,
  });
}
