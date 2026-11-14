import 'package:learno/features/chat/domain/entities/conversation.dart';

/// Data model representing a Conversation payload returned by `/api/v1/conversation`.
class ConversationModel extends Conversation {
  const ConversationModel({
    required super.id,
    required super.userId,
    required super.capabilityId,
    super.learningGoalId,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      capabilityId: json['capabilityId'] as String,
      learningGoalId: json['learningGoalId'] as String?,
      status: json['status'] as String? ?? 'ACTIVE',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'capabilityId': capabilityId,
      if (learningGoalId != null) 'learningGoalId': learningGoalId,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
