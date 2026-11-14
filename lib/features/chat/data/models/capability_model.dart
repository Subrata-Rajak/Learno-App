import 'package:learno/features/chat/domain/entities/capability.dart';

/// Data model representing a Capability payload returned by `/api/v1/capability`.
class CapabilityModel extends Capability {
  const CapabilityModel({
    required super.id,
    required super.key,
    required super.title,
    super.description,
    super.icon,
    required super.status,
    required super.sortOrder,
  });

  factory CapabilityModel.fromJson(Map<String, dynamic> json) {
    return CapabilityModel(
      id: json['id'] as String,
      key: json['key'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      status: json['status'] as String? ?? 'ACTIVE',
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'title': title,
      if (description != null) 'description': description,
      if (icon != null) 'icon': icon,
      'status': status,
      'sortOrder': sortOrder,
    };
  }
}
