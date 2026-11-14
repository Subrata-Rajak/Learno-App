import 'package:equatable/equatable.dart';

/// Lightweight topic summary used inside [RoadmapProgress].
class RoadmapProgressTopic extends Equatable {
  const RoadmapProgressTopic({
    required this.id,
    required this.title,
    required this.sequence,
    this.completedAt,
  });

  /// Unique UUID of the topic.
  final String id;

  /// Topic title.
  final String title;

  /// Sequence number within the roadmap.
  final int sequence;

  /// Completion timestamp if available.
  final DateTime? completedAt;

  @override
  List<Object?> get props => [id, title, sequence, completedAt];
}

/// Pure domain entity representing aggregate progress metrics for a roadmap.
class RoadmapProgress extends Equatable {
  const RoadmapProgress({
    required this.roadmapId,
    required this.totalTopics,
    required this.completedTopics,
    required this.percentage,
    required this.isCompleted,
    this.nextTopic,
    this.lastCompletedTopic,
  });

  /// Unique UUID of the roadmap.
  final String roadmapId;

  /// Total number of topics in the roadmap.
  final int totalTopics;

  /// Number of topics completed by the user.
  final int completedTopics;

  /// Integer progress percentage (0 - 100).
  final int percentage;

  /// Whether all topics in the roadmap have been completed.
  final bool isCompleted;

  /// Next uncompleted topic in the sequence, or null if all are done.
  final RoadmapProgressTopic? nextTopic;

  /// Most recently completed topic, or null if none completed yet.
  final RoadmapProgressTopic? lastCompletedTopic;

  @override
  List<Object?> get props => [
    roadmapId,
    totalTopics,
    completedTopics,
    percentage,
    isCompleted,
    nextTopic,
    lastCompletedTopic,
  ];
}
