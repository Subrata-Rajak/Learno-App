import 'package:learno/features/chat/domain/entities/conversation_message.dart';
import 'package:learno/features/chat/domain/repositories/chat_repository.dart';

/// Use case that retrieves historical messages for a conversation.
class GetConversationMessages {
  const GetConversationMessages(this.repository);

  final ChatRepository repository;

  Future<List<ConversationMessage>> call({required String conversationId}) {
    return repository.getConversationMessages(conversationId: conversationId);
  }
}
