import 'package:learno/features/chat/domain/entities/conversation.dart';
import 'package:learno/features/chat/domain/repositories/chat_repository.dart';

/// Use case that fetches an individual conversation by ID.
class GetConversation {
  const GetConversation(this.repository);

  final ChatRepository repository;

  Future<Conversation> call({required String conversationId}) {
    return repository.getConversation(conversationId: conversationId);
  }
}
