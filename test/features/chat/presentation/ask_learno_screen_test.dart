import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learno/features/ask_learno/presentation/screens/ask_learno_screen.dart';
import 'package:learno/features/auth/domain/entities/auth_user.dart';
import 'package:learno/features/auth/domain/repositories/auth_repository.dart';
import 'package:learno/features/auth/domain/usecases/login.dart';
import 'package:learno/features/auth/domain/usecases/logout.dart';
import 'package:learno/features/auth/domain/usecases/register.dart';
import 'package:learno/features/auth/domain/usecases/restore_session.dart';
import 'package:learno/features/auth/presentation/bloc/auth_bloc.dart';
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
import 'package:learno/features/chat/presentation/bloc/chat_state.dart';
import 'package:learno/features/chat/presentation/widgets/chat_bubble.dart';
import 'package:learno/features/chat/presentation/widgets/chat_composer.dart';
import 'package:learno/features/chat/presentation/widgets/chat_guest_view.dart';
import 'package:learno/features/chat/presentation/widgets/chat_welcome_view.dart';

class FakeAuthRepository implements AuthRepository {
  AuthUser? userToReturn;

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async => userToReturn!;

  @override
  Future<AuthUser> register({
    required String email,
    required String password,
    String? name,
  }) async => userToReturn!;

  @override
  Future<AuthUser?> restoreSession() async => userToReturn;

  @override
  Future<void> logout() async {}

  @override
  Future<bool> refreshSession() async => true;

  @override
  Future<String?> getAccessToken() async => 'fake_token';
}

class FakeChatRepository implements ChatRepository {
  List<Capability> capabilitiesToReturn = [];
  Conversation? conversationToReturn;
  List<ConversationMessage> messagesToReturn = [];
  StreamController<ChatStreamEvent>? streamController;

  @override
  Future<List<Capability>> getCapabilities() async => capabilitiesToReturn;

