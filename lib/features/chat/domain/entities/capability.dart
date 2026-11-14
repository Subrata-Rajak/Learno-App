import 'package:equatable/equatable.dart';

/// Pure domain entity representing a system conversational capability (e.g., LEARN_TOPIC).
class Capability extends Equatable {
  const Capability({
    required this.id,
    required this.key,
    required this.title,
    this.description,
    this.icon,
    required this.status,
    required this.sortOrder,
  });

  /// Unique UUID of the capability.
  final String id;

  /// Unique programmatic key identifier (e.g. `LEARN_TOPIC`).
  final String key;

  /// User-facing display title.
  final String title;

  /// Optional description.
  final String? description;

  /// Optional icon name or identifier.
  final String? icon;

  /// Lifecycle status (e.g. `ACTIVE`, `INACTIVE`).
  final String status;

  /// Sort priority for UI listing.
  final int sortOrder;

  @override
  List<Object?> get props => [
    id,
    key,
    title,
    description,
    icon,
    status,
    sortOrder,
  ];
}
