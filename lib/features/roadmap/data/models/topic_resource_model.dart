import 'package:learno/features/roadmap/domain/entities/topic_resource.dart';

/// Data model representing a Topic Resource returned by `/api/v1/roadmap/topics/:topicId/resources`.
class TopicResourceModel extends TopicResource {
  const TopicResourceModel({
    required super.id,
    required super.topicId,
    required super.title,
    required super.url,
    required super.type,
    required super.sourceName,
    required super.reason,
    required super.sequence,
    required super.createdAt,
    required super.updatedAt,
  });

  factory TopicResourceModel.fromJson(Map<String, dynamic> json) {
    return TopicResourceModel(
      id: json['id'] as String,
      topicId: json['topicId'] as String,
      title: json['title'] as String,
      url: json['url'] as String,
      type: json['type'] as String? ?? 'OTHER',
      sourceName: json['sourceName'] as String,
      reason: json['reason'] as String,
      sequence: (json['sequence'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'topicId': topicId,
      'title': title,
      'url': url,
      'type': type,
      'sourceName': sourceName,
      'reason': reason,
      'sequence': sequence,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
