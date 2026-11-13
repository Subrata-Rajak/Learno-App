import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Lightweight, secure logging interceptor active only in debug builds.
///
/// Strictly protects sensitive data:
/// - Never logs request or response bodies by default.
/// - Redacts authorization tokens, cookies, and secret headers.
/// - Operates inside error-guarded blocks so logging failures cannot disrupt app traffic.
class LoggingInterceptor extends Interceptor {
  LoggingInterceptor({this.enableLogging = kDebugMode});

  final bool enableLogging;

  static const Set<String> _sensitiveHeaderKeys = {
    'authorization',
    'cookie',
    'set-cookie',
    'x-refresh-token',
    'x-access-token',
    'x-api-key',
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (enableLogging) {
      _safeLog(() {
        final sanitizedHeaders = _sanitizeHeaders(options.headers);
        developer.log(
          '--> ${options.method.toUpperCase()} ${options.uri}',
          name: 'ApiClient',
        );
        if (sanitizedHeaders.isNotEmpty) {
          developer.log('    Headers: $sanitizedHeaders', name: 'ApiClient');
        }
      });
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (enableLogging) {
      _safeLog(() {
        developer.log(
          '<-- ${response.statusCode} ${response.requestOptions.method.toUpperCase()} ${response.requestOptions.uri}',
          name: 'ApiClient',
        );
      });
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (enableLogging) {
      _safeLog(() {
        developer.log(
          '<-- ERROR ${err.response?.statusCode ?? 'NO_STATUS'} ${err.requestOptions.method.toUpperCase()} ${err.requestOptions.uri}',
          name: 'ApiClient',
          error: err.message,
        );
      });
    }
    super.onError(err, handler);
  }

  Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic> headers) {
    final sanitized = <String, dynamic>{};
    for (final entry in headers.entries) {
      if (_sensitiveHeaderKeys.contains(entry.key.toLowerCase())) {
        sanitized[entry.key] = '[REDACTED]';
      } else {
        sanitized[entry.key] = entry.value;
      }
    }
    return sanitized;
  }

  void _safeLog(VoidCallback block) {
    try {
      block();
    } catch (_) {
      // Guard against any log formatting failures
    }
  }
}
