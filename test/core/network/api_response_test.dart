import 'package:flutter_test/flutter_test.dart';
import 'package:learno/core/network/models/api_response.dart';

void main() {
  group('ApiResponse', () {
    test('parses successful response with typed data', () {
      final json = {
        'success': true,
        'message': 'Roadmap fetched successfully',
        'data': {'id': 'flutter-101', 'title': 'Flutter Basics'},
      };

      final response = ApiResponse<Map<String, dynamic>>.fromJson(
        json,
        (data) => data as Map<String, dynamic>,
      );

      expect(response.success, isTrue);
      expect(response.message, equals('Roadmap fetched successfully'));
      expect(response.data?['id'], equals('flutter-101'));
      expect(response.error, isNull);
    });

    test('parses error response envelope correctly', () {
      final json = {
        'success': false,
        'message': 'Invalid credentials',
        'error': {'code': 'AUTH_FAILED', 'details': 'Incorrect password'},
      };

      final response = ApiResponse<dynamic>.fromJson(json);

      expect(response.success, isFalse);
      expect(response.message, equals('Invalid credentials'));
      expect(response.data, isNull);
      expect(response.error, isNotNull);
      expect(response.error?.code, equals('AUTH_FAILED'));
      expect(response.error?.details, equals('Incorrect password'));
    });
  });
}
