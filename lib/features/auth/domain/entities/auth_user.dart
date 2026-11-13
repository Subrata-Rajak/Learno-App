import 'package:equatable/equatable.dart';

/// Pure domain entity representing an authenticated user in Learno.
class AuthUser extends Equatable {
  const AuthUser({
    required this.id,
    required this.email,
    this.name,
    required this.role,
    required this.status,
    this.createdAt,
  });

  final String id;
  final String email;
  final String? name;
  final String role;
  final String status;
  final DateTime? createdAt;

  /// User's display name or fallback to username portion of email.
  String get displayName {
    if (name != null && name!.trim().isNotEmpty) {
      return name!.trim();
    }
    return email.split('@').first;
  }

  /// Whether the user account is active.
  bool get isActive => status.toUpperCase() == 'ACTIVE';

  @override
  List<Object?> get props => [id, email, name, role, status, createdAt];
}
