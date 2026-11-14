import 'package:equatable/equatable.dart';
import 'package:learno/features/chat/domain/entities/chat_stream_event.dart';

/// Base class for all [ChatBloc] events.
sealed class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

/// Triggered when the chat screen mounts or authentication status changes.
class ChatStarted extends ChatEvent {
  const ChatStarted({required this.isAuthenticated});

  final bool isAuthenticated;

  @override
  List<Object?> get props => [isAuthenticated];
}

/// Triggered to load an existing conversation by ID.
class ChatConversationOpened extends ChatEvent {
  const ChatConversationOpened({required this.conversationId});

  final String conversationId;

  @override
  List<Object?> get props => [conversationId];
}

/// Triggered when the user submits a message in the composer.
class ChatMessageSubmitted extends ChatEvent {
  const ChatMessageSubmitted({required this.content});

  final String content;

  @override
  List<Object?> get props => [content];
}

/// Triggered to cancel an active in-flight streaming request.
class ChatCancelRequested extends ChatEvent {
  const ChatCancelRequested();
}

/// Triggered to reconcile conversation history from backend after an interrupted stream.
class ChatReconcileRequested extends ChatEvent {
  const ChatReconcileRequested();
}

/// Triggered to reset the conversation and return to the introductory welcome screen.
class ChatResetRequested extends ChatEvent {
  const ChatResetRequested();
}

// Internal stream events dispatched by the stream listener
class ChatStreamEventReceived extends ChatEvent {
  const ChatStreamEventReceived({
    required this.conversationId,
    required this.event,
  });

  final String conversationId;
  final ChatStreamEvent event;

  @override
  List<Object?> get props => [conversationId, event];
}

class ChatStreamErrorReceived extends ChatEvent {
  const ChatStreamErrorReceived({
    required this.conversationId,
    required this.error,
  });

  final String conversationId;
  final Object error;

  @override
  List<Object?> get props => [conversationId, error];
}

class ChatStreamDoneReceived extends ChatEvent {
  const ChatStreamDoneReceived({required this.conversationId});

  final String conversationId;

  @override
  List<Object?> get props => [conversationId];
}
