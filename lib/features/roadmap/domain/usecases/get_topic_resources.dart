import 'package:learno/features/roadmap/domain/entities/topic_resource.dart';
import 'package:learno/features/roadmap/domain/repositories/roadmap_repository.dart';

/// Fetches external resources for a specific topic.
class GetTopicResources {
  const GetTopicResources(this.repository);

  final RoadmapRepository repository;

  Future<List<TopicResource>> call(String topicId) {
    return repository.getTopicResources(topicId);
  }
}
