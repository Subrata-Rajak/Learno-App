import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Handler function signature for executing session refresh.
typedef RefreshSessionHandler = Future<bool> Function();

/// Handler function signature for retrieving the updated access token.
typedef AccessTokenGetter = Future<String?> Function();

/// Interceptor that handles transparent token refresh on HTTP 401 responses.
///
/// Features:
/// - Intercepts 401 Unauthorized responses on eligible endpoints.
/// - Coordinates a single active refresh operation across concurrent 401 failures.
/// - Rotates and persists token pairs via [onRefresh].
/// - Retries the original failed request exactly once with the new access token.
/// - Avoids recursive refresh loops on authentication endpoints.
/// - Purges invalid sessions and triggers [onSessionExpired] if refresh fails.
class TokenRefreshInterceptor extends QueuedInterceptor {
  TokenRefreshInterceptor({
    required this.onRefresh,
    required this.tokenGetter,
    required this.dio,
    this.onSessionExpired,
  });

  final RefreshSessionHandler onRefresh;
  final AccessTokenGetter tokenGetter;
  final Dio dio;
  final VoidCallback? onSessionExpired;

  static const String _retryKey = 'learno_is_retry_request';
  Completer<bool>? _refreshCompleter;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    if (statusCode != 401) {
      return handler.next(err);
    }

    final path = err.requestOptions.path;
    // 1. Never attempt refresh for authentication endpoints themselves
    if (_isAuthEndpoint(path)) {
      return handler.next(err);
    }

    // 2. Never retry an already retried request (at most one retry)
    if (err.requestOptions.extra[_retryKey] == true) {
      return handler.next(err);
    }

    // 3. Concurrency guard: Coordinate single refresh in-flight
    bool refreshSucceeded = false;
    if (_refreshCompleter != null) {
      refreshSucceeded = await _refreshCompleter!.future;
    } else {
      _refreshCompleter = Completer<bool>();
      try {
        refreshSucceeded = await onRefresh();
        _refreshCompleter!.complete(refreshSucceeded);
      } catch (_) {
        _refreshCompleter!.complete(false);
      } finally {
        _refreshCompleter = null;
      }
    }

    // 4. Retry original request if refresh succeeded
    if (refreshSucceeded) {
      try {
        final newAccessToken = await tokenGetter();
        final requestOptions = err.requestOptions;

        requestOptions.extra[_retryKey] = true;
        if (newAccessToken != null && newAccessToken.isNotEmpty) {
          requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
        }

        final response = await dio.fetch(requestOptions);
        return handler.resolve(response);
      } catch (retryError) {
        if (retryError is DioException) {
          return handler.next(retryError);
        }
        return handler.next(err);
      }
    } else {
      onSessionExpired?.call();
      return handler.next(err);
    }
  }

  bool _isAuthEndpoint(String path) {
    return path.contains('/auth/login') ||
        path.contains('/auth/register') ||
        path.contains('/auth/refresh') ||
        path.contains('/auth/logout');
  }
}
