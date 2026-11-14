import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:learno/features/chat/data/datasources/sse/sse_event.dart';
import 'package:learno/features/chat/data/datasources/sse/sse_transformer.dart';

void main() {
  group('SseStringTransformer & SseTransformer', () {
    test('parses a single event with LF framing', () async {
      const payload = 'event: token\ndata: {"text":"hello"}\n\n';
      final stream = Stream.value(
        payload,
      ).transform(const SseStringTransformer());
      final events = await stream.toList();

      expect(events.length, equals(1));
      expect(events.first.event, equals('token'));
      expect(events.first.data, equals('{"text":"hello"}'));
      expect(events.first.id, isNull);
    });

    test('parses a single event with CRLF framing', () async {
      const payload = 'event: token\r\ndata: {"text":"crlf"}\r\n\r\n';
      final stream = Stream.value(
        payload,
      ).transform(const SseStringTransformer());
      final events = await stream.toList();

      expect(events.length, equals(1));
      expect(events.first.event, equals('token'));
      expect(events.first.data, equals('{"text":"crlf"}'));
    });

    test('parses multiple events in a single chunk', () async {
      const payload =
          'event: token\ndata: 1\n\n'
          'event: token\ndata: 2\n\n'
          'event: complete\ndata: done\n\n';

      final stream = Stream.value(
        payload,
      ).transform(const SseStringTransformer());
      final events = await stream.toList();

      expect(events.length, equals(3));
      expect(events[0].data, equals('1'));
      expect(events[1].data, equals('2'));
      expect(events[2].event, equals('complete'));
      expect(events[2].data, equals('done'));
    });

    test(
      'parses one event split across arbitrary network byte chunks',
      () async {
        final chunks = [
          'eve',
          'nt: to',
          'ken\n',
          'da',
          'ta: {"text":',
          '"split"}\n\n',
        ];

        final stream = Stream.fromIterable(
          chunks,
        ).transform(const SseStringTransformer());
        final events = await stream.toList();

        expect(events.length, equals(1));
        expect(events.first.event, equals('token'));
        expect(events.first.data, equals('{"text":"split"}'));
      },
    );

    test(
      'handles delimiter split across chunks (CR in one chunk, LF in the next)',
      () async {
        final chunks = ['event: token\r\ndata: split-crlf\r', '\n\r', '\n'];

        final stream = Stream.fromIterable(
          chunks,
        ).transform(const SseStringTransformer());
        final events = await stream.toList();

        expect(events.length, equals(1));
        expect(events.first.event, equals('token'));
        expect(events.first.data, equals('split-crlf'));
      },
    );

    test(
      'concatenates multi-line data fields according to SSE specification',
      () async {
        const payload =
            'event: message\n'
            'data: line 1\n'
            'data: line 2\n'
            'data: line 3\n\n';

        final stream = Stream.value(
          payload,
        ).transform(const SseStringTransformer());
        final events = await stream.toList();

        expect(events.length, equals(1));
        expect(events.first.event, equals('message'));
        expect(events.first.data, equals('line 1\nline 2\nline 3'));
      },
    );

    test(
      'ignores comments and heartbeats without emitting empty events',
      () async {
        const payload =
            ': ping heartbeat\n\n'
            ': second comment\n'
            'event: token\n'
            ': another comment inside\n'
            'data: {"text":"heartbeat passed"}\n\n';

        final stream = Stream.value(
          payload,
        ).transform(const SseStringTransformer());
        final events = await stream.toList();

        expect(events.length, equals(1));
        expect(events.first.event, equals('token'));
        expect(events.first.data, equals('{"text":"heartbeat passed"}'));
      },
    );

    test(
      'correctly flushes final event when stream closes without trailing blank line',
      () async {
        const payload = 'event: complete\ndata: {"message":"flushed"}';

        final stream = Stream.value(
          payload,
        ).transform(const SseStringTransformer());
        final events = await stream.toList();

        expect(events.length, equals(1));
        expect(events.first.event, equals('complete'));
        expect(events.first.data, equals('{"message":"flushed"}'));
      },
    );

    test('parses event with id field', () async {
      const payload = 'id: 104\nevent: sync\ndata: ok\n\n';

      final stream = Stream.value(
        payload,
      ).transform(const SseStringTransformer());
      final events = await stream.toList();

      expect(events.length, equals(1));
      expect(events.first.id, equals('104'));
      expect(events.first.event, equals('sync'));
      expect(events.first.data, equals('ok'));
    });

    test(
      'transforms raw Uint8List byte chunks with SseTransformer and multibyte UTF-8',
      () async {
        final utf8Bytes = utf8.encode(
          'event: token\ndata: {"text":"🚀 Learning ✨"}\n\n',
        );
        final chunks = <Uint8List>[
          Uint8List.fromList(utf8Bytes.sublist(0, 15)),
          Uint8List.fromList(utf8Bytes.sublist(15)),
        ];

        final stream = Stream.fromIterable(
          chunks,
        ).transform(const SseTransformer());
        final events = await stream.toList();

        expect(events.length, equals(1));
        expect(events.first.event, equals('token'));
        expect(events.first.data, equals('{"text":"🚀 Learning ✨"}'));
      },
    );

    test(
      'throws SseParseException when decodeJson is called on malformed JSON payload',
      () {
        const invalidEvent = SseEvent(event: 'token', data: '{invalid-json}');

        expect(
          () => invalidEvent.decodeJson(),
          throwsA(
            isA<SseParseException>().having(
              (e) => e.errorCode,
              'errorCode',
              equals('SSE_PARSE_ERROR'),
            ),
          ),
        );
      },
    );

    test('emits nothing when stream is completely empty', () async {
      final stream = const Stream<String>.empty().transform(
        const SseStringTransformer(),
      );
      final events = await stream.toList();

      expect(events, isEmpty);
    });
  });
}
