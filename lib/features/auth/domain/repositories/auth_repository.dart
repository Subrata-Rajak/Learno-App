import 'package:learno/features/auth/domain/entities/auth_user.dart';

/// Contract defining authentication and session operations.
abstract interface class AuthRepository {
  /// Authenticates with user credentials and persists the returned session tokens.
  Future<AuthUser> login({required String email, required String password});

  /// Registers a new user account according to the backend contract.
  Future<AuthUser> register({
    required String email,
    required String password,
    String? name,
  });

  /// Restores an existing session if valid persisted credentials exist.
  ///
  /// Returns the authenticated [AuthUser] if valid, or null if unauthenticated.
  Future<AuthUser?> restoreSession();

  /// Revokes the current session and clears stored tokens.
  Future<void> logout();

  /// Retrieves the current access token for outgoing network requests.
  Future<String?> getAccessToken();

  /// Attempts to refresh the current access and refresh tokens using rotation.
  ///
  /// Returns `true` if refresh succeeded, or `false` if the session is invalid.
  Future<bool> refreshSession();
}
