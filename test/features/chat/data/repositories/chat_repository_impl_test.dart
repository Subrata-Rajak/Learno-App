import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learno/core/network/errors/app_exception.dart';
import 'package:learno/features/chat/data/datasources/chat_remote_data_source.dart';
import 'package:learno/features/chat/data/datasources/sse/chat_event_mapper.dart';
import 'package:learno/features/chat/data/datasources/sse/sse_event.dart';
import 'package:learno/features/chat/data/models/capability_model.dart';
import 'package:learno/features/chat/data/models/conversation_message_model.dart';
import 'package:learno/features/chat/data/models/conversation_model.dart';
import 'package:learno/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:learno/features/chat/domain/entities/chat_stream_event.dart';
import 'package:learno/features/chat/domain/usecases/create_conversation.dart';
import 'package:learno/features/chat/domain/usecases/get_capabilities.dart';
import 'package:learno/features/chat/domain/usecases/get_conversation.dart';
import 'package:learno/features/chat/domain/usecases/get_conversation_messages.dart';
import 'package:learno/features/chat/domain/usecases/get_conversations.dart';
import 'package:learno/features/chat/domain/usecases/send_chat_message_stream.dart';

class FakeChatRemoteDataSource implements ChatRemoteDataSource {
  List<CapabilityModel> mockCapabilities = [];
  ConversationModel? mockCreatedConversation;
  ConversationModel? mockConversation;
  List<ConversationModel> mockConversations = [];
  List<ConversationMessageModel> mockMessages = [];
  Stream<SseEvent>? mockSseStream;

  AppException? exceptionToThrow;

  @override
  Future<List<CapabilityModel>> getCapabilities() async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return mockCapabilities;
  }

  @override
  Future<ConversationModel> createConversation({
    required String capabilityId,
  }) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return mockCreatedConversation!;
  }

  @override
  Future<ConversationModel> getConversation({
    required String conversationId,
  }) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return mockConversation!;
  }

  @override
  Future<List<ConversationModel>> getConversations() async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return mockConversations;
  }

  @override
  Future<List<ConversationMessageModel>> getConversationMessages({
    required String conversationId,
  }) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return mockMessages;
  }

  @override
  Stream<SseEvent> streamChat({
    required String conversationId,
    required String content,
    CancelToken? cancelToken,
  }) {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return mockSseStream ?? const Stream<SseEvent>.empty();
  }
}

