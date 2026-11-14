import 'package:equatable/equatable.dart';
import 'package:learno/features/roadmap/domain/entities/roadmap_topic.dart';

/// Pure domain entity representing a personalized learning roadmap.
class Roadmap extends Equatable {
  const Roadmap({
    required this.id,
    required this.learningGoalId,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.topics = const [],
  });

  /// Unique UUID of the roadmap.
  final String id;

  /// Associated learning goal ID.
  final String learningGoalId;

  /// Roadmap curriculum title.
  final String title;

  /// Overview description of the entire curriculum path.
  final String status;

  /// Overview description.
  final String description;

  /// Creation timestamp.
  final DateTime createdAt;

  /// Last update timestamp.
  final DateTime updatedAt;

  /// Ordered sequence of roadmap topics.
  final List<RoadmapTopic> topics;

  /// Total count of topics in this roadmap.
  int get totalTopics => topics.length;

  /// Count of completed topics.
  int get completedTopics => topics.where((t) => t.isCompleted).length;

  /// Completion percentage from 0.0 to 1.0.
  double get progressPercentage =>
      totalTopics > 0 ? (completedTopics / totalTopics).clamp(0.0, 1.0) : 0.0;

  @override
  List<Object?> get props => [
    id,
    learningGoalId,
    title,
    description,
    status,
    createdAt,
    updatedAt,
    topics,
  ];
}
