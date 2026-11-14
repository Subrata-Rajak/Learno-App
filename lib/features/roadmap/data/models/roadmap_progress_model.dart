import 'package:learno/features/roadmap/domain/entities/roadmap_progress.dart';

/// Data model representing a topic summary inside the progress payload.
class RoadmapProgressTopicModel extends RoadmapProgressTopic {
  const RoadmapProgressTopicModel({
    required super.id,
    required super.title,
    required super.sequence,
    super.completedAt,
  });

  factory RoadmapProgressTopicModel.fromJson(Map<String, dynamic> json) {
    return RoadmapProgressTopicModel(
      id: json['id'] as String,
      title: json['title'] as String,
      sequence: (json['sequence'] as num).toInt(),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'sequence': sequence,
      if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
    };
  }
}

/// Data model representing aggregate roadmap progress returned by `/api/v1/roadmap/:roadmapId/progress`.
class RoadmapProgressModel extends RoadmapProgress {
  const RoadmapProgressModel({
    required super.roadmapId,
    required super.totalTopics,
    required super.completedTopics,
    required super.percentage,
    required super.isCompleted,
    super.nextTopic,
    super.lastCompletedTopic,
  });

  factory RoadmapProgressModel.fromJson(Map<String, dynamic> json) {
    return RoadmapProgressModel(
      roadmapId: json['roadmapId'] as String,
      totalTopics: (json['totalTopics'] as num).toInt(),
      completedTopics: (json['completedTopics'] as num).toInt(),
      percentage: (json['percentage'] as num).toInt(),
      isCompleted: json['isCompleted'] as bool? ?? false,
      nextTopic: json['nextTopic'] != null
          ? RoadmapProgressTopicModel.fromJson(
              json['nextTopic'] as Map<String, dynamic>,
            )
          : null,
      lastCompletedTopic: json['lastCompletedTopic'] != null
          ? RoadmapProgressTopicModel.fromJson(
              json['lastCompletedTopic'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roadmapId': roadmapId,
      'totalTopics': totalTopics,
      'completedTopics': completedTopics,
      'percentage': percentage,
      'isCompleted': isCompleted,
      if (nextTopic != null)
        'nextTopic': nextTopic is RoadmapProgressTopicModel
            ? (nextTopic as RoadmapProgressTopicModel).toJson()
            : RoadmapProgressTopicModel(
                id: nextTopic!.id,
                title: nextTopic!.title,
                sequence: nextTopic!.sequence,
                completedAt: nextTopic!.completedAt,
              ).toJson(),
      if (lastCompletedTopic != null)
        'lastCompletedTopic':
            lastCompletedTopic is RoadmapProgressTopicModel
            ? (lastCompletedTopic as RoadmapProgressTopicModel).toJson()
            : RoadmapProgressTopicModel(
                id: lastCompletedTopic!.id,
                title: lastCompletedTopic!.title,
                sequence: lastCompletedTopic!.sequence,
                completedAt: lastCompletedTopic!.completedAt,
              ).toJson(),
    };
  }
}
