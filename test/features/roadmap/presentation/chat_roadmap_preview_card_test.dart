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
import 'package:learno/features/roadmap/presentation/widgets/chat_roadmap_preview_card.dart';

class MockRoadmapRepository implements RoadmapRepository {
  @override
  Future<Roadmap> getRoadmap(String roadmapId) => throw UnimplementedError();

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
  group('ChatRoadmapPreviewCard', () {
    late MockRoadmapRepository repository;
    late RoadmapBloc bloc;

    final testRoadmap = Roadmap(
      id: 'rm-100',
      learningGoalId: 'goal-1',
      title: 'Full-Stack Dart & Flutter',
      description: 'End to end cross-platform curriculum.',
      status: 'ACTIVE',
      createdAt: DateTime.parse('2026-11-14T10:00:00.000Z'),
      updatedAt: DateTime.parse('2026-11-14T10:00:00.000Z'),
      topics: [
        RoadmapTopic(
          id: 'top-1',
          roadmapId: 'rm-100',
          title: 'Dart Foundations',
          description: 'Language syntax',
          sequence: 1,
          completedAt: null,
          createdAt: DateTime.parse('2026-11-14T10:00:00.000Z'),
          updatedAt: DateTime.parse('2026-11-14T10:00:00.000Z'),
        ),
        RoadmapTopic(
          id: 'top-2',
          roadmapId: 'rm-100',
          title: 'Widget Architecture',
          description: 'Stateful vs stateless',
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

    testWidgets('renders loading state preview card', (WidgetTester tester) async {
      bloc.emit(const RoadmapDetailLoading(roadmapId: 'rm-100'));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatRoadmapPreviewCard(
              roadmapId: 'rm-100',
              roadmapBloc: bloc,
              onExploreJourney: (_) {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Fetching roadmap curriculum...'), findsOneWidget);
    });

    testWidgets('renders error preview card with retry action', (
      WidgetTester tester,
    ) async {
      bloc.emit(
        const RoadmapDetailError(
          message: 'Network connection dropped',
          roadmapId: 'rm-100',
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatRoadmapPreviewCard(
              roadmapId: 'rm-100',
              roadmapBloc: bloc,
              onExploreJourney: (_) {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Unable to load roadmap preview'), findsOneWidget);
      expect(find.text('Network connection dropped'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('renders actual roadmap data and triggers Explore Journey callback', (
      WidgetTester tester,
    ) async {
      String? capturedRoadmapId;
      bloc.emit(RoadmapDetailLoaded(testRoadmap));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatRoadmapPreviewCard(
              roadmapId: 'rm-100',
              roadmapBloc: bloc,
              onExploreJourney: (id) {
                capturedRoadmapId = id;
              },
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('ROADMAP READY'), findsOneWidget);
      expect(find.text('2 Topics'), findsOneWidget);
      expect(find.text('Full-Stack Dart & Flutter'), findsOneWidget);
      expect(
        find.text('End to end cross-platform curriculum.'),
        findsOneWidget,
      );
      expect(find.text('Dart Foundations'), findsOneWidget);
      expect(find.text('Explore Journey'), findsOneWidget);

      await tester.tap(find.text('Explore Journey'));
      await tester.pump();

      expect(capturedRoadmapId, equals('rm-100'));
    });
  });
}
