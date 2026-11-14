import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learno/core/network/errors/app_exception.dart';
import 'package:learno/features/chat/domain/entities/chat_stream_event.dart';
import 'package:learno/features/chat/domain/entities/conversation_message.dart';
import 'package:learno/features/chat/domain/usecases/create_conversation.dart';
import 'package:learno/features/chat/domain/usecases/get_capabilities.dart';
import 'package:learno/features/chat/domain/usecases/get_conversation.dart';
import 'package:learno/features/chat/domain/usecases/get_conversation_messages.dart';
import 'package:learno/features/chat/domain/usecases/get_conversations.dart';
import 'package:learno/features/chat/domain/usecases/send_chat_message_stream.dart';
import 'package:learno/features/chat/presentation/bloc/chat_event.dart';
import 'package:learno/features/chat/presentation/bloc/chat_state.dart';

/// Business logic component managing the Ask Learno conversational interface.
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc({
    required this.getCapabilities,
    required this.createConversation,
    required this.getConversation,
    required this.getConversations,
    required this.getConversationMessages,
    required this.sendChatMessageStream,
  }) : super(const ChatState()) {
    on<ChatStarted>(_onStarted);
    on<ChatConversationOpened>(_onConversationOpened);
    on<ChatMessageSubmitted>(_onMessageSubmitted);
    on<ChatCancelRequested>(_onCancelRequested);
    on<ChatReconcileRequested>(_onReconcileRequested);
    on<ChatResetRequested>(_onResetRequested);
    on<ChatStreamEventReceived>(_onStreamEventReceived);
    on<ChatStreamErrorReceived>(_onStreamErrorReceived);
    on<ChatStreamDoneReceived>(_onStreamDoneReceived);
  }

  final GetCapabilities getCapabilities;
  final CreateConversation createConversation;
  final GetConversation getConversation;
  final GetConversations getConversations;
  final GetConversationMessages getConversationMessages;
  final SendChatMessageStream sendChatMessageStream;

  CancelToken? _activeCancelToken;
  StreamSubscription<ChatStreamEvent>? _streamSubscription;

  Future<void> _onStarted(ChatStarted event, Emitter<ChatState> emit) async {
    if (!event.isAuthenticated) {
      _cancelActiveStream();
      emit(const ChatState(status: ChatStatus.guest));
      return;
    }

    // If capabilities are already loaded and not in guest/initial mode, remain ready
    if (state.capabilities.isNotEmpty && state.status == ChatStatus.ready) {
      return;
    }

    emit(state.copyWith(status: ChatStatus.loading, clearErrorMessage: true));

    try {
      final capabilities = await getCapabilities();
      final defaultCapability = capabilities.firstWhere(
        (c) => c.key == 'LEARN_TOPIC',
        orElse: () => capabilities.first,
      );

      emit(
        state.copyWith(
          status: ChatStatus.ready,
          capabilities: capabilities,
          selectedCapability: defaultCapability,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ChatStatus.error,
          errorMessage: e is AppException ? e.message : e.toString(),
        ),
      );
    }
  }

  Future<void> _onConversationOpened(
    ChatConversationOpened event,
    Emitter<ChatState> emit,
  ) async {
    _cancelActiveStream();

    emit(
      state.copyWith(
        status: ChatStatus.loading,
        conversationId: event.conversationId,
        clearErrorMessage: true,
      ),
    );

    try {
      final messages = await getConversationMessages(
        conversationId: event.conversationId,
      );

      emit(
        state.copyWith(
          status: ChatStatus.ready,
          conversationId: event.conversationId,
          messages: messages,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ChatStatus.error,
          errorMessage: e is AppException ? e.message : e.toString(),
        ),
      );
    }
  }

  Future<void> _onMessageSubmitted(
    ChatMessageSubmitted event,
    Emitter<ChatState> emit,
  ) async {
    final text = event.content.trim();
    if (text.isEmpty || !state.canSendMessage) {
      return;
    }

    // 1. Optimistic UI: Add user message and empty assistant bubble
    final userSeq = state.messages.isEmpty
        ? 1
        : state.messages.last.sequence + 1;
    final now = DateTime.now();

    final userMsg = ConversationMessage(
      id: 'temp_user_${now.millisecondsSinceEpoch}',
      conversationId: state.conversationId ?? '',
      role: 'USER',
      content: text,
      sequence: userSeq,
      createdAt: now,
    );

    final assistantMsg = ConversationMessage(
      id: 'temp_assistant_${now.millisecondsSinceEpoch}',
      conversationId: state.conversationId ?? '',
      role: 'ASSISTANT',
      content: '',
      sequence: userSeq + 1,
      createdAt: now,
    );

    emit(
      state.copyWith(
        messages: [...state.messages, userMsg, assistantMsg],
        isStreaming: true,
        isStreamInterrupted: false,
        clearErrorMessage: true,
      ),
    );

    // 2. Conversation creation (if starting fresh)
    String conversationId;
    if (state.conversationId == null) {
      final capabilityId =
          state.selectedCapability?.id ??
          (state.capabilities.isNotEmpty ? state.capabilities.first.id : null);

      if (capabilityId == null) {
        emit(
          state.copyWith(
            isStreaming: false,
            errorMessage: 'No capability selected to start conversation.',
          ),
        );
        return;
      }

      try {
        final conversation = await createConversation(
          capabilityId: capabilityId,
        );
        conversationId = conversation.id;
        emit(state.copyWith(conversationId: conversationId));
      } catch (e) {
        emit(
          state.copyWith(
            isStreaming: false,
            errorMessage: e is AppException ? e.message : e.toString(),
          ),
        );
        return;
      }
    } else {
      conversationId = state.conversationId!;
    }

    // 3. Start SSE stream
    _cancelActiveStream();
    _activeCancelToken = CancelToken();

    final stream = sendChatMessageStream(
      conversationId: conversationId,
      content: text,
      cancelToken: _activeCancelToken,
    );

    final targetConvId = conversationId;

    _streamSubscription = stream.listen(
      (streamEvent) {
        add(
          ChatStreamEventReceived(
            conversationId: targetConvId,
            event: streamEvent,
          ),
        );
      },
      onError: (error) {
        add(
          ChatStreamErrorReceived(conversationId: targetConvId, error: error),
        );
      },
      onDone: () {
        add(ChatStreamDoneReceived(conversationId: targetConvId));
      },
    );
  }

  void _onStreamEventReceived(
    ChatStreamEventReceived event,
    Emitter<ChatState> emit,
  ) {
    // Prevent stale stream events from updating a different conversation
    if (event.conversationId != state.conversationId) {
      return;
    }

    switch (event.event) {
      case ChatTokenEvent(:final text):
        final msgs = List<ConversationMessage>.from(state.messages);
        if (msgs.isNotEmpty && msgs.last.role == 'ASSISTANT') {
          final last = msgs.removeLast();
          msgs.add(
            ConversationMessage(
              id: last.id,
              conversationId: last.conversationId,
              role: last.role,
              content: last.content + text,
              sequence: last.sequence,
              createdAt: last.createdAt,
            ),
          );
        }
        emit(state.copyWith(messages: msgs));

      case ChatGoalCreatedEvent(:final goalId):
        emit(state.copyWith(goalId: goalId));

      case ChatRoadmapStartedEvent():
        emit(state.copyWith(isGeneratingRoadmap: true));

      case ChatRoadmapCompletedEvent(:final roadmapId):
        emit(state.copyWith(roadmapId: roadmapId, isGeneratingRoadmap: false));

      case ChatCompleteEvent():
        emit(state.copyWith(isStreaming: false, isGeneratingRoadmap: false));

      case ChatErrorEvent(:final message):
        emit(
          state.copyWith(
            isStreaming: false,
            isGeneratingRoadmap: false,
            errorMessage: message,
          ),
        );

      case ChatUnknownEvent():
        // Unknown future events preserved without disruption
        break;
    }
  }

  void _onStreamErrorReceived(
    ChatStreamErrorReceived event,
    Emitter<ChatState> emit,
  ) {
    if (event.conversationId != state.conversationId) {
      return;
    }

    final error = event.error;

    if (error is CancellationException) {
      emit(state.copyWith(isStreaming: false, isGeneratingRoadmap: false));
      return;
    }

    if (error is ServerException &&
        error.errorCode == 'STREAM_PREMATURE_TERMINATION') {
      emit(
        state.copyWith(
          isStreaming: false,
          isGeneratingRoadmap: false,
          isStreamInterrupted: true,
          errorMessage: 'Stream connection was interrupted.',
        ),
      );
      return;
    }

    final message = error is AppException
        ? error.message
        : 'An error occurred during response streaming.';

    emit(
      state.copyWith(
        isStreaming: false,
        isGeneratingRoadmap: false,
        isStreamInterrupted: true,
        errorMessage: message,
      ),
    );
  }

  void _onStreamDoneReceived(
    ChatStreamDoneReceived event,
    Emitter<ChatState> emit,
  ) {
    if (event.conversationId != state.conversationId) {
      return;
    }

    emit(state.copyWith(isStreaming: false, isGeneratingRoadmap: false));
  }

  void _onCancelRequested(ChatCancelRequested event, Emitter<ChatState> emit) {
    _cancelActiveStream();
    emit(state.copyWith(isStreaming: false, isGeneratingRoadmap: false));
  }

  Future<void> _onReconcileRequested(
    ChatReconcileRequested event,
    Emitter<ChatState> emit,
  ) async {
    final convId = state.conversationId;
    if (convId == null) {
      return;
    }

    emit(state.copyWith(status: ChatStatus.loading, clearErrorMessage: true));

    try {
      final messages = await getConversationMessages(conversationId: convId);

      emit(
        state.copyWith(
          status: ChatStatus.ready,
          messages: messages,
          isStreamInterrupted: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ChatStatus.ready,
          errorMessage: e is AppException ? e.message : e.toString(),
        ),
      );
    }
  }

  void _onResetRequested(ChatResetRequested event, Emitter<ChatState> emit) {
    _cancelActiveStream();

    emit(
      state.copyWith(
        status: ChatStatus.ready,
        clearConversationId: true,
        messages: const [],
        isStreaming: false,
        goalId: null,
        isGeneratingRoadmap: false,
        roadmapId: null,
        clearErrorMessage: true,
        isStreamInterrupted: false,
      ),
    );
  }

  void _cancelActiveStream() {
    _activeCancelToken?.cancel('Cancelled by ChatBloc');
    _activeCancelToken = null;
    _streamSubscription?.cancel();
    _streamSubscription = null;
  }

  @override
  Future<void> close() {
    _cancelActiveStream();
    return super.close();
  }
}
