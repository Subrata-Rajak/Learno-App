import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learno/core/config/app_config.dart';
import 'package:learno/core/network/api_client.dart';
import 'package:learno/core/network/errors/app_exception.dart';
import 'package:learno/features/roadmap/data/datasources/roadmap_remote_data_source.dart';

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
  group('RoadmapRemoteDataSourceImpl', () {
    const testConfig = AppConfig(
      environment: AppEnvironment.development,
      apiBaseUrl: 'http://localhost:3000',
    );

    late MockHttpClientAdapter mockAdapter;
    late Dio testDio;
    late ApiClient apiClient;
    late RoadmapRemoteDataSourceImpl dataSource;

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
      dataSource = RoadmapRemoteDataSourceImpl(apiClient: apiClient);
    });

    test('getRoadmap fetches from /api/v1/roadmap/:roadmapId on GET', () async {
      mockAdapter.handler = (options, _, _) async {
        expect(options.path, equals('/api/v1/roadmap/rm-100'));
        expect(options.method, equals('GET'));

        return ResponseBody.fromString(
          jsonEncode({
            'success': true,
            'message': 'Roadmap fetched',
            'data': {
              'id': 'rm-100',
              'learningGoalId': 'goal-10',
              'title': 'Flutter Mastery',
              'description': 'Roadmap details',
              'status': 'ACTIVE',
              'createdAt': '2026-11-14T10:00:00.000Z',
              'updatedAt': '2026-11-14T10:00:00.000Z',
              'topics': [
                {
                  'id': 'top-1',
                  'roadmapId': 'rm-100',
                  'title': 'Dart Basics',
                  'description': 'Basics',
                  'sequence': 1,
                  'completedAt': null,
                  'createdAt': '2026-11-14T10:00:00.000Z',
                  'updatedAt': '2026-11-14T10:00:00.000Z',
                },
              ],
            },
          }),
          200,
          headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
        );
      };

      final roadmap = await dataSource.getRoadmap('rm-100');

      expect(roadmap.id, equals('rm-100'));
      expect(roadmap.learningGoalId, equals('goal-10'));
      expect(roadmap.topics.length, equals(1));
      expect(roadmap.topics.first.title, equals('Dart Basics'));
    });

    test('getRoadmapByGoal queries /api/v1/roadmap?learningGoalId=:id', () async {
      mockAdapter.handler = (options, _, _) async {
        expect(
          options.path,
          equals('/api/v1/roadmap?learningGoalId=goal-10'),
        );
        expect(options.method, equals('GET'));

        return ResponseBody.fromString(
          jsonEncode({
            'success': true,
            'message': 'Roadmap fetched',
            'data': {
              'id': 'rm-100',
              'learningGoalId': 'goal-10',
              'title': 'Flutter Mastery',
              'description': 'Roadmap details',
              'status': 'ACTIVE',
              'createdAt': '2026-11-14T10:00:00.000Z',
              'updatedAt': '2026-11-14T10:00:00.000Z',
              'topics': [],
            },
          }),
          200,
          headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
        );
      };

      final roadmap = await dataSource.getRoadmapByGoal('goal-10');

      expect(roadmap.id, equals('rm-100'));
      expect(roadmap.learningGoalId, equals('goal-10'));
    });

    test('getRoadmapProgress calls /api/v1/roadmap/:id/progress on GET', () async {
      mockAdapter.handler = (options, _, _) async {
        expect(options.path, equals('/api/v1/roadmap/rm-100/progress'));
        expect(options.method, equals('GET'));

        return ResponseBody.fromString(
          jsonEncode({
            'success': true,
            'message': 'Roadmap progress fetched',
            'data': {
              'roadmapId': 'rm-100',
              'totalTopics': 4,
              'completedTopics': 1,
              'percentage': 25,
              'isCompleted': false,
              'nextTopic': {
                'id': 'top-2',
                'title': 'Next Step',
                'sequence': 2,
              },
              'lastCompletedTopic': {
                'id': 'top-1',
                'title': 'First Step',
                'sequence': 1,
                'completedAt': '2026-11-14T10:00:00.000Z',
              },
            },
          }),
          200,
          headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
        );
      };

      final progress = await dataSource.getRoadmapProgress('rm-100');

      expect(progress.roadmapId, equals('rm-100'));
      expect(progress.percentage, equals(25));
      expect(progress.nextTopic?.title, equals('Next Step'));
      expect(progress.lastCompletedTopic?.title, equals('First Step'));
    });

    test('completeTopic posts to /api/v1/roadmap/topics/:topicId/complete with empty body', () async {
      mockAdapter.handler = (options, _, _) async {
        expect(options.path, equals('/api/v1/roadmap/topics/top-1/complete'));
        expect(options.method, equals('POST'));
        expect(options.data, equals({}));

        return ResponseBody.fromString(
          jsonEncode({
            'success': true,
            'message': 'Topic marked as completed',
            'data': {
              'id': 'top-1',
              'roadmapId': 'rm-100',
              'title': 'Dart Basics',
              'description': 'Basics',
              'sequence': 1,
              'completedAt': '2026-11-14T10:20:00.000Z',
              'createdAt': '2026-11-14T10:00:00.000Z',
              'updatedAt': '2026-11-14T10:20:00.000Z',
            },
          }),
          200,
          headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
        );
      };

      final topic = await dataSource.completeTopic('top-1');

      expect(topic.id, equals('top-1'));
      expect(topic.isCompleted, isTrue);
      expect(topic.completedAt, isNotNull);
    });

    test('getTopicResources calls /api/v1/roadmap/topics/:topicId/resources without roadmapId', () async {
      mockAdapter.handler = (options, _, _) async {
        expect(options.path, equals('/api/v1/roadmap/topics/top-1/resources'));
        expect(options.method, equals('GET'));

        return ResponseBody.fromString(
          jsonEncode({
            'success': true,
            'message': 'Resources fetched',
            'data': [
              {
                'id': 'res-1',
                'topicId': 'top-1',
                'title': 'Resource 1',
                'url': 'https://example.com/res1',
                'type': 'DOCUMENTATION',
                'sourceName': 'Example',
                'reason': 'Great guide',
                'sequence': 1,
                'createdAt': '2026-11-14T10:00:00.000Z',
                'updatedAt': '2026-11-14T10:00:00.000Z',
              },
            ],
          }),
          200,
          headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
        );
      };

      final resources = await dataSource.getTopicResources('top-1');

      expect(resources.length, equals(1));
      expect(resources.first.title, equals('Resource 1'));
    });

    test('getActiveLearningGoals calls /api/v1/learning-goals on GET', () async {
      mockAdapter.handler = (options, _, _) async {
        expect(options.path, equals('/api/v1/learning-goals'));
        expect(options.method, equals('GET'));

        return ResponseBody.fromString(
          jsonEncode({
            'success': true,
            'message': 'Goals fetched',
            'data': [
              {
                'id': 'goal-1',
                'userId': 'user-1',
                'title': 'Learn Flutter',
                'subject': 'Mobile',
                'description': 'Deep dive',
                'currentLevel': 'BEGINNER',
                'targetOutcome': null,
                'status': 'ACTIVE',
                'createdAt': '2026-11-14T10:00:00.000Z',
                'updatedAt': '2026-11-14T10:00:00.000Z',
              },
            ],
          }),
          200,
          headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
        );
      };

      final goals = await dataSource.getActiveLearningGoals();

      expect(goals.length, equals(1));
      expect(goals.first.title, equals('Learn Flutter'));
    });

    test('throws ServerException when response success is false', () async {
      mockAdapter.handler = (options, _, _) async {
        return ResponseBody.fromString(
          jsonEncode({
            'success': false,
            'message': 'Roadmap not found',
            'error': {'code': 'ROADMAP_NOT_FOUND'},
          }),
          200,
          headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
        );
      };

      expect(
        () => dataSource.getRoadmap('non-existent'),
        throwsA(
          isA<ServerException>().having(
            (e) => e.message,
            'message',
            contains('Roadmap not found'),
          ),
        ),
      );
    });

    test('propagates HTTP 404 error through ApiClient / ErrorHandler', () async {
      mockAdapter.handler = (options, _, _) async {
        return ResponseBody.fromString(
          jsonEncode({
            'success': false,
            'message': 'Roadmap not found',
            'error': {'code': 'ROADMAP_NOT_FOUND'},
          }),
          404,
          headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
        );
      };

      expect(
        () => dataSource.getRoadmap('unknown'),
        throwsA(isA<NotFoundException>()),
      );
    });
  });
}
