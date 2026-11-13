import 'package:equatable/equatable.dart';

/// Structured error payload embedded in unsuccessful backend responses.
class ApiErrorData extends Equatable {
  const ApiErrorData({required this.code, this.details});

  /// Backend error code identifier (e.g. `VALIDATION_ERROR`, `UNAUTHORIZED`).
  final String code;

  /// Optional contextual error details (map, list, or primitive).
  final dynamic details;

  factory ApiErrorData.fromJson(Map<String, dynamic> json) {
    return ApiErrorData(
      code: json['code'] as String? ?? 'UNKNOWN_ERROR',
      details: json['details'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'code': code, if (details != null) 'details': details};
  }

  @override
  List<Object?> get props => [code, details];
}

/// Standardized API response envelope matching the Learno backend contract.
class ApiResponse<T> extends Equatable {
  const ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.error,
  });

  /// Whether the operation succeeded on the server.
  final bool success;

  /// Human-readable status or informational message.
  final String message;

  /// Typed payload, present on successful responses.
  final T? data;

  /// Structured error details, present on failed responses.
  final ApiErrorData? error;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json, [
    T Function(dynamic dataJson)? fromJsonT,
  ]) {
    final rawData = json['data'];
    final T? parsedData;
    if (rawData != null && fromJsonT != null) {
      parsedData = fromJsonT(rawData);
    } else if (rawData is T) {
      parsedData = rawData;
    } else {
      parsedData = null;
    }

    final rawError = json['error'];
    final ApiErrorData? parsedError = rawError is Map<String, dynamic>
        ? ApiErrorData.fromJson(rawError)
        : null;

    return ApiResponse<T>(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: parsedData,
      error: parsedError,
    );
  }

  @override
  List<Object?> get props => [success, message, data, error];
}
