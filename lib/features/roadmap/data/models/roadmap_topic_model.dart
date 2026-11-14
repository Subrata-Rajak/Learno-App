import 'package:learno/features/roadmap/domain/entities/roadmap_topic.dart';

/// Data model representing a Roadmap Topic returned by the roadmap endpoints.
class RoadmapTopicModel extends RoadmapTopic {
  const RoadmapTopicModel({
    required super.id,
    required super.roadmapId,
    required super.title,
    required super.description,
    required super.sequence,
    super.completedAt,
    required super.createdAt,
    required super.updatedAt,
  });

  factory RoadmapTopicModel.fromJson(Map<String, dynamic> json) {
    return RoadmapTopicModel(
      id: json['id'] as String,
      roadmapId: json['roadmapId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      sequence: (json['sequence'] as num).toInt(),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roadmapId': roadmapId,
      'title': title,
      'description': description,
      'sequence': sequence,
      if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
