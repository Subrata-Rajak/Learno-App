import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:learno/features/chat/data/datasources/sse/sse_event.dart';

/// Stream transformer that converts a stream of text chunks into a stream of [SseEvent]s.
class SseStringTransformer extends StreamTransformerBase<String, SseEvent> {
  const SseStringTransformer();

  @override
  Stream<SseEvent> bind(Stream<String> stream) {
    return Stream<SseEvent>.eventTransformed(
      stream,
      (sink) => _SseStringEventSink(sink),
    );
  }
}

class _SseStringEventSink implements EventSink<String> {
  _SseStringEventSink(this._outputSink);

  final EventSink<SseEvent> _outputSink;

  String _buffer = '';
  String? _currentEvent;
  final List<String> _currentDataLines = [];
  String? _currentId;

  @override
  void add(String chunk) {
    _buffer += chunk;
    _processBuffer(isDone: false);
  }

  @override
  void addError(Object error, [StackTrace? stackTrace]) {
    _outputSink.addError(error, stackTrace);
  }

  @override
  void close() {
    _processBuffer(isDone: true);
    _dispatchEvent();
    _outputSink.close();
  }

  void _processBuffer({required bool isDone}) {
    while (_buffer.isNotEmpty) {
      int lineEnd = -1;
      int delimiterLength = 0;

      for (int i = 0; i < _buffer.length; i++) {
        final codeUnit = _buffer.codeUnitAt(i);
        if (codeUnit == 13) {
          // '\r'
          if (i == _buffer.length - 1) {
            // Buffer ends with '\r'. If not done, wait for the next chunk to check for '\n'.
            if (!isDone) {
              return;
            }
            lineEnd = i;
            delimiterLength = 1;
            break;
          } else if (_buffer.codeUnitAt(i + 1) == 10) {
            // '\r\n'
            lineEnd = i;
            delimiterLength = 2;
            break;
          } else {
            // Lone '\r'
            lineEnd = i;
            delimiterLength = 1;
            break;
          }
        } else if (codeUnit == 10) {
          // '\n'
          lineEnd = i;
          delimiterLength = 1;
          break;
        }
      }

      if (lineEnd == -1) {
        if (isDone) {
          final line = _buffer;
          _buffer = '';
          _processLine(line);
        }
        return;
      }

      final line = _buffer.substring(0, lineEnd);
      _buffer = _buffer.substring(lineEnd + delimiterLength);
      _processLine(line);
    }
  }

  void _processLine(String line) {
    if (line.isEmpty) {
      _dispatchEvent();
      return;
    }

    if (line.startsWith(':')) {
      // Comment or heartbeat line: ignore
      return;
    }

    final colonIndex = line.indexOf(':');
    final String field;
    final String value;

    if (colonIndex != -1) {
      field = line.substring(0, colonIndex);
      var rawValue = line.substring(colonIndex + 1);
      if (rawValue.startsWith(' ')) {
        rawValue = rawValue.substring(1);
      }
      value = rawValue;
    } else {
      field = line;
      value = '';
    }

    switch (field) {
      case 'event':
        _currentEvent = value;
        break;
      case 'data':
        _currentDataLines.add(value);
        break;
      case 'id':
        _currentId = value;
        break;
      default:
        // Other fields ignored per SSE specification
        break;
    }
  }

  void _dispatchEvent() {
    if (_currentDataLines.isNotEmpty ||
        _currentEvent != null ||
        _currentId != null) {
      final data = _currentDataLines.join('\n');
      _outputSink.add(
        SseEvent(event: _currentEvent, data: data, id: _currentId),
      );
      _currentEvent = null;
      _currentDataLines.clear();
      _currentId = null;
    }
  }
}

/// Stream transformer that converts raw byte chunks ([Uint8List], e.g. from Dio's [ResponseBody.stream])
/// into a stream of [SseEvent]s.
class SseTransformer extends StreamTransformerBase<Uint8List, SseEvent> {
  const SseTransformer();

  @override
  Stream<SseEvent> bind(Stream<Uint8List> stream) {
    return const SseStringTransformer().bind(utf8.decoder.bind(stream));
  }
}
