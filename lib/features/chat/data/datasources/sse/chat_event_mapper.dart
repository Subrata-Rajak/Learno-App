import 'dart:convert';
import 'package:learno/features/chat/data/datasources/sse/sse_event.dart';
import 'package:learno/features/chat/domain/entities/chat_stream_event.dart';

/// Maps raw [SseEvent]s from the backend into typed domain [ChatStreamEvent]s.
class ChatEventMapper {
  const ChatEventMapper();

  /// Converts a single [SseEvent] into a typed [ChatStreamEvent].
  ///
  /// Throws [SseParseException] if a known event type contains invalid or malformed data.
  ChatStreamEvent map(SseEvent sseEvent) {
    dynamic decodedJson;
    bool isJsonValid = false;

    try {
      decodedJson = jsonDecode(sseEvent.data);
      isJsonValid = true;
    } catch (_) {
      isJsonValid = false;
    }

    final Map<String, dynamic>? dataMap = decodedJson is Map<String, dynamic>
        ? decodedJson
        : null;

    final String effectiveEvent =
        sseEvent.event ?? (dataMap?['type'] as String?) ?? 'unknown';

    switch (effectiveEvent) {
      case 'token':
        if (!isJsonValid || dataMap == null) {
          throw SseParseException(
            message: 'Malformed JSON payload in token event: ${sseEvent.data}',
            rawEvent: sseEvent,
          );
        }
        final text = dataMap['text'];
        if (text is! String) {
          throw SseParseException(
            message:
                'Missing or non-string "text" field in token event: ${sseEvent.data}',
            rawEvent: sseEvent,
          );
        }
        return ChatTokenEvent(text: text);

      case 'goal_created':
        if (!isJsonValid || dataMap == null) {
          throw SseParseException(
            message:
                'Malformed JSON payload in goal_created event: ${sseEvent.data}',
            rawEvent: sseEvent,
          );
        }
        final goalId = dataMap['goalId'];
        if (goalId is! String || goalId.isEmpty) {
          throw SseParseException(
            message:
                'Missing or empty "goalId" field in goal_created event: ${sseEvent.data}',
            rawEvent: sseEvent,
          );
        }
        return ChatGoalCreatedEvent(goalId: goalId);

      case 'roadmap_started':
        if (!isJsonValid || dataMap == null) {
          throw SseParseException(
            message:
                'Malformed JSON payload in roadmap_started event: ${sseEvent.data}',
            rawEvent: sseEvent,
          );
        }
        final learningGoalId = dataMap['learningGoalId'];
        if (learningGoalId is! String || learningGoalId.isEmpty) {
          throw SseParseException(
            message:
                'Missing or empty "learningGoalId" in roadmap_started event: ${sseEvent.data}',
            rawEvent: sseEvent,
          );
        }
        return ChatRoadmapStartedEvent(learningGoalId: learningGoalId);

      case 'roadmap_completed':
        if (!isJsonValid || dataMap == null) {
          throw SseParseException(
            message:
                'Malformed JSON payload in roadmap_completed event: ${sseEvent.data}',
            rawEvent: sseEvent,
          );
        }
        final roadmapId = dataMap['roadmapId'];
        if (roadmapId is! String || roadmapId.isEmpty) {
          throw SseParseException(
            message:
                'Missing or empty "roadmapId" in roadmap_completed event: ${sseEvent.data}',
            rawEvent: sseEvent,
          );
        }
        return ChatRoadmapCompletedEvent(roadmapId: roadmapId);

      case 'complete':
        final message =
            dataMap?['message'] as String? ?? 'Generation completed';
        return ChatCompleteEvent(message: message);

      case 'error':
        final message =
            dataMap?['message'] as String? ?? 'AI generation failed';
        return ChatErrorEvent(message: message);

      default:
        // Safely preserve unknown event names without crashing
        return ChatUnknownEvent(
          eventName: effectiveEvent,
          rawPayload: sseEvent.data,
          data: decodedJson,
        );
    }
  }
}
