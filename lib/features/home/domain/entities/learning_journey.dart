import 'package:equatable/equatable.dart';

/// Pure domain entity representing a learning journey in Learno.
///
/// Contains learning-domain properties without UI or data-layer dependencies.
class LearningJourney extends Equatable {
  const LearningJourney({
    required this.id,
    required this.title,
    required this.description,
    required this.completedTopics,
    required this.totalTopics,
    this.nextTopic,
    this.category,
    this.estimatedMinutesRemaining,
  });

  final String id;
  final String title;
  final String description;
  final int completedTopics;
  final int totalTopics;
  final String? nextTopic;
  final String? category;
  final int? estimatedMinutesRemaining;

  double get progressPercentage =>
      totalTopics > 0 ? (completedTopics / totalTopics).clamp(0.0, 1.0) : 0.0;

  String get progressSummary => '$completedTopics of $totalTopics topics';

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    completedTopics,
    totalTopics,
    nextTopic,
    category,
    estimatedMinutesRemaining,
  ];
}
