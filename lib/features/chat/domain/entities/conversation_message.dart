import 'package:equatable/equatable.dart';

/// Pure domain entity representing a single message within a conversation.
class ConversationMessage extends Equatable {
  const ConversationMessage({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.sequence,
    required this.createdAt,
  });

  /// Unique UUID of the message.
  final String id;

  /// ID of the parent conversation.
  final String conversationId;

  /// Message author role (`USER`, `ASSISTANT`, or `SYSTEM`).
  final String role;

  /// Text content of the message.
  final String content;

  /// Monotonically increasing sequence integer.
  final int sequence;

  /// Message creation timestamp.
  final DateTime createdAt;

  @override
  List<Object?> get props => [
    id,
    conversationId,
    role,
    content,
    sequence,
    createdAt,
  ];
}
