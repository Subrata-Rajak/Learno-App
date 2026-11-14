import 'package:learno/features/roadmap/domain/entities/roadmap_progress.dart';
import 'package:learno/features/roadmap/domain/repositories/roadmap_repository.dart';

/// Retrieves completion metrics and next-topic pointers for a roadmap.
class GetRoadmapProgress {
  const GetRoadmapProgress(this.repository);

  final RoadmapRepository repository;

  Future<RoadmapProgress> call(String roadmapId) {
    return repository.getRoadmapProgress(roadmapId);
  }
}
