import 'package:learno/features/roadmap/domain/entities/learning_goal.dart';
import 'package:learno/features/roadmap/domain/repositories/roadmap_repository.dart';

/// Fetches all active learning goals for the current user.
class GetActiveLearningGoals {
  const GetActiveLearningGoals(this.repository);

  final RoadmapRepository repository;

  Future<List<LearningGoal>> call() {
    return repository.getActiveLearningGoals();
  }
}
