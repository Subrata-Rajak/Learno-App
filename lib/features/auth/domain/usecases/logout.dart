import 'package:learno/features/auth/domain/repositories/auth_repository.dart';

/// Use case that logs the user out, revoking remote refresh session and clearing stored tokens.
class Logout {
  const Logout(this.repository);

  final AuthRepository repository;

  Future<void> call() {
    return repository.logout();
  }
}
