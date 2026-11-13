import 'package:learno/features/auth/domain/entities/auth_user.dart';
import 'package:learno/features/auth/domain/repositories/auth_repository.dart';

/// Use case that registers a new user with email, password, and optional name.
class Register {
  const Register(this.repository);

  final AuthRepository repository;

  Future<AuthUser> call({
    required String email,
    required String password,
    String? name,
  }) {
    return repository.register(email: email, password: password, name: name);
  }
}
