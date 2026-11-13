import 'package:dio/dio.dart';

/// Function signature for retrieving the current access token.
typedef AccessTokenProvider = Future<String?> Function();

/// Centralized interceptor responsible for future authentication header attachment.
///
/// Prepares the request pipeline for bearer token injection in upcoming auth checkpoints
/// without enforcing token persistence or refresh logic before authentication is introduced.
class AuthHeaderInterceptor extends Interceptor {
  AuthHeaderInterceptor({this.tokenProvider});

  final AccessTokenProvider? tokenProvider;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (tokenProvider != null) {
      try {
        final token = await tokenProvider!();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
      } catch (_) {
        // Silently continue; error interceptor will handle missing authentication
      }
    }

    super.onRequest(options, handler);
  }
}
