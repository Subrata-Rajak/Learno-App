import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learno/core/network/errors/app_exception.dart';
import 'package:learno/core/network/errors/error_handler.dart';
import 'package:learno/core/network/errors/failure.dart';

void main() {
  group('ErrorHandler', () {
    final testRequestOptions = RequestOptions(path: '/test');

    test('maps connection timeout to TimeoutException and TimeoutFailure', () {
      final dioException = DioException(
        requestOptions: testRequestOptions,
        type: DioExceptionType.connectionTimeout,
      );

      final exception = ErrorHandler.handle(dioException);
      final failure = ErrorHandler.toFailure(dioException);

      expect(exception, isA<TimeoutException>());
      expect(failure, isA<TimeoutFailure>());
    });

    test('maps connection error to NetworkException and NetworkFailure', () {
      final dioException = DioException(
        requestOptions: testRequestOptions,
        type: DioExceptionType.connectionError,
      );

      final exception = ErrorHandler.handle(dioException);
      final failure = ErrorHandler.toFailure(dioException);

      expect(exception, isA<NetworkException>());
      expect(failure, isA<NetworkFailure>());
    });

    test(
      'maps 401 Unauthorized to UnauthorizedException and UnauthorizedFailure',
      () {
        final dioException = DioException(
          requestOptions: testRequestOptions,
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: testRequestOptions,
            statusCode: 401,
            data: {
              'success': false,
              'message': 'Invalid session token',
              'error': {'code': 'TOKEN_EXPIRED'},
            },
          ),
        );

        final exception = ErrorHandler.handle(dioException);
        final failure = ErrorHandler.toFailure(dioException);

        expect(exception, isA<UnauthorizedException>());
        expect(exception.message, equals('Invalid session token'));
        expect(exception.errorCode, equals('TOKEN_EXPIRED'));
        expect(failure, isA<UnauthorizedFailure>());
      },
    );

    test('maps 404 Not Found to NotFoundException and NotFoundFailure', () {
      final dioException = DioException(
        requestOptions: testRequestOptions,
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: testRequestOptions,
          statusCode: 404,
          data: {
            'success': false,
            'message': 'Topic not found',
            'error': {'code': 'RESOURCE_NOT_FOUND'},
          },
        ),
      );

      final exception = ErrorHandler.handle(dioException);
      final failure = ErrorHandler.toFailure(dioException);

      expect(exception, isA<NotFoundException>());
      expect(failure, isA<NotFoundFailure>());
    });

    test('maps 500 Server Error to ServerException and ServerFailure', () {
      final dioException = DioException(
        requestOptions: testRequestOptions,
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: testRequestOptions,
          statusCode: 500,
          data: {
            'success': false,
            'message': 'Internal database failure',
            'error': {'code': 'INTERNAL_ERROR'},
          },
        ),
      );

      final exception = ErrorHandler.handle(dioException);
      final failure = ErrorHandler.toFailure(dioException);

      expect(exception, isA<ServerException>());
      expect(failure, isA<ServerFailure>());
    });

    test(
      'maps 400 Bad Request to BadRequestException and ValidationFailure',
      () {
        final dioException = DioException(
          requestOptions: testRequestOptions,
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: testRequestOptions,
            statusCode: 400,
            data: {
              'success': false,
              'message': 'Email is invalid',
              'error': {
                'code': 'VALIDATION_ERROR',
                'details': {'field': 'email'},
              },
            },
          ),
        );

        final exception = ErrorHandler.handle(dioException);
        final failure = ErrorHandler.toFailure(dioException);

        expect(exception, isA<BadRequestException>());
        expect(exception.details, equals({'field': 'email'}));
        expect(failure, isA<ValidationFailure>());
      },
    );
  });
}
