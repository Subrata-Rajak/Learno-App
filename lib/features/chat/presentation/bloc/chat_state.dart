import 'package:equatable/equatable.dart';
import 'package:learno/features/chat/domain/entities/capability.dart';
import 'package:learno/features/chat/domain/entities/conversation_message.dart';

/// Semantic lifecycle status for [ChatBloc].
enum ChatStatus {
  /// Initial resting state before initialization.
  initial,

  /// Unauthenticated guest view; backend access is disabled.
  guest,

  /// Asynchronous operation in progress (loading capabilities, creating conversation, loading history).
  loading,

  /// Interactive state ready for conversational input.
  ready,

  /// Actively streaming real-time tokens from backend.
  streaming,

  /// Unrecoverable error state.
  error,
}

/// State representing the Ask Learno chat experience.
class ChatState extends Equatable {
  const ChatState({
    this.status = ChatStatus.initial,
    this.capabilities = const [],
    this.selectedCapability,
    this.conversationId,
    this.messages = const [],
    this.isStreaming = false,
    this.goalId,
    this.isGeneratingRoadmap = false,
    this.roadmapId,
    this.errorMessage,
    this.isStreamInterrupted = false,
  });

  /// High-level lifecycle state.
  final ChatStatus status;

  /// Available system conversational capabilities.
  final List<Capability> capabilities;

  /// Currently active capability (defaults to `LEARN_TOPIC`).
  final Capability? selectedCapability;

  /// Active conversation ID, if a conversation has been started or opened.
  final String? conversationId;

  /// Ordered chronological messages in the conversation.
  final List<ConversationMessage> messages;

  /// Whether an SSE token stream is actively in flight.
  final bool isStreaming;

  /// Latest goal ID created during this conversation, if any.
  final String? goalId;

  /// Whether roadmap synthesis is in progress.
  final bool isGeneratingRoadmap;

  /// Latest roadmap ID created during this conversation, if any.
  final String? roadmapId;

  /// Contextual error message, if an operation failed.
  final String? errorMessage;

  /// Whether the active stream was interrupted prematurely.
  final bool isStreamInterrupted;

  /// Whether the user can send a message right now.
  bool get canSendMessage =>
      status != ChatStatus.guest &&
      status != ChatStatus.loading &&
      !isStreaming;

  ChatState copyWith({
    ChatStatus? status,
    List<Capability>? capabilities,
    Capability? selectedCapability,
    String? conversationId,
    bool clearConversationId = false,
    List<ConversationMessage>? messages,
    bool? isStreaming,
    String? goalId,
    bool? isGeneratingRoadmap,
    String? roadmapId,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool? isStreamInterrupted,
  }) {
    return ChatState(
      status: status ?? this.status,
      capabilities: capabilities ?? this.capabilities,
      selectedCapability: selectedCapability ?? this.selectedCapability,
      conversationId: clearConversationId
          ? null
          : (conversationId ?? this.conversationId),
      messages: messages ?? this.messages,
      isStreaming: isStreaming ?? this.isStreaming,
      goalId: goalId ?? this.goalId,
      isGeneratingRoadmap: isGeneratingRoadmap ?? this.isGeneratingRoadmap,
      roadmapId: roadmapId ?? this.roadmapId,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      isStreamInterrupted: isStreamInterrupted ?? this.isStreamInterrupted,
    );
  }

  @override
  List<Object?> get props => [
    status,
    capabilities,
    selectedCapability,
    conversationId,
    messages,
    isStreaming,
    goalId,
    isGeneratingRoadmap,
    roadmapId,
    errorMessage,
    isStreamInterrupted,
  ];
}
