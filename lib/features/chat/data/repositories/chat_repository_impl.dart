import 'package:dio/dio.dart';
import 'package:learno/core/network/errors/app_exception.dart';
import 'package:learno/core/network/errors/error_handler.dart';
import 'package:learno/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:learno/features/chat/data/datasources/sse/chat_event_mapper.dart';
import 'package:learno/features/chat/domain/entities/capability.dart';
import 'package:learno/features/chat/domain/entities/chat_stream_event.dart';
import 'package:learno/features/chat/domain/entities/conversation.dart';
import 'package:learno/features/chat/domain/entities/conversation_message.dart';
import 'package:learno/features/chat/domain/repositories/chat_repository.dart';

/// Implementation of [ChatRepository] orchestrating remote data sources and event mapping.
class ChatRepositoryImpl implements ChatRepository {
  const ChatRepositoryImpl({
    required this.remoteDataSource,
    this.eventMapper = const ChatEventMapper(),
  });

  final ChatRemoteDataSource remoteDataSource;
  final ChatEventMapper eventMapper;

  @override
  Future<List<Capability>> getCapabilities() async {
    try {
      final models = await remoteDataSource.getCapabilities();
      return models;
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<Conversation> createConversation({
    required String capabilityId,
  }) async {
    try {
      final model = await remoteDataSource.createConversation(
        capabilityId: capabilityId,
      );
      return model;
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<Conversation> getConversation({required String conversationId}) async {
    try {
      final model = await remoteDataSource.getConversation(
        conversationId: conversationId,
      );
      return model;
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<List<Conversation>> getConversations() async {
    try {
      final models = await remoteDataSource.getConversations();
      return models;
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Future<List<ConversationMessage>> getConversationMessages({
    required String conversationId,
  }) async {
    try {
      final models = await remoteDataSource.getConversationMessages(
        conversationId: conversationId,
      );
      return models;
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ErrorHandler.handle(e);
    }
  }

  @override
  Stream<ChatStreamEvent> sendChatMessageStream({
    required String conversationId,
    required String content,
    CancelToken? cancelToken,
  }) async* {
    try {
      final sseStream = remoteDataSource.streamChat(
        conversationId: conversationId,
        content: content,
        cancelToken: cancelToken,
      );

      await for (final sseEvent in sseStream) {
        final domainEvent = eventMapper.map(sseEvent);
        yield domainEvent;
      }
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      throw ErrorHandler.handle(e);
    }
  }
}
