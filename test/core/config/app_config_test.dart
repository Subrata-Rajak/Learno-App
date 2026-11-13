import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learno/core/config/app_config.dart';

void main() {
  group('AppConfig', () {
    test('defaults to development environment when unspecified', () {
      final config = AppConfig.fromEnvironment();
      expect(config.environment, equals(AppEnvironment.development));
      expect(config.isDevelopment, isTrue);
      expect(config.isProduction, isFalse);
    });

    test('parses environment strings correctly', () {
      expect(
        AppEnvironment.fromString('production'),
        equals(AppEnvironment.production),
      );
      expect(
        AppEnvironment.fromString('PROD'),
        equals(AppEnvironment.production),
      );
      expect(
        AppEnvironment.fromString('staging'),
        equals(AppEnvironment.staging),
      );
      expect(
        AppEnvironment.fromString('stage'),
        equals(AppEnvironment.staging),
      );
      expect(
        AppEnvironment.fromString('development'),
        equals(AppEnvironment.development),
      );
      expect(
        AppEnvironment.fromString('dev'),
        equals(AppEnvironment.development),
      );
      expect(
        AppEnvironment.fromString('unknown'),
        equals(AppEnvironment.development),
      );
    });

    test('resolves Android emulator base URL on Android platform', () {
      final config = AppConfig.fromEnvironment(
        targetPlatform: TargetPlatform.android,
        isWebOverride: false,
      );
      expect(config.apiBaseUrl, equals('http://10.0.2.2:3000'));
    });

    test('resolves localhost base URL on iOS simulator / desktop', () {
      final config = AppConfig.fromEnvironment(
        targetPlatform: TargetPlatform.iOS,
        isWebOverride: false,
      );
      expect(config.apiBaseUrl, equals('http://localhost:3000'));
    });

    test('explicit constructor retains provided base URL and environment', () {
      const customUrl = 'http://192.168.1.100:3000';
      const config = AppConfig(
        environment: AppEnvironment.development,
        apiBaseUrl: customUrl,
      );
      expect(config.apiBaseUrl, equals(customUrl));
      expect(config.environment, equals(AppEnvironment.development));
    });
  });
}