void main() {
  group('ChatRepositoryImpl & UseCases', () {
    late FakeChatRemoteDataSource fakeDataSource;
    late ChatRepositoryImpl repository;

    final testNow = DateTime.parse('2026-11-14T10:00:00.000Z');

    final sampleCapability = CapabilityModel(
      id: 'cap-1',
      key: 'LEARN_TOPIC',
      title: 'Learn a New Topic',
      status: 'ACTIVE',
      sortOrder: 1,
    );

    final sampleConversation = ConversationModel(
      id: 'conv-1',
      userId: 'user-1',
      capabilityId: 'cap-1',
      learningGoalId: null,
      status: 'ACTIVE',
      createdAt: testNow,
      updatedAt: testNow,
    );

    final sampleMessage = ConversationMessageModel(
      id: 'msg-1',
      conversationId: 'conv-1',
      role: 'USER',
      content: 'Hello',
      sequence: 1,
      createdAt: testNow,
    );

    setUp(() {
      fakeDataSource = FakeChatRemoteDataSource();
      repository = ChatRepositoryImpl(
        remoteDataSource: fakeDataSource,
        eventMapper: const ChatEventMapper(),
      );
    });

    test('getCapabilities returns mapped domain entities', () async {
      fakeDataSource.mockCapabilities = [sampleCapability];

      final useCase = GetCapabilities(repository);
      final result = await useCase();

      expect(result.length, equals(1));
      expect(result.first.id, equals('cap-1'));
      expect(result.first.key, equals('LEARN_TOPIC'));
    });

    test(
      'createConversation creates and returns domain Conversation',
      () async {
        fakeDataSource.mockCreatedConversation = sampleConversation;

        final useCase = CreateConversation(repository);
        final result = await useCase(capabilityId: 'cap-1');

        expect(result.id, equals('conv-1'));
        expect(result.capabilityId, equals('cap-1'));
        expect(result.status, equals('ACTIVE'));
      },
    );

    test('getConversation fetches single conversation by ID', () async {
      fakeDataSource.mockConversation = sampleConversation;

      final useCase = GetConversation(repository);
      final result = await useCase(conversationId: 'conv-1');

      expect(result.id, equals('conv-1'));
    });

    test('getConversations returns list of domain conversations', () async {
      fakeDataSource.mockConversations = [sampleConversation];

      final useCase = GetConversations(repository);
      final result = await useCase();

      expect(result.length, equals(1));
      expect(result.first.id, equals('conv-1'));
    });

    test('getConversationMessages returns list of domain messages', () async {
      fakeDataSource.mockMessages = [sampleMessage];

      final useCase = GetConversationMessages(repository);
      final result = await useCase(conversationId: 'conv-1');

      expect(result.length, equals(1));
      expect(result.first.content, equals('Hello'));
      expect(result.first.role, equals('USER'));
    });

    test(
      'sendChatMessageStream maps tokens, milestones, and complete events',
      () async {
        fakeDataSource.mockSseStream = Stream.fromIterable([
          const SseEvent(
            event: 'token',
            data: '{"type":"token","text":"Analyzing..."}',
          ),
          const SseEvent(
            event: 'goal_created',
            data: '{"type":"goal_created","goalId":"goal-99"}',
          ),
          const SseEvent(
            event: 'roadmap_started',
            data: '{"type":"roadmap_started","learningGoalId":"goal-99"}',
          ),
          const SseEvent(
            event: 'roadmap_completed',
            data: '{"type":"roadmap_completed","roadmapId":"rdm-88"}',
          ),
          const SseEvent(event: 'complete', data: '{"message":"Finished"}'),
        ]);

        final useCase = SendChatMessageStream(repository);
        final stream = useCase(conversationId: 'conv-1', content: 'Teach me');

        final events = await stream.toList();

        expect(events.length, equals(5));
        expect(events[0], isA<ChatTokenEvent>());
        expect((events[0] as ChatTokenEvent).text, equals('Analyzing...'));

        expect(events[1], isA<ChatGoalCreatedEvent>());
        expect((events[1] as ChatGoalCreatedEvent).goalId, equals('goal-99'));

        expect(events[2], isA<ChatRoadmapStartedEvent>());
        expect(
          (events[2] as ChatRoadmapStartedEvent).learningGoalId,
          equals('goal-99'),
        );

        expect(events[3], isA<ChatRoadmapCompletedEvent>());
        expect(
          (events[3] as ChatRoadmapCompletedEvent).roadmapId,
          equals('rdm-88'),
        );

        expect(events[4], isA<ChatCompleteEvent>());
        expect((events[4] as ChatCompleteEvent).message, equals('Finished'));
      },
    );

    test('sendChatMessageStream maps error terminal event', () async {
      fakeDataSource.mockSseStream = Stream.fromIterable([
        const SseEvent(event: 'error', data: '{"message":"Model unavailable"}'),
      ]);

      final useCase = SendChatMessageStream(repository);
      final stream = useCase(conversationId: 'conv-1', content: 'Teach me');

      final events = await stream.toList();

      expect(events.length, equals(1));
      expect(events[0], isA<ChatErrorEvent>());
      expect(
        (events[0] as ChatErrorEvent).message,
        equals('Model unavailable'),
      );
    });

    test(
      'propagates HTTP error when remote data source throws before stream starts',
      () {
        fakeDataSource.exceptionToThrow = const ServerException(
          message: 'Internal Gateway Error',
          statusCode: 502,
          errorCode: 'BAD_GATEWAY',
        );

        final useCase = SendChatMessageStream(repository);

        expect(
          () => useCase(conversationId: 'conv-1', content: 'Teach me').toList(),
          throwsA(
            isA<ServerException>().having(
              (e) => e.errorCode,
              'errorCode',
              equals('BAD_GATEWAY'),
            ),
          ),
        );
      },
    );

    test(
      'propagates CancellationException without treating it as server failure',
      () {
        fakeDataSource.exceptionToThrow = const CancellationException(
          message: 'Request was cancelled by user',
        );

        final useCase = SendChatMessageStream(repository);

        expect(
          () => useCase(conversationId: 'conv-1', content: 'Teach me').toList(),
          throwsA(
            isA<CancellationException>().having(
              (e) => e.errorCode,
              'errorCode',
              equals('REQUEST_CANCELLED'),
            ),
          ),
        );
      },
    );

    test(
      'propagates stream interruption exception when stream cut off prematurely',
      () {
        fakeDataSource.exceptionToThrow = const ServerException(
          message:
              'Chat stream closed prematurely without a terminal completion event.',
          errorCode: 'STREAM_PREMATURE_TERMINATION',
        );

        final useCase = SendChatMessageStream(repository);

        expect(
          () => useCase(conversationId: 'conv-1', content: 'Teach me').toList(),
          throwsA(
            isA<ServerException>().having(
              (e) => e.errorCode,
              'errorCode',
              equals('STREAM_PREMATURE_TERMINATION'),
            ),
          ),
        );
      },
    );
  });
}
