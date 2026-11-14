import 'package:learno/features/roadmap/domain/entities/roadmap.dart';
import 'package:learno/features/roadmap/domain/repositories/roadmap_repository.dart';

/// Fetches a roadmap and its full ordered topic list by learning goal ID.
class GetRoadmapByGoal {
  const GetRoadmapByGoal(this.repository);

  final RoadmapRepository repository;

  Future<Roadmap> call(String learningGoalId) {
    return repository.getRoadmapByGoal(learningGoalId);
  }
}
