import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learno/core/network/errors/app_exception.dart';
import 'package:learno/features/chat/domain/entities/capability.dart';
import 'package:learno/features/chat/domain/entities/chat_stream_event.dart';
import 'package:learno/features/chat/domain/entities/conversation.dart';
import 'package:learno/features/chat/domain/entities/conversation_message.dart';
import 'package:learno/features/chat/domain/repositories/chat_repository.dart';
import 'package:learno/features/chat/domain/usecases/create_conversation.dart';
import 'package:learno/features/chat/domain/usecases/get_capabilities.dart';
import 'package:learno/features/chat/domain/usecases/get_conversation.dart';
import 'package:learno/features/chat/domain/usecases/get_conversation_messages.dart';
import 'package:learno/features/chat/domain/usecases/get_conversations.dart';
import 'package:learno/features/chat/domain/usecases/send_chat_message_stream.dart';
import 'package:learno/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:learno/features/chat/presentation/bloc/chat_event.dart';
import 'package:learno/features/chat/presentation/bloc/chat_state.dart';

class FakeChatRepository implements ChatRepository {
  List<Capability> capabilitiesToReturn = [];
  Conversation? conversationToReturn;
  List<ConversationMessage> messagesToReturn = [];
  StreamController<ChatStreamEvent>? streamController;

  AppException? exceptionToThrow;
  int createConversationCallCount = 0;
  int getConversationMessagesCallCount = 0;
  int sendChatMessageStreamCallCount = 0;

  @override
  Future<List<Capability>> getCapabilities() async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return capabilitiesToReturn;
  }

  @override
  Future<Conversation> createConversation({
    required String capabilityId,
  }) async {
    createConversationCallCount++;
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return conversationToReturn ??
        Conversation(
          id: 'conv-auto-1',
          userId: 'user-1',
          capabilityId: capabilityId,
          status: 'ACTIVE',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
  }

  @override
  Future<Conversation> getConversation({required String conversationId}) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return conversationToReturn!;
  }

  @override
  Future<List<Conversation>> getConversations() async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return [];
  }

  @override
  Future<List<ConversationMessage>> getConversationMessages({
    required String conversationId,
  }) async {
    getConversationMessagesCallCount++;
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return messagesToReturn;
  }

  @override
  Stream<ChatStreamEvent> sendChatMessageStream({
    required String conversationId,
    required String content,
    CancelToken? cancelToken,
  }) {
    sendChatMessageStreamCallCount++;
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return streamController?.stream ?? const Stream<ChatStreamEvent>.empty();
  }
}

