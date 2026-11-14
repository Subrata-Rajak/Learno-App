import 'package:flutter_test/flutter_test.dart';
import 'package:learno/features/roadmap/domain/entities/learning_goal.dart';
import 'package:learno/features/roadmap/domain/entities/roadmap.dart';
import 'package:learno/features/roadmap/domain/entities/roadmap_progress.dart';
import 'package:learno/features/roadmap/domain/entities/roadmap_topic.dart';
import 'package:learno/features/roadmap/domain/entities/topic_resource.dart';
import 'package:learno/features/roadmap/domain/repositories/roadmap_repository.dart';
import 'package:learno/features/roadmap/domain/usecases/complete_topic.dart';
import 'package:learno/features/roadmap/domain/usecases/get_active_learning_goals.dart';
import 'package:learno/features/roadmap/domain/usecases/get_roadmap.dart';
import 'package:learno/features/roadmap/domain/usecases/get_roadmap_by_goal.dart';
import 'package:learno/features/roadmap/domain/usecases/get_roadmap_progress.dart';
import 'package:learno/features/roadmap/domain/usecases/get_topic_resources.dart';

class MockRoadmapRepository implements RoadmapRepository {
  Roadmap? mockRoadmap;
  RoadmapProgress? mockProgress;
  RoadmapTopic? mockTopic;
  List<TopicResource> mockResources = [];
  List<LearningGoal> mockGoals = [];

  String? lastRoadmapIdRequested;
  String? lastLearningGoalIdRequested;
  String? lastTopicIdCompleted;
  String? lastTopicIdResourcesRequested;
  bool getActiveLearningGoalsCalled = false;

  @override
  Future<Roadmap> getRoadmap(String roadmapId) async {
    lastRoadmapIdRequested = roadmapId;
    return mockRoadmap!;
  }

  @override
  Future<Roadmap> getRoadmapByGoal(String learningGoalId) async {
    lastLearningGoalIdRequested = learningGoalId;
    return mockRoadmap!;
  }

  @override
  Future<RoadmapProgress> getRoadmapProgress(String roadmapId) async {
    lastRoadmapIdRequested = roadmapId;
    return mockProgress!;
  }

  @override
  Future<RoadmapTopic> completeTopic(String topicId) async {
    lastTopicIdCompleted = topicId;
    return mockTopic!;
  }

  @override
  Future<List<TopicResource>> getTopicResources(String topicId) async {
    lastTopicIdResourcesRequested = topicId;
    return mockResources;
  }

  @override
  Future<List<LearningGoal>> getActiveLearningGoals() async {
    getActiveLearningGoalsCalled = true;
    return mockGoals;
  }
}

void main() {
  group('Roadmap Use Cases', () {
    late MockRoadmapRepository mockRepository;

    final testRoadmap = Roadmap(
      id: 'rm-1',
      learningGoalId: 'goal-1',
      title: 'Flutter Roadmap',
      description: 'Curriculum',
      status: 'ACTIVE',
      createdAt: DateTime.parse('2026-11-14T10:00:00.000Z'),
      updatedAt: DateTime.parse('2026-11-14T10:00:00.000Z'),
    );

    final testProgress = const RoadmapProgress(
      roadmapId: 'rm-1',
      totalTopics: 5,
      completedTopics: 2,
      percentage: 40,
      isCompleted: false,
    );

    final testTopic = RoadmapTopic(
      id: 'top-1',
      roadmapId: 'rm-1',
      title: 'Topic 1',
      description: 'Desc',
      sequence: 1,
      completedAt: DateTime.parse('2026-11-14T10:30:00.000Z'),
      createdAt: DateTime.parse('2026-11-14T10:00:00.000Z'),
      updatedAt: DateTime.parse('2026-11-14T10:30:00.000Z'),
    );

    final testResource = TopicResource(
      id: 'res-1',
      topicId: 'top-1',
      title: 'Res 1',
      url: 'https://example.com',
      type: 'ARTICLE',
      sourceName: 'Medium',
      reason: 'Overview',
      sequence: 1,
      createdAt: DateTime.parse('2026-11-14T10:00:00.000Z'),
      updatedAt: DateTime.parse('2026-11-14T10:00:00.000Z'),
    );

    final testGoal = LearningGoal(
      id: 'goal-1',
      userId: 'user-1',
      title: 'Goal 1',
      subject: 'Mobile',
      description: 'Desc',
      currentLevel: 'BEGINNER',
      status: 'ACTIVE',
      createdAt: DateTime.parse('2026-11-14T10:00:00.000Z'),
      updatedAt: DateTime.parse('2026-11-14T10:00:00.000Z'),
    );

    setUp(() {
      mockRepository = MockRoadmapRepository();
    });

    test('GetRoadmap delegates to repository.getRoadmap', () async {
      mockRepository.mockRoadmap = testRoadmap;
      final useCase = GetRoadmap(mockRepository);

      final result = await useCase('rm-1');

      expect(mockRepository.lastRoadmapIdRequested, equals('rm-1'));
      expect(result, equals(testRoadmap));
    });

    test('GetRoadmapByGoal delegates to repository.getRoadmapByGoal', () async {
      mockRepository.mockRoadmap = testRoadmap;
      final useCase = GetRoadmapByGoal(mockRepository);

      final result = await useCase('goal-1');

      expect(mockRepository.lastLearningGoalIdRequested, equals('goal-1'));
      expect(result, equals(testRoadmap));
    });

    test('GetRoadmapProgress delegates to repository.getRoadmapProgress', () async {
      mockRepository.mockProgress = testProgress;
      final useCase = GetRoadmapProgress(mockRepository);

      final result = await useCase('rm-1');

      expect(mockRepository.lastRoadmapIdRequested, equals('rm-1'));
      expect(result, equals(testProgress));
    });

    test('CompleteTopic delegates to repository.completeTopic', () async {
      mockRepository.mockTopic = testTopic;
      final useCase = CompleteTopic(mockRepository);

      final result = await useCase('top-1');

      expect(mockRepository.lastTopicIdCompleted, equals('top-1'));
      expect(result, equals(testTopic));
    });

    test('GetTopicResources delegates to repository.getTopicResources', () async {
      mockRepository.mockResources = [testResource];
      final useCase = GetTopicResources(mockRepository);

      final result = await useCase('top-1');

      expect(mockRepository.lastTopicIdResourcesRequested, equals('top-1'));
      expect(result, equals([testResource]));
    });

    test('GetActiveLearningGoals delegates to repository.getActiveLearningGoals', () async {
      mockRepository.mockGoals = [testGoal];
      final useCase = GetActiveLearningGoals(mockRepository);

      final result = await useCase();

      expect(mockRepository.getActiveLearningGoalsCalled, isTrue);
      expect(result, equals([testGoal]));
    });
  });
}
