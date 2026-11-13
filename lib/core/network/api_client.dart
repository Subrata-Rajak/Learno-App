import 'package:dio/dio.dart';
import 'package:learno/core/config/app_config.dart';
import 'package:learno/core/network/errors/error_handler.dart';
import 'package:learno/core/network/interceptors/auth_header_interceptor.dart';
import 'package:learno/core/network/interceptors/logging_interceptor.dart';

/// Centralized HTTP client wrapping Dio with structured error handling,
/// standard timeouts, and uniform configuration.
class ApiClient {
  ApiClient({
    required AppConfig config,
    Dio? customDio,
    AuthHeaderInterceptor? authInterceptor,
    LoggingInterceptor? loggingInterceptor,
  }) : _dio =
           customDio ??
           Dio(
             BaseOptions(
               baseUrl: config.apiBaseUrl,
               connectTimeout: const Duration(seconds: 10),
               receiveTimeout: const Duration(seconds: 15),
               sendTimeout: const Duration(seconds: 15),
               contentType: Headers.jsonContentType,
               responseType: ResponseType.json,
               headers: const {'Accept': 'application/json'},
             ),
           ) {
    _dio.interceptors.addAll([
      authInterceptor ?? AuthHeaderInterceptor(),
      loggingInterceptor ?? LoggingInterceptor(),
    ]);
  }

  final Dio _dio;

  /// Appends an interceptor to the underlying Dio client.
  void addInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);
  }

  /// Direct access to underlying Dio client for specialized transport (e.g. SSE streaming).
  Dio get dio => _dio;

  /// Performs an HTTP GET request.
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// Performs an HTTP POST request.
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// Performs an HTTP PUT request.
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// Performs an HTTP PATCH request.
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  /// Performs an HTTP DELETE request.
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }
}
