import 'package:learno/features/chat/domain/entities/conversation.dart';
import 'package:learno/features/chat/domain/repositories/chat_repository.dart';

/// Use case that retrieves all conversations belonging to the user.
class GetConversations {
  const GetConversations(this.repository);

  final ChatRepository repository;

  Future<List<Conversation>> call() {
    return repository.getConversations();
  }
}
