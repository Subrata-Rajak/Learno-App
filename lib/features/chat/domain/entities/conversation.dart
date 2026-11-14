import 'package:equatable/equatable.dart';

/// Pure domain entity representing an active or archived conversation session.
class Conversation extends Equatable {
  const Conversation({
    required this.id,
    required this.userId,
    required this.capabilityId,
    this.learningGoalId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Unique UUID of the conversation session.
  final String id;

  /// ID of the user owning this conversation.
  final String userId;

  /// Capability powering this conversation.
  final String capabilityId;

  /// Optional associated learning goal ID created during this conversation.
  final String? learningGoalId;

  /// Status of the conversation (e.g. `ACTIVE`, `COMPLETED`, `ARCHIVED`).
  final String status;

  /// Creation timestamp.
  final DateTime createdAt;

  /// Last update timestamp.
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
    id,
    userId,
    capabilityId,
    learningGoalId,
    status,
    createdAt,
    updatedAt,
  ];
}
