import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
import 'package:learno/features/roadmap/presentation/bloc/roadmap_state.dart';
import 'package:learno/features/roadmap/presentation/screens/roadmap_detail_screen.dart';

class MockRoadmapRepository implements RoadmapRepository {
  Roadmap? mockRoadmap;
  Exception? errorToThrow;

  @override
  Future<Roadmap> getRoadmap(String roadmapId) async {
    if (errorToThrow != null) throw errorToThrow!;
    return mockRoadmap!;
  }

  @override
  Future<Roadmap> getRoadmapByGoal(String learningGoalId) =>
      throw UnimplementedError();

  @override
  Future<List<LearningGoal>> getActiveLearningGoals() =>
      throw UnimplementedError();

  @override
  Future<RoadmapProgress> getRoadmapProgress(String roadmapId) =>
      throw UnimplementedError();

  @override
  Future<RoadmapTopic> completeTopic(String topicId) =>
      throw UnimplementedError();

  @override
  Future<List<TopicResource>> getTopicResources(String topicId) =>
      throw UnimplementedError();
}

void main() {
  group('RoadmapDetailScreen', () {
    late MockRoadmapRepository repository;
    late RoadmapBloc bloc;

    final testRoadmap = Roadmap(
      id: 'rm-100',
      learningGoalId: 'goal-1',
      title: 'Flutter Architecture Journey',
      description: 'Master BLoC and Clean Architecture step by step.',
      status: 'ACTIVE',
      createdAt: DateTime.parse('2026-11-14T10:00:00.000Z'),
      updatedAt: DateTime.parse('2026-11-14T10:00:00.000Z'),
      topics: [
        RoadmapTopic(
          id: 'top-1',
          roadmapId: 'rm-100',
          title: 'Dart Language Essentials',
          description: 'Records, patterns, and sound null safety.',
          sequence: 1,
          completedAt: DateTime.parse('2026-11-14T10:15:00.000Z'),
          createdAt: DateTime.parse('2026-11-14T10:00:00.000Z'),
          updatedAt: DateTime.parse('2026-11-14T10:15:00.000Z'),
        ),
        RoadmapTopic(
          id: 'top-2',
          roadmapId: 'rm-100',
          title: 'Clean Architecture Layers',
          description: 'Domain, data, and presentation boundaries.',
          sequence: 2,
          completedAt: null,
          createdAt: DateTime.parse('2026-11-14T10:00:00.000Z'),
          updatedAt: DateTime.parse('2026-11-14T10:00:00.000Z'),
        ),
      ],
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

    testWidgets('renders loading indicator when fetching curriculum', (
      WidgetTester tester,
    ) async {
      bloc.emit(const RoadmapDetailLoading(roadmapId: 'rm-100'));

      await tester.pumpWidget(
        MaterialApp(
          home: RoadmapDetailScreen(roadmapId: 'rm-100', roadmapBloc: bloc),
        ),
      );
      await tester.pump();

      expect(find.text('Learning Roadmap'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading curriculum...'), findsOneWidget);
    });

    testWidgets('renders error view with retry button on failure', (
      WidgetTester tester,
    ) async {
      bloc.emit(
        const RoadmapDetailError(
          message: 'Could not connect to service.',
          roadmapId: 'rm-100',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: RoadmapDetailScreen(roadmapId: 'rm-100', roadmapBloc: bloc),
        ),
      );
      await tester.pump();

      expect(find.text('Failed to load roadmap'), findsOneWidget);
      expect(find.text('Could not connect to service.'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('renders roadmap title, progress, and distinct topic statuses', (
      WidgetTester tester,
    ) async {
      bloc.emit(RoadmapDetailLoaded(testRoadmap));

      await tester.pumpWidget(
        MaterialApp(
          home: RoadmapDetailScreen(roadmapId: 'rm-100', roadmapBloc: bloc),
        ),
      );
      await tester.pump();

      // Verify Header & Description
      expect(find.text('Flutter Architecture Journey'), findsOneWidget);
      expect(
        find.text('Master BLoC and Clean Architecture step by step.'),
        findsOneWidget,
      );

      // Verify Progress Card
      expect(find.text('Overall Progress'), findsOneWidget);
      expect(find.text('1 of 2 topics completed'), findsOneWidget);
      expect(find.text('50% DONE'), findsOneWidget);

      // Verify Topics Section
      expect(find.text('TOPICS IN THIS JOURNEY'), findsOneWidget);
      expect(find.text('2 topics'), findsOneWidget);

      // Verify Step 1 (Completed)
      expect(find.text('STEP 1'), findsOneWidget);
      expect(find.text('Dart Language Essentials'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);

      // Verify Step 2 (Up Next / Pending)
      expect(find.text('STEP 2'), findsOneWidget);
      expect(find.text('Clean Architecture Layers'), findsOneWidget);
      expect(find.text('Up Next'), findsOneWidget);
    });
  });
}
