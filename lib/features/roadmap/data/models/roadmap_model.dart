import 'package:learno/features/roadmap/data/models/roadmap_topic_model.dart';
import 'package:learno/features/roadmap/domain/entities/roadmap.dart';

/// Data model representing a Roadmap returned by `/api/v1/roadmap/:roadmapId`.
class RoadmapModel extends Roadmap {
  const RoadmapModel({
    required super.id,
    required super.learningGoalId,
    required super.title,
    required super.description,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    super.topics = const [],
  });

  factory RoadmapModel.fromJson(Map<String, dynamic> json) {
    final rawTopics = json['topics'] as List<dynamic>?;
    final List<RoadmapTopicModel> parsedTopics = [];

    if (rawTopics != null) {
      for (final item in rawTopics) {
        if (item is Map<String, dynamic>) {
          parsedTopics.add(RoadmapTopicModel.fromJson(item));
        }
      }
      // Guarantee sequential ordering from backend sequence numbers
      parsedTopics.sort((a, b) => a.sequence.compareTo(b.sequence));
    }

    return RoadmapModel(
      id: json['id'] as String,
      learningGoalId: json['learningGoalId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      status: json['status'] as String? ?? 'ACTIVE',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      topics: parsedTopics,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'learningGoalId': learningGoalId,
      'title': title,
      'description': description,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'topics': topics
          .map(
            (t) => t is RoadmapTopicModel
                ? t.toJson()
                : RoadmapTopicModel(
                    id: t.id,
                    roadmapId: t.roadmapId,
                    title: t.title,
                    description: t.description,
                    sequence: t.sequence,
                    completedAt: t.completedAt,
                    createdAt: t.createdAt,
                    updatedAt: t.updatedAt,
                  ).toJson(),
          )
          .toList(),
    };
  }
}
