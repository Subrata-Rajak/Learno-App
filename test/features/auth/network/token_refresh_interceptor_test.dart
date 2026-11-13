import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learno/core/network/interceptors/token_refresh_interceptor.dart';

class FakeErrorInterceptorHandler extends Fake
    implements ErrorInterceptorHandler {
  DioException? nextError;
  Response? resolvedResponse;

  @override
  void next(DioException err) {
    nextError = err;
  }

  @override
  void resolve(Response response) {
    resolvedResponse = response;
  }
}

void main() {
  group('TokenRefreshInterceptor', () {
    late Dio dio;
    int refreshCallCount = 0;
    bool refreshReturnValue = true;
    String currentToken = 'initial_access_token';
    bool sessionExpiredTriggered = false;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000'));
      refreshCallCount = 0;
      refreshReturnValue = true;
      currentToken = 'initial_access_token';
      sessionExpiredTriggered = false;
    });

    TokenRefreshInterceptor createInterceptor({Dio? customDio}) {
      return TokenRefreshInterceptor(
        onRefresh: () async {
          refreshCallCount++;
          if (refreshReturnValue) {
            currentToken = 'rotated_access_token';
            return true;
          }
          return false;
        },
        tokenGetter: () async => currentToken,
        dio: customDio ?? dio,
        onSessionExpired: () {
          sessionExpiredTriggered = true;
        },
      );
    }

    test('ignores non-401 errors and passes them along', () async {
      final interceptor = createInterceptor();
      final options = RequestOptions(path: '/api/v1/roadmap');
      final dioException = DioException(
        requestOptions: options,
        response: Response(requestOptions: options, statusCode: 500),
      );

      final handler = FakeErrorInterceptorHandler();
      await interceptor.onError(dioException, handler);

      expect(refreshCallCount, equals(0));
      expect(handler.nextError, equals(dioException));
    });

    test(
      'does not attempt refresh for authentication endpoints (prevents recursion)',
      () async {
        final interceptor = createInterceptor();
        final options = RequestOptions(path: '/api/v1/auth/refresh');
        final dioException = DioException(
          requestOptions: options,
          response: Response(requestOptions: options, statusCode: 401),
        );

        final handler = FakeErrorInterceptorHandler();
        await interceptor.onError(dioException, handler);

        expect(refreshCallCount, equals(0));
        expect(handler.nextError, equals(dioException));
      },
    );

    test(
      'does not retry a request that has already been retried once',
      () async {
        final interceptor = createInterceptor();
        final options = RequestOptions(
          path: '/api/v1/roadmap',
          extra: {'learno_is_retry_request': true},
        );
        final dioException = DioException(
          requestOptions: options,
          response: Response(requestOptions: options, statusCode: 401),
        );

        final handler = FakeErrorInterceptorHandler();
        await interceptor.onError(dioException, handler);

        expect(refreshCallCount, equals(0));
        expect(handler.nextError, equals(dioException));
      },
    );

    test('triggers onSessionExpired when token refresh fails', () async {
      refreshReturnValue = false;
      final interceptor = createInterceptor();
      final options = RequestOptions(path: '/api/v1/roadmap');
      final dioException = DioException(
        requestOptions: options,
        response: Response(requestOptions: options, statusCode: 401),
      );

      final handler = FakeErrorInterceptorHandler();
      await interceptor.onError(dioException, handler);

      expect(refreshCallCount, equals(1));
      expect(sessionExpiredTriggered, isTrue);
      expect(handler.nextError, equals(dioException));
    });

    test(
      'coordinates single refresh operation across concurrent 401 responses',
      () async {
        final refreshCompleter = Completer<void>();
        int slowRefreshCount = 0;

        final interceptor = TokenRefreshInterceptor(
          onRefresh: () async {
            slowRefreshCount++;
            await refreshCompleter.future;
            currentToken = 'synchronized_token';
            return true;
          },
          tokenGetter: () async => currentToken,
          dio: dio,
        );

        final opt1 = RequestOptions(path: '/api/v1/goal/1');
        final opt2 = RequestOptions(path: '/api/v1/goal/2');

        final err1 = DioException(
          requestOptions: opt1,
          response: Response(requestOptions: opt1, statusCode: 401),
        );
        final err2 = DioException(
          requestOptions: opt2,
          response: Response(requestOptions: opt2, statusCode: 401),
        );

        final handler1 = FakeErrorInterceptorHandler();
        final handler2 = FakeErrorInterceptorHandler();

        // Launch both concurrently
        final future1 = interceptor.onError(err1, handler1);
        final future2 = interceptor.onError(err2, handler2);

        // Let both register while refresh is still in-flight
        expect(slowRefreshCount, equals(1));

        // Complete the single refresh
        refreshCompleter.complete();

        await Future.wait([
          future1.catchError((_) {}),
          future2.catchError((_) {}),
        ]);

        // Exactly ONE refresh operation was executed for both concurrent 401s
        expect(slowRefreshCount, equals(1));
      },
    );
  });
}
