import 'package:equatable/equatable.dart';

/// Pure domain entity representing an AI-curated external learning resource.
class TopicResource extends Equatable {
  const TopicResource({
    required this.id,
    required this.topicId,
    required this.title,
    required this.url,
    required this.type,
    required this.sourceName,
    required this.reason,
    required this.sequence,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Unique UUID of the resource.
  final String id;

  /// ID of the parent topic.
  final String topicId;

  /// Resource title.
  final String title;

  /// Direct URL to the learning resource.
  final String url;

  /// Resource type (e.g. 'DOCUMENTATION', 'VIDEO', 'ARTICLE', 'TUTORIAL', 'OTHER').
  final String type;

  /// Origin publisher or platform (e.g. 'Flutter.dev', 'YouTube').
  final String sourceName;

  /// Pedagogical rationale explaining why this resource was curated.
  final String reason;

  /// Display sequence order.
  final int sequence;

  /// Creation timestamp.
  final DateTime createdAt;

  /// Last update timestamp.
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
    id,
    topicId,
    title,
    url,
    type,
    sourceName,
    reason,
    sequence,
    createdAt,
    updatedAt,
  ];
}
