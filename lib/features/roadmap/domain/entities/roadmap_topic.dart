import 'package:equatable/equatable.dart';

/// Pure domain entity representing a single ordered topic within a Roadmap.
class RoadmapTopic extends Equatable {
  const RoadmapTopic({
    required this.id,
    required this.roadmapId,
    required this.title,
    required this.description,
    required this.sequence,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Unique UUID of the topic.
  final String id;

  /// ID of the parent roadmap.
  final String roadmapId;

  /// Topic title.
  final String title;

  /// Comprehensive description of the concept and learning goals.
  final String description;

  /// 1-based sequential order within the roadmap.
  final int sequence;

  /// Completion timestamp when marked done, or null if pending.
  final DateTime? completedAt;

  /// Topic creation timestamp.
  final DateTime createdAt;

  /// Last update timestamp.
  final DateTime updatedAt;

  /// Whether the user has marked this topic as completed.
  bool get isCompleted => completedAt != null;

  @override
  List<Object?> get props => [
    id,
    roadmapId,
    title,
    description,
    sequence,
    completedAt,
    createdAt,
    updatedAt,
  ];
}
