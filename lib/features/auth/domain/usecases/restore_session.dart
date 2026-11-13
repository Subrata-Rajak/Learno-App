import 'package:learno/features/auth/domain/entities/auth_user.dart';
import 'package:learno/features/auth/domain/repositories/auth_repository.dart';

/// Use case that attempts to restore an existing authenticated session on app launch.
class RestoreSession {
  const RestoreSession(this.repository);

  final AuthRepository repository;

  Future<AuthUser?> call() {
    return repository.restoreSession();
  }
}
