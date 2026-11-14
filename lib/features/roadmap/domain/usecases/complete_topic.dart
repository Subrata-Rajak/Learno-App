import 'package:learno/features/roadmap/domain/entities/roadmap_topic.dart';
import 'package:learno/features/roadmap/domain/repositories/roadmap_repository.dart';

/// Marks a roadmap topic as completed.
class CompleteTopic {
  const CompleteTopic(this.repository);

  final RoadmapRepository repository;

  Future<RoadmapTopic> call(String topicId) {
    return repository.completeTopic(topicId);
  }
}
