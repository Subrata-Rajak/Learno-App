import 'dart:io';
import 'package:dio/dio.dart';
import 'package:learno/core/network/errors/app_exception.dart';
import 'package:learno/core/network/errors/failure.dart';

/// Centralized mapper converting raw network exceptions into typed exceptions and domain failures.
abstract final class ErrorHandler {
  /// Converts a [DioException] or generic object into an [AppException].
  static AppException handle(Object error) {
    if (error is AppException) {
      return error;
    }

    if (error is DioException) {
      return _handleDioException(error);
    }

    if (error is SocketException) {
      return const NetworkException();
    }

    return UnexpectedException(message: error.toString(), details: error);
  }

  /// Converts an [AppException] or generic error into a domain [Failure].
  static Failure toFailure(Object error) {
    final appException = handle(error);

    return switch (appException) {
      NetworkException(:final message, :final errorCode) => NetworkFailure(
        message: message,
        code: errorCode,
      ),
      TimeoutException(:final message, :final errorCode) => TimeoutFailure(
        message: message,
        code: errorCode,
      ),
      ServerException(:final message, :final errorCode) => ServerFailure(
        message: message,
        code: errorCode,
      ),
      UnauthorizedException(:final message, :final errorCode) =>
        UnauthorizedFailure(message: message, code: errorCode),
      NotFoundException(:final message, :final errorCode) => NotFoundFailure(
        message: message,
        code: errorCode,
      ),
      BadRequestException(:final message, :final errorCode) =>
        ValidationFailure(message: message, code: errorCode),
      CancellationException(:final message, :final errorCode) =>
        CancellationFailure(message: message, code: errorCode),
      UnexpectedException(:final message, :final errorCode) =>
        UnexpectedFailure(message: message, code: errorCode),
      _ => UnexpectedFailure(message: appException.message),
    };
  }

  static AppException _handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return TimeoutException(
          message: 'Connection timed out. Please try again.',
          statusCode: error.response?.statusCode,
        );

      case DioExceptionType.connectionError:
        return const NetworkException();

      case DioExceptionType.badCertificate:
        return const NetworkException(
          message: 'Security certificate verification failed.',
          errorCode: 'BAD_CERTIFICATE',
        );

      case DioExceptionType.cancel:
        return const CancellationException(
          message: 'The request was cancelled.',
        );

      case DioExceptionType.badResponse:
        return _handleBadResponse(error);

      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return const NetworkException();
        }
        return UnexpectedException(
          message: error.message ?? 'An unexpected network error occurred.',
          details: error.error,
        );
    }
  }

  static AppException _handleBadResponse(DioException error) {
    final response = error.response;
    final statusCode = response?.statusCode ?? 500;
    final responseData = response?.data;

    String? serverMessage;
    String? serverErrorCode;
    dynamic details;

    if (responseData is Map<String, dynamic>) {
      serverMessage = responseData['message'] as String?;
      final errorField = responseData['error'];
      if (errorField is Map<String, dynamic>) {
        serverErrorCode = errorField['code'] as String?;
        details = errorField['details'];
      }
    }

    final message = serverMessage ?? 'Request failed with status $statusCode.';

    return switch (statusCode) {
      400 => BadRequestException(
        message: message,
        statusCode: 400,
        errorCode: serverErrorCode ?? 'BAD_REQUEST',
        details: details,
      ),
      401 => UnauthorizedException(
        message: message,
        statusCode: 401,
        errorCode: serverErrorCode ?? 'UNAUTHORIZED',
        details: details,
      ),
      403 => UnauthorizedException(
        message: message,
        statusCode: 403,
        errorCode: serverErrorCode ?? 'FORBIDDEN',
        details: details,
      ),
      404 => NotFoundException(
        message: message,
        statusCode: 404,
        errorCode: serverErrorCode ?? 'NOT_FOUND',
        details: details,
      ),
      >= 500 && < 600 => ServerException(
        message: message,
        statusCode: statusCode,
        errorCode: serverErrorCode ?? 'SERVER_ERROR',
        details: details,
      ),
      _ => UnexpectedException(
        message: message,
        statusCode: statusCode,
        errorCode: serverErrorCode ?? 'HTTP_$statusCode',
        details: details,
      ),
    };
  }
}
