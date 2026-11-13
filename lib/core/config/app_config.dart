import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Supported application environments.
enum AppEnvironment {
  development,
  staging,
  production;

  static AppEnvironment fromString(String value) {
    return switch (value.trim().toLowerCase()) {
      'production' || 'prod' => AppEnvironment.production,
      'staging' || 'stage' => AppEnvironment.staging,
      _ => AppEnvironment.development,
    };
  }
}

/// Centralized application configuration driven by compile-time environment variables.
///
/// Supports declarations via `--dart-define`:
/// - `APP_ENV`: Environment name (e.g. `development`, `staging`, `production`).
/// - `API_BASE_URL`: Explicit API base URL override.
class AppConfig extends Equatable {
  const AppConfig({required this.environment, required this.apiBaseUrl});

  /// The active application environment.
  final AppEnvironment environment;

  /// The base URL for backend API requests.
  final String apiBaseUrl;

  /// Whether the current environment is development.
  bool get isDevelopment => environment == AppEnvironment.development;

  /// Whether the current environment is production.
  bool get isProduction => environment == AppEnvironment.production;

  /// Factory resolving configuration from compile-time environment definitions.
  factory AppConfig.fromEnvironment({
    TargetPlatform? targetPlatform,
    bool? isWebOverride,
  }) {
    const rawEnv = String.fromEnvironment(
      'APP_ENV',
      defaultValue: 'development',
    );
    const rawBaseUrl = String.fromEnvironment('API_BASE_URL');

    final environment = AppEnvironment.fromString(rawEnv);
    final isWeb = isWebOverride ?? kIsWeb;
    final platform = targetPlatform ?? defaultTargetPlatform;

    final resolvedBaseUrl = _resolveBaseUrl(
      rawBaseUrl: rawBaseUrl,
      environment: environment,
      isWeb: isWeb,
      platform: platform,
    );

    return AppConfig(environment: environment, apiBaseUrl: resolvedBaseUrl);
  }

  static String _resolveBaseUrl({
    required String rawBaseUrl,
    required AppEnvironment environment,
    required bool isWeb,
    required TargetPlatform platform,
  }) {
    // 1. Explicit override via --dart-define takes top priority
    if (rawBaseUrl.trim().isNotEmpty) {
      return rawBaseUrl.trim();
    }

    // 2. Production default
    if (environment == AppEnvironment.production) {
      return 'https://api.learno.app';
    }

    // 3. Staging default
    if (environment == AppEnvironment.staging) {
      return 'https://staging-api.learno.app';
    }

    // 4. Development local defaults:
    // Android emulator routes to host machine via 10.0.2.2
    if (!isWeb && platform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000';
    }

    // iOS Simulator, macOS, Web, and desktop route via localhost
    return 'http://localhost:3000';
  }

  @override
  List<Object?> get props => [environment, apiBaseUrl];
}
