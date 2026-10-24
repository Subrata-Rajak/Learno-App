import 'package:learno/features/home/domain/entities/learning_journey.dart';

/// Data transfer model for LearningJourney with JSON serialization support.
class LearningJourneyModel extends LearningJourney {
  const LearningJourneyModel({
    required super.id,
    required super.title,
    required super.description,
    required super.completedTopics,
    required super.totalTopics,
    super.nextTopic,
    super.category,
    super.estimatedMinutesRemaining,
  });

  factory LearningJourneyModel.fromJson(Map<String, dynamic> json) {
    return LearningJourneyModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      completedTopics: json['completedTopics'] as int,
      totalTopics: json['totalTopics'] as int,
      nextTopic: json['nextTopic'] as String?,
      category: json['category'] as String?,
      estimatedMinutesRemaining: json['estimatedMinutesRemaining'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'completedTopics': completedTopics,
      'totalTopics': totalTopics,
      'nextTopic': nextTopic,
      'category': category,
      'estimatedMinutesRemaining': estimatedMinutesRemaining,
    };
  }
}
