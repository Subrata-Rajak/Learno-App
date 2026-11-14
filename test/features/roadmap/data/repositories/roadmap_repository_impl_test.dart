import 'package:flutter_test/flutter_test.dart';
import 'package:learno/core/network/errors/app_exception.dart';
import 'package:learno/features/roadmap/data/datasources/roadmap_remote_data_source.dart';
import 'package:learno/features/roadmap/data/models/learning_goal_model.dart';
import 'package:learno/features/roadmap/data/models/roadmap_model.dart';
import 'package:learno/features/roadmap/data/models/roadmap_progress_model.dart';
import 'package:learno/features/roadmap/data/models/roadmap_topic_model.dart';
import 'package:learno/features/roadmap/data/models/topic_resource_model.dart';
import 'package:learno/features/roadmap/data/repositories/roadmap_repository_impl.dart';

class FakeRoadmapRemoteDataSource implements RoadmapRemoteDataSource {
  RoadmapModel? roadmapToReturn;
  RoadmapProgressModel? progressToReturn;
  RoadmapTopicModel? topicToReturn;
  List<TopicResourceModel> resourcesToReturn = [];
  List<LearningGoalModel> goalsToReturn = [];
  Exception? exceptionToThrow;

  @override
  Future<RoadmapModel> getRoadmap(String roadmapId) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return roadmapToReturn!;
  }

  @override
  Future<RoadmapModel> getRoadmapByGoal(String learningGoalId) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return roadmapToReturn!;
  }

  @override
  Future<RoadmapProgressModel> getRoadmapProgress(String roadmapId) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return progressToReturn!;
  }

  @override
  Future<RoadmapTopicModel> completeTopic(String topicId) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return topicToReturn!;
  }

  @override
  Future<List<TopicResourceModel>> getTopicResources(String topicId) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return resourcesToReturn;
  }

  @override
  Future<List<LearningGoalModel>> getActiveLearningGoals() async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return goalsToReturn;
  }
}

void main() {
  group('RoadmapRepositoryImpl', () {
    late FakeRoadmapRemoteDataSource fakeDataSource;
    late RoadmapRepositoryImpl repository;

    final testRoadmap = RoadmapModel(
      id: 'rm-1',
      learningGoalId: 'goal-1',
      title: 'Flutter Architecture',
      description: 'Comprehensive curriculum',
      status: 'ACTIVE',
      createdAt: DateTime.parse('2026-11-14T10:00:00.000Z'),
      updatedAt: DateTime.parse('2026-11-14T10:00:00.000Z'),
      topics: [
        RoadmapTopicModel(
          id: 'top-1',
          roadmapId: 'rm-1',
          title: 'Topic 1',
          description: 'Desc 1',
          sequence: 1,
          completedAt: null,
          createdAt: DateTime.parse('2026-11-14T10:00:00.000Z'),
          updatedAt: DateTime.parse('2026-11-14T10:00:00.000Z'),
        ),
      ],
    );

    final testProgress = const RoadmapProgressModel(
      roadmapId: 'rm-1',
      totalTopics: 1,
      completedTopics: 0,
      percentage: 0,
      isCompleted: false,
    );

    final testTopic = RoadmapTopicModel(
      id: 'top-1',
      roadmapId: 'rm-1',
      title: 'Topic 1',
      description: 'Desc 1',
      sequence: 1,
      completedAt: DateTime.parse('2026-11-14T10:30:00.000Z'),
      createdAt: DateTime.parse('2026-11-14T10:00:00.000Z'),
      updatedAt: DateTime.parse('2026-11-14T10:30:00.000Z'),
    );

    final testResource = TopicResourceModel(
      id: 'res-1',
      topicId: 'top-1',
      title: 'Resource 1',
      url: 'https://example.com',
      type: 'DOCUMENTATION',
      sourceName: 'Example',
      reason: 'Reason 1',
      sequence: 1,
      createdAt: DateTime.parse('2026-11-14T10:00:00.000Z'),
      updatedAt: DateTime.parse('2026-11-14T10:00:00.000Z'),
    );

    final testGoal = LearningGoalModel(
      id: 'goal-1',
      userId: 'user-1',
      title: 'Learn Flutter',
      subject: 'Mobile',
      description: 'Desc',
      currentLevel: 'BEGINNER',
      status: 'ACTIVE',
      createdAt: DateTime.parse('2026-11-14T10:00:00.000Z'),
      updatedAt: DateTime.parse('2026-11-14T10:00:00.000Z'),
    );

    setUp(() {
      fakeDataSource = FakeRoadmapRemoteDataSource();
      repository = RoadmapRepositoryImpl(remoteDataSource: fakeDataSource);
    });

    test('getRoadmap returns domain Roadmap entity on success', () async {
      fakeDataSource.roadmapToReturn = testRoadmap;

      final result = await repository.getRoadmap('rm-1');

      expect(result.id, equals('rm-1'));
      expect(result.title, equals('Flutter Architecture'));
      expect(result.topics.length, equals(1));
    });

    test('getRoadmapByGoal returns domain Roadmap entity on success', () async {
      fakeDataSource.roadmapToReturn = testRoadmap;

      final result = await repository.getRoadmapByGoal('goal-1');

      expect(result.id, equals('rm-1'));
      expect(result.learningGoalId, equals('goal-1'));
    });

    test('getRoadmapProgress returns domain RoadmapProgress entity', () async {
      fakeDataSource.progressToReturn = testProgress;

      final result = await repository.getRoadmapProgress('rm-1');

      expect(result.roadmapId, equals('rm-1'));
      expect(result.percentage, equals(0));
    });

    test('completeTopic returns updated RoadmapTopic entity', () async {
      fakeDataSource.topicToReturn = testTopic;

      final result = await repository.completeTopic('top-1');

      expect(result.id, equals('top-1'));
      expect(result.isCompleted, isTrue);
    });

    test('getTopicResources returns list of TopicResource entities', () async {
      fakeDataSource.resourcesToReturn = [testResource];

      final result = await repository.getTopicResources('top-1');

      expect(result.length, equals(1));
      expect(result.first.title, equals('Resource 1'));
    });

    test('getActiveLearningGoals returns list of LearningGoal entities', () async {
      fakeDataSource.goalsToReturn = [testGoal];

      final result = await repository.getActiveLearningGoals();

      expect(result.length, equals(1));
      expect(result.first.title, equals('Learn Flutter'));
    });

    test('rethrows AppException without wrapping', () async {
      fakeDataSource.exceptionToThrow = const NotFoundException(
        message: 'Roadmap not found',
        errorCode: 'ROADMAP_NOT_FOUND',
      );

      expect(
        () => repository.getRoadmap('rm-999'),
        throwsA(
          isA<NotFoundException>().having(
            (e) => e.errorCode,
            'errorCode',
            equals('ROADMAP_NOT_FOUND'),
          ),
        ),
      );
    });

    test('maps unknown exception to AppException via ErrorHandler', () async {
      fakeDataSource.exceptionToThrow = Exception('Network socket closed');

      expect(
        () => repository.getRoadmap('rm-1'),
        throwsA(isA<AppException>()),
      );
    });
  });
}
