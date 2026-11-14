import 'package:learno/features/roadmap/domain/entities/learning_goal.dart';
import 'package:learno/features/roadmap/domain/entities/roadmap.dart';
import 'package:learno/features/roadmap/domain/entities/roadmap_progress.dart';
import 'package:learno/features/roadmap/domain/entities/roadmap_topic.dart';
import 'package:learno/features/roadmap/domain/entities/topic_resource.dart';

/// Contract defining roadmap, topic, progress, and learning goal operations.
abstract interface class RoadmapRepository {
  /// Fetches a roadmap and its ordered topics by roadmap ID.
  Future<Roadmap> getRoadmap(String roadmapId);

  /// Fetches a roadmap and its ordered topics by associated learning goal ID.
  Future<Roadmap> getRoadmapByGoal(String learningGoalId);

  /// Retrieves aggregate completion and next-step metrics for a roadmap.
  Future<RoadmapProgress> getRoadmapProgress(String roadmapId);

  /// Marks a specific roadmap topic as completed.
  Future<RoadmapTopic> completeTopic(String topicId);

  /// Fetches AI-discovered and persisted learning resources for a topic.
  Future<List<TopicResource>> getTopicResources(String topicId);

  /// Lists all active learning goals for the authenticated user.
  Future<List<LearningGoal>> getActiveLearningGoals();
}
