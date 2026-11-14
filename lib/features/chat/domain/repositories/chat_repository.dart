import 'package:dio/dio.dart';
import 'package:learno/features/chat/domain/entities/capability.dart';
import 'package:learno/features/chat/domain/entities/chat_stream_event.dart';
import 'package:learno/features/chat/domain/entities/conversation.dart';
import 'package:learno/features/chat/domain/entities/conversation_message.dart';

/// Contract defining conversational domain operations.
abstract interface class ChatRepository {
  /// Fetches system conversational capabilities.
  Future<List<Capability>> getCapabilities();

  /// Creates a new conversation session for a given capability ID.
  Future<Conversation> createConversation({required String capabilityId});

  /// Retrieves a specific conversation by ID.
  Future<Conversation> getConversation({required String conversationId});

  /// Lists all conversations belonging to the current user.
  Future<List<Conversation>> getConversations();

  /// Retrieves chronological message history for a conversation.
  Future<List<ConversationMessage>> getConversationMessages({
    required String conversationId,
  });

  /// Sends a user message and returns a real-time stream of conversational AI events.
  Stream<ChatStreamEvent> sendChatMessageStream({
    required String conversationId,
    required String content,
    CancelToken? cancelToken,
  });
}
