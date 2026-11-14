import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learno/core/config/app_config.dart';
import 'package:learno/core/network/api_client.dart';
import 'package:learno/core/network/errors/app_exception.dart';
import 'package:learno/features/chat/data/datasources/chat_remote_data_source.dart';

class MockHttpClientAdapter implements HttpClientAdapter {
  MockHttpClientAdapter({this.handler});

  Future<ResponseBody> Function(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  )?
  handler;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (handler != null) {
      return handler!(options, requestStream, cancelFuture);
    }
    throw UnimplementedError('Unhandled request for ${options.path}');
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('ChatRemoteDataSourceImpl', () {
    const testConfig = AppConfig(
      environment: AppEnvironment.development,
      apiBaseUrl: 'http://localhost:3000',
    );

    late MockHttpClientAdapter mockAdapter;
    late Dio testDio;
    late ApiClient apiClient;
    late ChatRemoteDataSourceImpl dataSource;

    setUp(() {
      mockAdapter = MockHttpClientAdapter();
      testDio = Dio(
        BaseOptions(
          baseUrl: testConfig.apiBaseUrl,
          responseType: ResponseType.json,
          contentType: Headers.jsonContentType,
        ),
      );
      testDio.httpClientAdapter = mockAdapter;

      apiClient = ApiClient(config: testConfig, customDio: testDio);
      dataSource = ChatRemoteDataSourceImpl(apiClient: apiClient);
    });

    test(
      'getCapabilities returns list of CapabilityModel on 200 success',
      () async {
        mockAdapter.handler = (options, _, _) async {
          expect(options.path, equals('/api/v1/capability'));
          expect(options.method, equals('GET'));

          return ResponseBody.fromString(
            jsonEncode({
              'success': true,
              'message': 'Capabilities fetched',
              'data': [
                {
                  'id': 'cap-1',
                  'key': 'LEARN_TOPIC',
                  'title': 'Learn a New Topic',
                  'description': 'Guided roadmap creation',
                  'icon': 'school',
                  'status': 'ACTIVE',
                  'sortOrder': 1,
                },
              ],
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        };

        final capabilities = await dataSource.getCapabilities();

        expect(capabilities.length, equals(1));
        expect(capabilities.first.id, equals('cap-1'));
        expect(capabilities.first.key, equals('LEARN_TOPIC'));
        expect(capabilities.first.title, equals('Learn a New Topic'));
      },
    );

    test(
      'createConversation sends capabilityId and parses ConversationModel on 201 success',
      () async {
        mockAdapter.handler = (options, _, _) async {
          expect(options.path, equals('/api/v1/conversation'));
          expect(options.method, equals('POST'));
          expect(options.data, equals({'capabilityId': 'cap-1'}));

          return ResponseBody.fromString(
            jsonEncode({
              'success': true,
              'message': 'Conversation created',
              'data': {
                'id': 'conv-100',
                'userId': 'user-1',
                'capabilityId': 'cap-1',
                'learningGoalId': null,
                'status': 'ACTIVE',
                'createdAt': '2026-11-14T10:00:00.000Z',
                'updatedAt': '2026-11-14T10:00:00.000Z',
              },
            }),
            201,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        };

        final conversation = await dataSource.createConversation(
          capabilityId: 'cap-1',
        );

        expect(conversation.id, equals('conv-100'));
        expect(conversation.capabilityId, equals('cap-1'));
        expect(conversation.status, equals('ACTIVE'));
        expect(conversation.learningGoalId, isNull);
      },
    );

    test(
      'getConversation retrieves single ConversationModel by conversationId',
      () async {
        mockAdapter.handler = (options, _, _) async {
          expect(options.path, equals('/api/v1/conversation/conv-100'));
          expect(options.method, equals('GET'));

          return ResponseBody.fromString(
            jsonEncode({
              'success': true,
              'message': 'Conversation retrieved',
              'data': {
                'id': 'conv-100',
                'userId': 'user-1',
                'capabilityId': 'cap-1',
                'learningGoalId': 'goal-1',
                'status': 'ACTIVE',
                'createdAt': '2026-11-14T10:00:00.000Z',
                'updatedAt': '2026-11-14T10:05:00.000Z',
              },
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        };

        final conversation = await dataSource.getConversation(
          conversationId: 'conv-100',
        );

        expect(conversation.id, equals('conv-100'));
        expect(conversation.learningGoalId, equals('goal-1'));
      },
    );

    test('getConversations lists all user conversations', () async {
      mockAdapter.handler = (options, _, _) async {
        expect(options.path, equals('/api/v1/conversation'));
        expect(options.method, equals('GET'));

        return ResponseBody.fromString(
          jsonEncode({
            'success': true,
            'message': 'Conversations retrieved',
            'data': [
              {
                'id': 'conv-1',
                'userId': 'user-1',
                'capabilityId': 'cap-1',
                'learningGoalId': null,
                'status': 'ACTIVE',
                'createdAt': '2026-11-14T10:00:00.000Z',
                'updatedAt': '2026-11-14T10:00:00.000Z',
              },
            ],
          }),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };

      final conversations = await dataSource.getConversations();

      expect(conversations.length, equals(1));
      expect(conversations.first.id, equals('conv-1'));
    });

    test(
      'getConversationMessages returns historical messages ordered by sequence',
      () async {
        mockAdapter.handler = (options, _, _) async {
          expect(options.path, equals('/api/v1/conversation/message/conv-100'));
          expect(options.method, equals('GET'));

          return ResponseBody.fromString(
            jsonEncode({
              'success': true,
              'message': 'Messages retrieved',
              'data': [
                {
                  'id': 'msg-1',
                  'conversationId': 'conv-100',
                  'role': 'USER',
                  'content': 'I want to learn Dart',
                  'sequence': 1,
                  'createdAt': '2026-11-14T10:00:01.000Z',
                },
                {
                  'id': 'msg-2',
                  'conversationId': 'conv-100',
                  'role': 'ASSISTANT',
                  'content': 'Great! What is your experience level?',
                  'sequence': 2,
                  'createdAt': '2026-11-14T10:00:05.000Z',
                },
              ],
            }),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        };

        final messages = await dataSource.getConversationMessages(
          conversationId: 'conv-100',
        );

        expect(messages.length, equals(2));
        expect(messages[0].role, equals('USER'));
        expect(messages[0].sequence, equals(1));
        expect(messages[1].role, equals('ASSISTANT'));
        expect(messages[1].sequence, equals(2));
      },
    );

    test('streamChat streams SSE events including complete', () async {
      mockAdapter.handler = (options, _, _) async {
        expect(options.path, equals('/api/v1/conversation/conv-100/chat'));
        expect(options.method, equals('POST'));
        expect(options.data, equals({'content': 'Teach me BLoC'}));
        expect(options.responseType, equals(ResponseType.stream));
        expect(options.headers['Accept'], equals('text/event-stream'));

        final sseRaw =
            'event: token\ndata: {"type":"token","text":"Hello"}\n\n'
            'event: complete\ndata: {"message":"Done"}\n\n';

        final byteStream = Stream.value(
          Uint8List.fromList(utf8.encode(sseRaw)),
        );

        return ResponseBody(
          byteStream,
          200,
          headers: {
            Headers.contentTypeHeader: ['text/event-stream'],
          },
        );
      };

      final stream = dataSource.streamChat(
        conversationId: 'conv-100',
        content: 'Teach me BLoC',
      );

      final events = await stream.toList();

      expect(events.length, equals(2));
      expect(events[0].event, equals('token'));
      expect(events[0].data, equals('{"type":"token","text":"Hello"}'));
      expect(events[1].event, equals('complete'));
    });

    test(
      'streamChat propagates HTTP error occurring before stream begins',
      () async {
        mockAdapter.handler = (options, _, _) async {
          return ResponseBody.fromString(
            jsonEncode({
              'success': false,
              'message': 'Conversation session has expired',
              'error': {'code': 'UNAUTHORIZED'},
            }),
            401,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        };

        final stream = dataSource.streamChat(
          conversationId: 'conv-100',
          content: 'Teach me BLoC',
        );

        expect(
          stream.toList(),
          throwsA(
            isA<UnauthorizedException>().having(
              (e) => e.message,
              'message',
              contains('Conversation session has expired'),
            ),
          ),
        );
      },
    );

    test(
      'streamChat throws ServerException when stream terminates prematurely without complete or error',
      () async {
        mockAdapter.handler = (options, _, _) async {
          // Stream closes immediately after one token without emitting complete or error
          final sseRaw =
              'event: token\ndata: {"type":"token","text":"Cut off"}\n\n';
          final byteStream = Stream.value(
            Uint8List.fromList(utf8.encode(sseRaw)),
          );

          return ResponseBody(
            byteStream,
            200,
            headers: {
              Headers.contentTypeHeader: ['text/event-stream'],
            },
          );
        };

        final stream = dataSource.streamChat(
          conversationId: 'conv-100',
          content: 'Teach me BLoC',
        );

        expect(
          stream.toList(),
          throwsA(
            isA<ServerException>().having(
              (e) => e.errorCode,
              'errorCode',
              equals('STREAM_PREMATURE_TERMINATION'),
            ),
          ),
        );
      },
    );

    test(
      'streamChat propagates CancellationException when CancelToken is cancelled',
      () async {
        final cancelToken = CancelToken();

        mockAdapter.handler = (options, _, cancelFuture) async {
          final controller = StreamController<Uint8List>();

          // Trigger cancel shortly after stream setup
          cancelFuture?.then((_) {
            controller.addError(
              DioException.requestCancelled(
                requestOptions: options,
                reason: 'User cancelled stream',
              ),
            );
          });

          return ResponseBody(
            controller.stream,
            200,
            headers: {
              Headers.contentTypeHeader: ['text/event-stream'],
            },
          );
        };

        final stream = dataSource.streamChat(
          conversationId: 'conv-100',
          content: 'Teach me BLoC',
          cancelToken: cancelToken,
        );

        // Cancel the token
        cancelToken.cancel('User requested stop');

        expect(
          stream.toList(),
          throwsA(
            isA<CancellationException>().having(
              (e) => e.errorCode,
              'errorCode',
              equals('REQUEST_CANCELLED'),
            ),
          ),
        );
      },
    );
  });
}
