import 'package:flutter_test/flutter_test.dart';
import 'package:learno/core/network/errors/app_exception.dart';
import 'package:learno/features/roadmap/domain/entities/learning_goal.dart';
import 'package:learno/features/roadmap/domain/entities/roadmap.dart';
import 'package:learno/features/roadmap/domain/entities/roadmap_progress.dart';
import 'package:learno/features/roadmap/domain/entities/roadmap_topic.dart';
import 'package:learno/features/roadmap/domain/entities/topic_resource.dart';
import 'package:learno/features/roadmap/domain/repositories/roadmap_repository.dart';
import 'package:learno/features/roadmap/domain/usecases/get_active_learning_goals.dart';
import 'package:learno/features/roadmap/domain/usecases/get_roadmap.dart';
import 'package:learno/features/roadmap/domain/usecases/get_roadmap_by_goal.dart';
import 'package:learno/features/roadmap/presentation/bloc/roadmap_bloc.dart';
import 'package:learno/features/roadmap/presentation/bloc/roadmap_event.dart';
import 'package:learno/features/roadmap/presentation/bloc/roadmap_state.dart';

class MockRoadmapRepository implements RoadmapRepository {
  Roadmap? mockRoadmap;
  final Map<String, Roadmap> goalToRoadmap = {};
  List<LearningGoal> mockGoals = [];
  Exception? errorToThrow;

  @override
  Future<Roadmap> getRoadmap(String roadmapId) async {
    if (errorToThrow != null) throw errorToThrow!;
    return mockRoadmap!;
  }

  @override
  Future<Roadmap> getRoadmapByGoal(String learningGoalId) async {
    if (errorToThrow != null) throw errorToThrow!;
    if (goalToRoadmap.containsKey(learningGoalId)) {
      return goalToRoadmap[learningGoalId]!;
    }
    throw const NotFoundException(
      message: 'Roadmap not found',
      errorCode: 'ROADMAP_NOT_FOUND',
    );
  }

  @override
  Future<List<LearningGoal>> getActiveLearningGoals() async {
    if (errorToThrow != null) throw errorToThrow!;
    return mockGoals;
  }

  @override
  Future<RoadmapProgress> getRoadmapProgress(String roadmapId) {
    throw UnimplementedError();
  }

  @override
  Future<RoadmapTopic> completeTopic(String topicId) {
    throw UnimplementedError();
  }

  @override
  Future<List<TopicResource>> getTopicResources(String topicId) {
    throw UnimplementedError();
  }
}