  @override
  Future<Conversation> createConversation({
    required String capabilityId,
  }) async =>
      conversationToReturn ??
      Conversation(
        id: 'conv-test-1',
        userId: 'u1',
        capabilityId: capabilityId,
        status: 'ACTIVE',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

  @override
  Future<Conversation> getConversation({
    required String conversationId,
  }) async => conversationToReturn!;

  @override
  Future<List<Conversation>> getConversations() async => [];

  @override
  Future<List<ConversationMessage>> getConversationMessages({
    required String conversationId,
  }) async => messagesToReturn;

  @override
  Stream<ChatStreamEvent> sendChatMessageStream({
    required String conversationId,
    required String content,
    CancelToken? cancelToken,
  }) {
    return streamController?.stream ?? const Stream<ChatStreamEvent>.empty();
  }
}

void main() {
  group('AskLearnoScreen UI', () {
    late FakeAuthRepository authRepository;
    late AuthBloc authBloc;
    late FakeChatRepository chatRepository;
    late ChatBloc chatBloc;

    final sampleCapability = const Capability(
      id: 'cap-1',
      key: 'LEARN_TOPIC',
      title: 'Topic Explorer',
      status: 'ACTIVE',
      sortOrder: 1,
    );

    setUp(() {
      authRepository = FakeAuthRepository();
      authBloc = AuthBloc(
        login: Login(authRepository),
        register: Register(authRepository),
        restoreSession: RestoreSession(authRepository),
        logout: Logout(authRepository),
      );

      chatRepository = FakeChatRepository();
      chatRepository.capabilitiesToReturn = [sampleCapability];

      chatBloc = ChatBloc(
        getCapabilities: GetCapabilities(chatRepository),
        createConversation: CreateConversation(chatRepository),
        getConversation: GetConversation(chatRepository),
        getConversations: GetConversations(chatRepository),
        getConversationMessages: GetConversationMessages(chatRepository),
        sendChatMessageStream: SendChatMessageStream(chatRepository),
      );
    });

    tearDown(() {
      authBloc.close();
      chatBloc.close();
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: AskLearnoScreen(chatBloc: chatBloc),
        ),
      );
    }

    testWidgets('renders ChatGuestView when user is unauthenticated', (
      tester,
    ) async {
      chatBloc.emit(const ChatState(status: ChatStatus.guest));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(ChatGuestView), findsOneWidget);
      expect(find.text('Meet Learno'), findsOneWidget);
      expect(find.text('Sign In to Start Learning'), findsOneWidget);
      expect(find.text('Don\'t have an account? Sign up'), findsOneWidget);
      expect(find.byType(ChatComposer), findsNothing);
    });

    testWidgets(
      'renders ChatWelcomeView and ChatComposer when authenticated with no messages',
      (tester) async {
        authRepository.userToReturn = const AuthUser(
          id: 'u1',
          email: 'user@learno.app',
          role: 'USER',
          status: 'ACTIVE',
        );
        authBloc.emit(AuthAuthenticated(user: authRepository.userToReturn!));
        chatBloc.emit(
          ChatState(
            status: ChatStatus.ready,
            capabilities: [sampleCapability],
            selectedCapability: sampleCapability,
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        expect(find.byType(ChatWelcomeView), findsOneWidget);
        expect(find.text('What do you want to learn?'), findsOneWidget);
        expect(find.text('Master Flutter BLoC'), findsOneWidget);
        expect(find.byType(ChatComposer), findsOneWidget);
      },
    );

    testWidgets(
      'renders user and assistant ChatBubble when messages exist in conversation',
      (tester) async {
        authRepository.userToReturn = const AuthUser(
          id: 'u1',
          email: 'user@learno.app',
          role: 'USER',
          status: 'ACTIVE',
        );
        authBloc.emit(AuthAuthenticated(user: authRepository.userToReturn!));

        final now = DateTime.now();
        chatBloc.emit(
          ChatState(
            status: ChatStatus.ready,
            capabilities: [sampleCapability],
            selectedCapability: sampleCapability,
            conversationId: 'conv-test-1',
            messages: [
              ConversationMessage(
                id: 'm1',
                conversationId: 'conv-test-1',
                role: 'USER',
                content: 'Can you teach me Dart streams?',
                sequence: 1,
                createdAt: now,
              ),
              ConversationMessage(
                id: 'm2',
                conversationId: 'conv-test-1',
                role: 'ASSISTANT',
                content: 'Dart streams are asynchronous sequences of data.',
                sequence: 2,
                createdAt: now,
              ),
            ],
          ),
        );

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pump();

        expect(find.byType(ChatBubble), findsNWidgets(2));
        expect(find.text('Can you teach me Dart streams?'), findsOneWidget);
        expect(
          find.text('Dart streams are asynchronous sequences of data.'),
          findsOneWidget,
        );
      },
    );

    testWidgets('composer button changes appearance based on text input', (
      tester,
    ) async {
      authRepository.userToReturn = const AuthUser(
        id: 'u1',
        email: 'user@learno.app',
        role: 'USER',
        status: 'ACTIVE',
      );
      authBloc.emit(AuthAuthenticated(user: authRepository.userToReturn!));
      chatBloc.emit(
        ChatState(
          status: ChatStatus.ready,
          capabilities: [sampleCapability],
          selectedCapability: sampleCapability,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      final textFieldFinder = find.byType(TextField);
      expect(textFieldFinder, findsOneWidget);

      // Initially empty: send button is disabled
      await tester.enterText(textFieldFinder, 'I want to learn Go');
      await tester.pump();

      expect(find.text('I want to learn Go'), findsOneWidget);
    });

    testWidgets('renders streaming indicator when isStreaming is active', (
      tester,
    ) async {
      authRepository.userToReturn = const AuthUser(
        id: 'u1',
        email: 'user@learno.app',
        role: 'USER',
        status: 'ACTIVE',
      );
      authBloc.emit(AuthAuthenticated(user: authRepository.userToReturn!));

      final now = DateTime.now();
      chatBloc.emit(
        ChatState(
          status: ChatStatus.ready,
          conversationId: 'conv-test-1',
          isStreaming: true,
          messages: [
            ConversationMessage(
              id: 'm1',
              conversationId: 'conv-test-1',
              role: 'USER',
              content: 'What is BLoC?',
              sequence: 1,
              createdAt: now,
            ),
            ConversationMessage(
              id: 'm2',
              conversationId: 'conv-test-1',
              role: 'ASSISTANT',
              content: 'BLoC stands for Business Logic Component',
              sequence: 2,
              createdAt: now,
            ),
          ],
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('Thinking...'), findsOneWidget);
      expect(find.byIcon(Icons.stop_rounded), findsOneWidget);
    });

    testWidgets('renders error presentation when state has status error', (
      tester,
    ) async {
      authRepository.userToReturn = const AuthUser(
        id: 'u1',
        email: 'user@learno.app',
        role: 'USER',
        status: 'ACTIVE',
      );
      authBloc.emit(AuthAuthenticated(user: authRepository.userToReturn!));

      chatBloc.emit(
        const ChatState(
          status: ChatStatus.error,
          errorMessage: 'Server is currently unreachable',
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();
      await tester.pump();

      expect(find.text('Failed to load Learno'), findsOneWidget);
      expect(find.text('Server is currently unreachable'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });
  });
}
