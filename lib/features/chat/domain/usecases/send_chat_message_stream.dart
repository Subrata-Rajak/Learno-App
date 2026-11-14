import 'package:dio/dio.dart';
import 'package:learno/features/chat/domain/entities/chat_stream_event.dart';
import 'package:learno/features/chat/domain/repositories/chat_repository.dart';

/// Use case that sends a chat message and returns a real-time stream of AI events.
class SendChatMessageStream {
  const SendChatMessageStream(this.repository);

  final ChatRepository repository;

  Stream<ChatStreamEvent> call({
    required String conversationId,
    required String content,
    CancelToken? cancelToken,
  }) {
    return repository.sendChatMessageStream(
      conversationId: conversationId,
      content: content,
      cancelToken: cancelToken,
    );
  }
}
