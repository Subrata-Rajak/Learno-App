import 'package:learno/features/chat/domain/entities/conversation_message.dart';

/// Data model representing a ConversationMessage payload returned by `/api/v1/conversation/message/:conversationId`.
class ConversationMessageModel extends ConversationMessage {
  const ConversationMessageModel({
    required super.id,
    required super.conversationId,
    required super.role,
    required super.content,
    required super.sequence,
    required super.createdAt,
  });

  factory ConversationMessageModel.fromJson(Map<String, dynamic> json) {
    return ConversationMessageModel(
      id: json['id'] as String,
      conversationId: json['conversationId'] as String,
      role: json['role'] as String? ?? 'USER',
      content: json['content'] as String,
      sequence: (json['sequence'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'role': role,
      'content': content,
      'sequence': sequence,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
