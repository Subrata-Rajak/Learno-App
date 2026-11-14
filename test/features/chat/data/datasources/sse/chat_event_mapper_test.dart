import 'package:flutter_test/flutter_test.dart';
import 'package:learno/features/chat/data/datasources/sse/chat_event_mapper.dart';
import 'package:learno/features/chat/data/datasources/sse/sse_event.dart';
import 'package:learno/features/chat/domain/entities/chat_stream_event.dart';

void main() {
  group('ChatEventMapper', () {
    const mapper = ChatEventMapper();

    test('maps token event successfully', () {
      const sse = SseEvent(
        event: 'token',
        data: '{"type":"token","text":"Hello world"}',
      );

      final event = mapper.map(sse);

      expect(event, isA<ChatTokenEvent>());
      expect((event as ChatTokenEvent).text, equals('Hello world'));
    });

    test('maps goal_created milestone event successfully', () {
      const sse = SseEvent(
        event: 'goal_created',
        data: '{"type":"goal_created","goalId":"goal-uuid-123"}',
      );

      final event = mapper.map(sse);

      expect(event, isA<ChatGoalCreatedEvent>());
      expect((event as ChatGoalCreatedEvent).goalId, equals('goal-uuid-123'));
    });

    test('maps roadmap_started milestone event successfully', () {
      const sse = SseEvent(
        event: 'roadmap_started',
        data: '{"type":"roadmap_started","learningGoalId":"goal-uuid-123"}',
      );

      final event = mapper.map(sse);

      expect(event, isA<ChatRoadmapStartedEvent>());
      expect(
        (event as ChatRoadmapStartedEvent).learningGoalId,
        equals('goal-uuid-123'),
      );
    });

    test('maps roadmap_completed milestone event successfully', () {
      const sse = SseEvent(
        event: 'roadmap_completed',
        data: '{"type":"roadmap_completed","roadmapId":"roadmap-uuid-456"}',
      );

      final event = mapper.map(sse);

      expect(event, isA<ChatRoadmapCompletedEvent>());
      expect(
        (event as ChatRoadmapCompletedEvent).roadmapId,
        equals('roadmap-uuid-456'),
      );
    });

    test('maps complete terminal event successfully', () {
      const sse = SseEvent(
        event: 'complete',
        data: '{"message":"Stream generation completed"}',
      );

      final event = mapper.map(sse);

      expect(event, isA<ChatCompleteEvent>());
      expect(
        (event as ChatCompleteEvent).message,
        equals('Stream generation completed'),
      );
    });

    test('maps error terminal event successfully', () {
      const sse = SseEvent(
        event: 'error',
        data: '{"message":"AI service quota exceeded"}',
      );

      final event = mapper.map(sse);

      expect(event, isA<ChatErrorEvent>());
      expect(
        (event as ChatErrorEvent).message,
        equals('AI service quota exceeded'),
      );
    });

    test('preserves unknown future backend event safely without crashing', () {
      const sse = SseEvent(
        event: 'future_milestone',
        data: '{"type":"future_milestone","details":{"level":3}}',
      );

      final event = mapper.map(sse);

      expect(event, isA<ChatUnknownEvent>());
      final unknown = event as ChatUnknownEvent;
      expect(unknown.eventName, equals('future_milestone'));
      expect(unknown.rawPayload, equals(sse.data));
      expect(unknown.data, isA<Map<String, dynamic>>());
      expect(unknown.data['details']['level'], equals(3));
    });

    test('throws SseParseException on malformed JSON for known event', () {
      const sse = SseEvent(event: 'token', data: 'this-is-not-json');

      expect(
        () => mapper.map(sse),
        throwsA(
          isA<SseParseException>().having(
            (e) => e.message,
            'message',
            contains('Malformed JSON payload'),
          ),
        ),
      );
    });

    test('throws SseParseException when token event lacks text field', () {
      const sse = SseEvent(event: 'token', data: '{"type":"token"}');

      expect(
        () => mapper.map(sse),
        throwsA(
          isA<SseParseException>().having(
            (e) => e.message,
            'message',
            contains('Missing or non-string "text" field'),
          ),
        ),
      );
    });

    test('throws SseParseException when goal_created lacks goalId', () {
      const sse = SseEvent(
        event: 'goal_created',
        data: '{"type":"goal_created"}',
      );

      expect(
        () => mapper.map(sse),
        throwsA(
          isA<SseParseException>().having(
            (e) => e.message,
            'message',
            contains('Missing or empty "goalId"'),
          ),
        ),
      );
    });

    test(
      'throws SseParseException when roadmap_started lacks learningGoalId',
      () {
        const sse = SseEvent(
          event: 'roadmap_started',
          data: '{"type":"roadmap_started"}',
        );

        expect(
          () => mapper.map(sse),
          throwsA(
            isA<SseParseException>().having(
              (e) => e.message,
              'message',
              contains('Missing or empty "learningGoalId"'),
            ),
          ),
        );
      },
    );

    test('throws SseParseException when roadmap_completed lacks roadmapId', () {
      const sse = SseEvent(
        event: 'roadmap_completed',
        data: '{"type":"roadmap_completed"}',
      );

      expect(
        () => mapper.map(sse),
        throwsA(
          isA<SseParseException>().having(
            (e) => e.message,
            'message',
            contains('Missing or empty "roadmapId"'),
          ),
        ),
      );
    });
  });
}
