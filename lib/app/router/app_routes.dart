/// Centralized route definitions and path sanitization for Learno.
abstract final class AppRoutes {
  // --- Route Paths ---
  static const String homePath = '/';
  static const String myLearningPath = '/my-learning';
  static const String askLearnoPath = '/ask-learno';
  static const String progressPath = '/progress';
  static const String profilePath = '/profile';
  static const String loginPath = '/login';
  static const String registerPath = '/register';
  static const String protectedSamplePath = '/protected-sample';
  static const String roadmapDetailPath = '/roadmap/:roadmapId';

  // --- Route Names ---
  static const String homeName = 'home';
  static const String myLearningName = 'my-learning';
  static const String askLearnoName = 'ask-learno';
  static const String progressName = 'progress';
  static const String profileName = 'profile';
  static const String loginName = 'login';
  static const String registerName = 'register';
  static const String protectedSampleName = 'protected-sample';
  static const String roadmapDetailName = 'roadmap-detail';

  // --- Helpers ---
  static String roadmapDetail(String roadmapId) => '/roadmap/$roadmapId';

  // --- Query Parameters ---
  static const String redirectParam = 'from';

  /// List of paths that require an authenticated session.
  static const Set<String> _protectedPaths = {protectedSamplePath};

  /// Returns whether [path] requires authentication.
  static bool isProtectedPath(String path) {
    return _protectedPaths.contains(path);
  }

  /// Validates and sanitizes a redirect destination path to prevent
  /// open-redirect vulnerabilities.
  ///
  /// Returns `null` if [path] is empty, malformed, contains a protocol/domain,
  /// or points back to an authentication flow.
  static String? sanitizeRedirectPath(String? path) {
    if (path == null || path.isEmpty) {
      return null;
    }

    final trimmed = path.trim();

    // Must be an absolute path starting with a single '/'
    if (!trimmed.startsWith('/') || trimmed.startsWith('//')) {
      return null;
    }

    // Must not contain URI scheme (e.g. 'https://', 'javascript:') or backslashes
    if (trimmed.contains('://') || trimmed.contains('\\')) {
      return null;
    }

    // Must not point to login or register (prevents redirect loops)
    final uri = Uri.tryParse(trimmed);
    if (uri == null) {
      return null;
    }

    final targetPath = uri.path;
    if (targetPath == loginPath || targetPath == registerPath) {
      return null;
    }

    return trimmed;
  }
}
