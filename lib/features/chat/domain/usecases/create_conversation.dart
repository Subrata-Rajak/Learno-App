import 'package:learno/features/chat/domain/entities/conversation.dart';
import 'package:learno/features/chat/domain/repositories/chat_repository.dart';

/// Use case that initiates a new conversation with a specific capability.
class CreateConversation {
  const CreateConversation(this.repository);

  final ChatRepository repository;

  Future<Conversation> call({required String capabilityId}) {
    return repository.createConversation(capabilityId: capabilityId);
  }
}