void main() {
  group('ChatBloc', () {
    late FakeChatRepository repository;
    late ChatBloc bloc;

    final sampleCapability = const Capability(
      id: 'cap-learn-topic',
      key: 'LEARN_TOPIC',
      title: 'Learn a New Topic',
      status: 'ACTIVE',
      sortOrder: 1,
    );

    setUp(() {
      repository = FakeChatRepository();
      repository.capabilitiesToReturn = [sampleCapability];

      bloc = ChatBloc(
        getCapabilities: GetCapabilities(repository),
        createConversation: CreateConversation(repository),
        getConversation: GetConversation(repository),
        getConversations: GetConversations(repository),
        getConversationMessages: GetConversationMessages(repository),
        sendChatMessageStream: SendChatMessageStream(repository),
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state has default ChatState properties', () {
      expect(bloc.state.status, equals(ChatStatus.initial));
      expect(bloc.state.messages, isEmpty);
      expect(bloc.state.isStreaming, isFalse);
    });

    test(
      'guest initialization emits ChatStatus.guest without calling APIs',
      () async {
        bloc.add(const ChatStarted(isAuthenticated: false));

        await expectLater(
          bloc.stream,
          emits(const ChatState(status: ChatStatus.guest)),
        );

        expect(repository.createConversationCallCount, equals(0));
        expect(repository.getConversationMessagesCallCount, equals(0));
      },
    );

    test(
      'authenticated initialization loads capabilities and selects LEARN_TOPIC',
      () async {
        bloc.add(const ChatStarted(isAuthenticated: true));

        await expectLater(
          bloc.stream,
          emitsInOrder([
            const ChatState(status: ChatStatus.loading),
            ChatState(
              status: ChatStatus.ready,
              capabilities: [sampleCapability],
              selectedCapability: sampleCapability,
            ),
          ]),
        );
      },
    );

    test(
      'submitting a message without an existing conversation creates one automatically',
      () async {
        // First initialize
        bloc.add(const ChatStarted(isAuthenticated: true));
        await pumpEventQueue();

        final controller = StreamController<ChatStreamEvent>();
        repository.streamController = controller;

        bloc.add(const ChatMessageSubmitted(content: 'I want to learn Dart'));
        await pumpEventQueue();

        expect(repository.createConversationCallCount, equals(1));
        expect(repository.sendChatMessageStreamCallCount, equals(1));
        expect(bloc.state.conversationId, isNotNull);
        expect(bloc.state.messages.length, equals(2));
        expect(
          bloc.state.messages.first.content,
          equals('I want to learn Dart'),
        );
        expect(bloc.state.messages.first.role, equals('USER'));
        expect(bloc.state.messages.last.role, equals('ASSISTANT'));
        expect(bloc.state.isStreaming, isTrue);

        controller.close();
      },
    );

    test(
      'incoming token events incrementally aggregate into assistant message',
      () async {
        bloc.add(const ChatStarted(isAuthenticated: true));
        await pumpEventQueue();

        final controller = StreamController<ChatStreamEvent>();
        repository.streamController = controller;

        bloc.add(const ChatMessageSubmitted(content: 'Teach me'));
        await pumpEventQueue();

        controller.add(const ChatTokenEvent(text: 'Hello '));
        await pumpEventQueue();
        expect(bloc.state.messages.last.content, equals('Hello '));

        controller.add(const ChatTokenEvent(text: 'world!'));
        await pumpEventQueue();
        expect(bloc.state.messages.last.content, equals('Hello world!'));

        controller.close();
      },
    );

    test(
      'milestone events update goalId, isGeneratingRoadmap, and roadmapId in state',
      () async {
        bloc.add(const ChatStarted(isAuthenticated: true));
        await pumpEventQueue();

        final controller = StreamController<ChatStreamEvent>();
        repository.streamController = controller;

        bloc.add(const ChatMessageSubmitted(content: 'Teach me'));
        await pumpEventQueue();

        controller.add(const ChatGoalCreatedEvent(goalId: 'goal-42'));
        await pumpEventQueue();
        expect(bloc.state.goalId, equals('goal-42'));

        controller.add(
          const ChatRoadmapStartedEvent(learningGoalId: 'goal-42'),
        );
        await pumpEventQueue();
        expect(bloc.state.isGeneratingRoadmap, isTrue);

        controller.add(const ChatRoadmapCompletedEvent(roadmapId: 'rdm-100'));
        await pumpEventQueue();
        expect(bloc.state.roadmapId, equals('rdm-100'));
        expect(bloc.state.isGeneratingRoadmap, isFalse);

        controller.close();
      },
    );

    test('complete event finishes streaming cleanly', () async {
      bloc.add(const ChatStarted(isAuthenticated: true));
      await pumpEventQueue();

      final controller = StreamController<ChatStreamEvent>();
      repository.streamController = controller;

      bloc.add(const ChatMessageSubmitted(content: 'Teach me'));
      await pumpEventQueue();

      controller.add(const ChatTokenEvent(text: 'Done!'));
      controller.add(const ChatCompleteEvent());
      await pumpEventQueue();

      expect(bloc.state.isStreaming, isFalse);
      expect(bloc.state.messages.last.content, equals('Done!'));

      controller.close();
    });

    test(
      'stream error updates state with error message and resets streaming',
      () async {
        bloc.add(const ChatStarted(isAuthenticated: true));
        await pumpEventQueue();

        final controller = StreamController<ChatStreamEvent>();
        repository.streamController = controller;

        bloc.add(const ChatMessageSubmitted(content: 'Teach me'));
        await pumpEventQueue();

        controller.add(const ChatErrorEvent(message: 'AI quota exceeded'));
        await pumpEventQueue();

        expect(bloc.state.isStreaming, isFalse);
        expect(bloc.state.errorMessage, equals('AI quota exceeded'));

        controller.close();
      },
    );

    test('ChatCancelRequested cancels active streaming', () async {
      bloc.add(const ChatStarted(isAuthenticated: true));
      await pumpEventQueue();

      final controller = StreamController<ChatStreamEvent>();
      repository.streamController = controller;

      bloc.add(const ChatMessageSubmitted(content: 'Teach me'));
      await pumpEventQueue();

      expect(bloc.state.isStreaming, isTrue);

      bloc.add(const ChatCancelRequested());
      await pumpEventQueue();

      expect(bloc.state.isStreaming, isFalse);

      controller.close();
    });

    test(
      'interrupted stream sets isStreamInterrupted flag and allows reconciliation',
      () async {
        bloc.add(const ChatStarted(isAuthenticated: true));
        await pumpEventQueue();

        final controller = StreamController<ChatStreamEvent>();
        repository.streamController = controller;

        bloc.add(const ChatMessageSubmitted(content: 'Teach me'));
        await pumpEventQueue();

        controller.addError(
          const ServerException(
            message: 'Connection dropped prematurely',
            errorCode: 'STREAM_PREMATURE_TERMINATION',
          ),
        );
        await pumpEventQueue();

        expect(bloc.state.isStreaming, isFalse);
        expect(bloc.state.isStreamInterrupted, isTrue);

        // Now reconcile: should fetch conversation messages from server without resending
        repository.messagesToReturn = [
          ConversationMessage(
            id: 'server-msg-1',
            conversationId: bloc.state.conversationId!,
            role: 'USER',
            content: 'Teach me',
            sequence: 1,
            createdAt: DateTime.now(),
          ),
          ConversationMessage(
            id: 'server-msg-2',
            conversationId: bloc.state.conversationId!,
            role: 'ASSISTANT',
            content: 'Here is what was saved',
            sequence: 2,
            createdAt: DateTime.now(),
          ),
        ];

        bloc.add(const ChatReconcileRequested());
        await pumpEventQueue();

        expect(repository.getConversationMessagesCallCount, equals(1));
        expect(
          repository.sendChatMessageStreamCallCount,
          equals(1),
        ); // Not called again!
        expect(bloc.state.isStreamInterrupted, isFalse);
        expect(bloc.state.messages.length, equals(2));
        expect(
          bloc.state.messages.last.content,
          equals('Here is what was saved'),
        );
      },
    );

    test(
      'ChatConversationOpened loads message history in chronological sequence',
      () async {
        repository.messagesToReturn = [
          ConversationMessage(
            id: 'hist-1',
            conversationId: 'conv-old',
            role: 'USER',
            content: 'Old message',
            sequence: 1,
            createdAt: DateTime.now(),
          ),
        ];

        bloc.add(const ChatConversationOpened(conversationId: 'conv-old'));
        await pumpEventQueue();

        expect(bloc.state.conversationId, equals('conv-old'));
        expect(bloc.state.messages.length, equals(1));
        expect(bloc.state.messages.first.content, equals('Old message'));
      },
    );

    test(
      'prevents stale stream events from updating a different conversation',
      () async {
        bloc.add(const ChatStarted(isAuthenticated: true));
        await pumpEventQueue();

        final controller = StreamController<ChatStreamEvent>();
        repository.streamController = controller;

        bloc.add(const ChatMessageSubmitted(content: 'Message 1'));
        await pumpEventQueue();

        final initialConvId = bloc.state.conversationId!;

        // User switches conversation
        bloc.add(
          const ChatConversationOpened(conversationId: 'conv-different'),
        );
        await pumpEventQueue();

        // Old stream emits event for initialConvId
        bloc.add(
          ChatStreamEventReceived(
            conversationId: initialConvId,
            event: const ChatTokenEvent(text: 'Stale token'),
          ),
        );
        await pumpEventQueue();

        // State of the new conversation should NOT contain the stale token
        expect(bloc.state.conversationId, equals('conv-different'));
        expect(
          bloc.state.messages.any((m) => m.content.contains('Stale token')),
          isFalse,
        );

        controller.close();
      },
    );
  });
}
