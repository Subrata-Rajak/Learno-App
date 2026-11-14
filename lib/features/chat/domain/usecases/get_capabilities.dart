import 'package:learno/features/chat/domain/entities/capability.dart';
import 'package:learno/features/chat/domain/repositories/chat_repository.dart';

/// Use case that retrieves active system conversational capabilities.
class GetCapabilities {
  const GetCapabilities(this.repository);

  final ChatRepository repository;

  Future<List<Capability>> call() {
    return repository.getCapabilities();
  }
}
