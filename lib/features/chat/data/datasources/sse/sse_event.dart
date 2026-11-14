import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:learno/core/network/errors/app_exception.dart';

/// Exception thrown when parsing raw Server-Sent Event framing or JSON payload fails.
class SseParseException extends AppException {
  const SseParseException({
    required super.message,
    super.errorCode = 'SSE_PARSE_ERROR',
    super.details,
    this.rawEvent,
    this.cause,
    this.stackTrace,
  });

  /// The raw [SseEvent] that failed parsing, if framing succeeded before payload decoding.
  final SseEvent? rawEvent;

  /// The underlying error or exception.
  final Object? cause;

  /// The stack trace associated with the parse error.
  final StackTrace? stackTrace;

  @override
  List<Object?> get props => [message, errorCode, details, rawEvent, cause];
}

/// Represents an un-decoded Server-Sent Event (SSE) parsed from the HTTP stream.
class SseEvent extends Equatable {
  const SseEvent({this.event, required this.data, this.id});

  /// Optional event name, corresponding to the `event:` field.
  final String? event;

  /// Raw payload string, corresponding to concatenated `data:` lines.
  final String data;

  /// Optional event identifier, corresponding to the `id:` field.
  final String? id;

  /// Decodes [data] as JSON.
  ///
  /// Throws [SseParseException] if JSON decoding fails.
  dynamic decodeJson() {
    try {
      return jsonDecode(data);
    } catch (e, stackTrace) {
      throw SseParseException(
        message: 'Failed to decode SSE data as JSON: $e',
        rawEvent: this,
        cause: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  List<Object?> get props => [event, data, id];

  @override
  String toString() => 'SseEvent(event: $event, id: $id, data: $data)';
}
