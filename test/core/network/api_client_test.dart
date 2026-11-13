import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learno/core/config/app_config.dart';
import 'package:learno/core/network/api_client.dart';
import 'package:learno/core/network/interceptors/auth_header_interceptor.dart';
import 'package:learno/core/network/interceptors/logging_interceptor.dart';

void main() {
  group('ApiClient', () {
    const testConfig = AppConfig(
      environment: AppEnvironment.development,
      apiBaseUrl: 'http://localhost:3000',
    );

    test('configures Dio with correct timeouts, headers and baseUrl', () {
      final client = ApiClient(config: testConfig);
      final options = client.dio.options;

      expect(options.baseUrl, equals('http://localhost:3000'));
      expect(options.connectTimeout, equals(const Duration(seconds: 10)));
      expect(options.receiveTimeout, equals(const Duration(seconds: 15)));
      expect(options.sendTimeout, equals(const Duration(seconds: 15)));
      expect(options.contentType, equals(Headers.jsonContentType));
      expect(options.responseType, equals(ResponseType.json));
      expect(options.headers['Accept'], equals('application/json'));
    });

    test(
      'attaches AuthHeaderInterceptor and LoggingInterceptor by default',
      () {
        final client = ApiClient(config: testConfig);
        final interceptorTypes = client.dio.interceptors
            .map((i) => i.runtimeType)
            .toList();

        expect(interceptorTypes, contains(AuthHeaderInterceptor));
        expect(interceptorTypes, contains(LoggingInterceptor));
      },
    );

    test(
      'AuthHeaderInterceptor attaches token when provider yields non-empty string',
      () async {
        final interceptor = AuthHeaderInterceptor(
          tokenProvider: () async => 'sample_jwt_token',
        );
        final options = RequestOptions(path: '/test');
        final handler = RequestInterceptorHandler();

        await interceptor.onRequest(options, handler);

        expect(
          options.headers['Authorization'],
          equals('Bearer sample_jwt_token'),
        );
      },
    );

    test(
      'AuthHeaderInterceptor omits Authorization header when token is null',
      () async {
        final interceptor = AuthHeaderInterceptor(
          tokenProvider: () async => null,
        );
        final options = RequestOptions(path: '/test');
        final handler = RequestInterceptorHandler();

        await interceptor.onRequest(options, handler);

        expect(options.headers.containsKey('Authorization'), isFalse);
      },
    );
  });
}
