import 'package:learno/features/roadmap/domain/entities/roadmap.dart';
import 'package:learno/features/roadmap/domain/repositories/roadmap_repository.dart';

/// Fetches a roadmap and its full ordered topic list by roadmap ID.
class GetRoadmap {
  const GetRoadmap(this.repository);

  final RoadmapRepository repository;

  Future<Roadmap> call(String roadmapId) {
    return repository.getRoadmap(roadmapId);
  }
}
