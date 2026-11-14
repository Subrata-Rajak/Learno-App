import 'package:equatable/equatable.dart';

/// Pure domain entity representing a user's crystallized Learning Goal.
class LearningGoal extends Equatable {
  const LearningGoal({
    required this.id,
    required this.userId,
    required this.title,
    required this.subject,
    required this.description,
    required this.currentLevel,
    this.targetOutcome,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Unique UUID of the learning goal.
  final String id;

  /// ID of the user owning this learning goal.
  final String userId;

  /// Goal title (e.g., 'Master Flutter Architecture').
  final String title;

  /// Primary subject category (e.g., 'Mobile Engineering').
  final String subject;

  /// In-depth description of the desired objective.
  final String description;

  /// Assessed current proficiency level (e.g., 'BEGINNER', 'INTERMEDIATE', 'ADVANCED', 'UNKNOWN').
  final String currentLevel;

  /// Optional specific target outcome articulated by the user.
  final String? targetOutcome;

  /// Status of the goal ('ACTIVE', 'COMPLETED', 'ARCHIVED').
  final String status;

  /// Goal creation timestamp.
  final DateTime createdAt;

  /// Last update timestamp.
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
    id,
    userId,
    title,
    subject,
    description,
    currentLevel,
    targetOutcome,
    status,
    createdAt,
    updatedAt,
  ];
}
