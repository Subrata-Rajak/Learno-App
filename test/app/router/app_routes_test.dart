import 'package:flutter_test/flutter_test.dart';
import 'package:learno/app/router/app_routes.dart';

void main() {
  group('AppRoutes', () {
    test('isProtectedPath correctly identifies protected destinations', () {
      expect(AppRoutes.isProtectedPath(AppRoutes.protectedSamplePath), isTrue);
      expect(AppRoutes.isProtectedPath(AppRoutes.homePath), isFalse);
      expect(AppRoutes.isProtectedPath(AppRoutes.myLearningPath), isFalse);
      expect(AppRoutes.isProtectedPath(AppRoutes.askLearnoPath), isFalse);
      expect(AppRoutes.isProtectedPath(AppRoutes.progressPath), isFalse);
      expect(AppRoutes.isProtectedPath(AppRoutes.profilePath), isFalse);
      expect(AppRoutes.isProtectedPath(AppRoutes.loginPath), isFalse);
      expect(AppRoutes.isProtectedPath(AppRoutes.registerPath), isFalse);
    });

    group('sanitizeRedirectPath', () {
      test('returns null for null, empty or blank strings', () {
        expect(AppRoutes.sanitizeRedirectPath(null), isNull);
        expect(AppRoutes.sanitizeRedirectPath(''), isNull);
        expect(AppRoutes.sanitizeRedirectPath('   '), isNull);
      });

      test('accepts valid relative internal paths', () {
        expect(
          AppRoutes.sanitizeRedirectPath('/my-learning'),
          equals('/my-learning'),
        );
        expect(
          AppRoutes.sanitizeRedirectPath(AppRoutes.protectedSamplePath),
          equals(AppRoutes.protectedSamplePath),
        );
        expect(
          AppRoutes.sanitizeRedirectPath('/progress'),
          equals('/progress'),
        );
        expect(AppRoutes.sanitizeRedirectPath('/'), equals('/'));
      });

      test('rejects external URLs and schemes (prevents open redirects)', () {
        expect(AppRoutes.sanitizeRedirectPath('https://evil.com'), isNull);
        expect(
          AppRoutes.sanitizeRedirectPath('http://malicious.org/test'),
          isNull,
        );
        expect(AppRoutes.sanitizeRedirectPath('javascript:alert(1)'), isNull);
        expect(AppRoutes.sanitizeRedirectPath('/foo://bar'), isNull);
      });

      test('rejects protocol-relative URLs (//evil.com)', () {
        expect(AppRoutes.sanitizeRedirectPath('//evil.com'), isNull);
        expect(AppRoutes.sanitizeRedirectPath('//evil.com/phish'), isNull);
      });

      test('rejects backslashes', () {
        expect(AppRoutes.sanitizeRedirectPath(r'/evil\test'), isNull);
      });

      test(
        'rejects redirection back to authentication endpoints (prevents loops)',
        () {
          expect(AppRoutes.sanitizeRedirectPath('/login'), isNull);
          expect(AppRoutes.sanitizeRedirectPath('/register'), isNull);
          expect(AppRoutes.sanitizeRedirectPath('/login?from=/test'), isNull);
          expect(AppRoutes.sanitizeRedirectPath('/register?ref=123'), isNull);
        },
      );
    });
  });
}