void main() {
  group('RoadmapBloc', () {
    late MockRoadmapRepository repository;
    late RoadmapBloc bloc;

    final testRoadmap = Roadmap(
      id: 'rm-100',
      learningGoalId: 'goal-1',
      title: 'Flutter Architecture',
      description: 'Master BLoC and Clean Architecture',
      status: 'ACTIVE',
      createdAt: DateTime.parse('2026-11-14T10:00:00.000Z'),
      updatedAt: DateTime.parse('2026-11-14T10:00:00.000Z'),
      topics: [
        RoadmapTopic(
          id: 'top-1',
          roadmapId: 'rm-100',
          title: 'Dart Basics',
          description: 'Types and patterns',
          sequence: 1,
          completedAt: DateTime.parse('2026-11-14T10:15:00.000Z'),
          createdAt: DateTime.parse('2026-11-14T10:00:00.000Z'),
          updatedAt: DateTime.parse('2026-11-14T10:15:00.000Z'),
        ),
      ],
    );

    final testGoal1 = LearningGoal(
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

    final testGoal2 = LearningGoal(
      id: 'goal-2',
      userId: 'user-1',
      title: 'Goal 2',
      subject: 'Backend',
      description: 'Desc',
      currentLevel: 'INTERMEDIATE',
      status: 'ACTIVE',
      createdAt: DateTime.parse('2026-11-14T10:00:00.000Z'),
      updatedAt: DateTime.parse('2026-11-14T10:00:00.000Z'),
    );

    setUp(() {
      repository = MockRoadmapRepository();
      bloc = RoadmapBloc(
        getRoadmap: GetRoadmap(repository),
        getRoadmapByGoal: GetRoadmapByGoal(repository),
        getActiveLearningGoals: GetActiveLearningGoals(repository),
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is RoadmapInitial', () {
      expect(bloc.state, equals(const RoadmapInitial()));
    });

    group('RoadmapDetailRequested', () {
      test('emits [RoadmapDetailLoading, RoadmapDetailLoaded] on success', () async {
        repository.mockRoadmap = testRoadmap;

        final expected = [
          const RoadmapDetailLoading(roadmapId: 'rm-100'),
          RoadmapDetailLoaded(testRoadmap),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));

        bloc.add(const RoadmapDetailRequested('rm-100'));
      });

      test('emits [RoadmapDetailLoading, RoadmapDetailError] on failure', () async {
        repository.errorToThrow = const ServerException(
          message: 'Failed to connect to backend',
          errorCode: 'SERVER_ERROR',
        );

        final expected = [
          const RoadmapDetailLoading(roadmapId: 'rm-100'),
          const RoadmapDetailError(
            message: 'Failed to connect to backend',
            roadmapId: 'rm-100',
          ),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));

        bloc.add(const RoadmapDetailRequested('rm-100'));
      });

      test('emits RoadmapDetailError immediately when roadmapId is empty', () async {
        final expected = [
          const RoadmapDetailError(
            message: 'Invalid roadmap ID.',
            roadmapId: '',
          ),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));

        bloc.add(const RoadmapDetailRequested('   '));
      });

      test('supports retry after error', () async {
        repository.errorToThrow = const ServerException(
          message: 'Network glitch',
          errorCode: 'NETWORK_ERROR',
        );

        bloc.add(const RoadmapDetailRequested('rm-100'));
        await pumpEventQueue();

        expect(bloc.state, isA<RoadmapDetailError>());

        // Fix error and retry
        repository.errorToThrow = null;
        repository.mockRoadmap = testRoadmap;

        final retryExpected = [
          const RoadmapDetailLoading(roadmapId: 'rm-100'),
          RoadmapDetailLoaded(testRoadmap),
        ];

        expectLater(bloc.stream, emitsInOrder(retryExpected));

        bloc.add(const RoadmapDetailRequested('rm-100'));
      });
    });

    group('RoadmapOverviewRequested', () {
      test('emits [RoadmapOverviewLoading, RoadmapOverviewLoaded] when goals have roadmaps', () async {
        repository.mockGoals = [testGoal1];
        repository.goalToRoadmap[testGoal1.id] = testRoadmap;

        final expected = [
          const RoadmapOverviewLoading(),
          RoadmapOverviewLoaded(roadmaps: [testRoadmap]),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));

        bloc.add(const RoadmapOverviewRequested());
      });

      test('emits [RoadmapOverviewLoading, RoadmapOverviewEmpty] when no active goals exist', () async {
        repository.mockGoals = [];

        final expected = [
          const RoadmapOverviewLoading(),
          const RoadmapOverviewEmpty(),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));

        bloc.add(const RoadmapOverviewRequested());
      });

      test('handles partial failure gracefully when one goal has no roadmap', () async {
        // goal1 has a roadmap; goal2 does not have a roadmap (throws 404)
        repository.mockGoals = [testGoal1, testGoal2];
        repository.goalToRoadmap[testGoal1.id] = testRoadmap;

        final expected = [
          const RoadmapOverviewLoading(),
          RoadmapOverviewLoaded(roadmaps: [testRoadmap]),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));

        bloc.add(const RoadmapOverviewRequested());
      });

      test('emits RoadmapOverviewEmpty when all goals have no associated roadmaps', () async {
        repository.mockGoals = [testGoal1, testGoal2];
        // Neither goal has a roadmap in goalToRoadmap -> both throw NotFoundException

        final expected = [
          const RoadmapOverviewLoading(),
          const RoadmapOverviewEmpty(),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));

        bloc.add(const RoadmapOverviewRequested());
      });

      test('emits [RoadmapOverviewLoading, RoadmapOverviewError] when getActiveLearningGoals throws', () async {
        repository.errorToThrow = const ServerException(
          message: 'Database connection failed',
          errorCode: 'DB_ERROR',
        );

        final expected = [
          const RoadmapOverviewLoading(),
          const RoadmapOverviewError(message: 'Database connection failed'),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));

        bloc.add(const RoadmapOverviewRequested());
      });
    });
  });
}
