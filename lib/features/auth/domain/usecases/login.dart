import 'package:learno/features/auth/domain/entities/auth_user.dart';
import 'package:learno/features/auth/domain/repositories/auth_repository.dart';

/// Use case that authenticates a user using their email and password.
class Login {
  const Login(this.repository);

  final AuthRepository repository;

  Future<AuthUser> call({required String email, required String password}) {
    return repository.login(email: email, password: password);
  }
}
