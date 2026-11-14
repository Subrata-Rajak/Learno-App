import 'package:learno/features/roadmap/domain/entities/learning_goal.dart';

/// Data model representing a Learning Goal returned by `/api/v1/learning-goals`.
class LearningGoalModel extends LearningGoal {
  const LearningGoalModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.subject,
    required super.description,
    required super.currentLevel,
    super.targetOutcome,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
  });

  factory LearningGoalModel.fromJson(Map<String, dynamic> json) {
    return LearningGoalModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      subject: json['subject'] as String,
      description: json['description'] as String,
      currentLevel: json['currentLevel'] as String,
      targetOutcome: json['targetOutcome'] as String?,
      status: json['status'] as String? ?? 'ACTIVE',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'subject': subject,
      'description': description,
      'currentLevel': currentLevel,
      if (targetOutcome != null) 'targetOutcome': targetOutcome,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
