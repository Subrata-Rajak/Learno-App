import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learno/features/auth/domain/entities/auth_user.dart';
import 'package:learno/features/auth/domain/repositories/auth_repository.dart';
import 'package:learno/features/auth/domain/usecases/login.dart';
import 'package:learno/features/auth/domain/usecases/logout.dart';
import 'package:learno/features/auth/domain/usecases/register.dart';
import 'package:learno/features/auth/domain/usecases/restore_session.dart';
import 'package:learno/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:learno/features/my_learning/presentation/screens/my_learning_screen.dart';
import 'package:learno/features/my_learning/presentation/widgets/my_learning_guest_view.dart';
import 'package:learno/features/my_learning/presentation/widgets/my_learning_journey_card.dart';
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

class FakeAuthRepository implements AuthRepository {
  AuthUser? userToReturn;

  @override
  Future<AuthUser> login({required String email, required String password}) async =>
      userToReturn!;

  @override
  Future<AuthUser> register({
    required String email,
    required String password,
    String? name,
  }) async =>
      userToReturn!;

  @override
  Future<AuthUser?> restoreSession() async => userToReturn;

  @override
  Future<void> logout() async {}

  @override
  Future<bool> refreshSession() async => true;

  @override
  Future<String?> getAccessToken() async => 'token';
}

class MockRoadmapRepository implements RoadmapRepository {
  bool getActiveLearningGoalsCalled = false;

  @override
  Future<List<LearningGoal>> getActiveLearningGoals() async {
    getActiveLearningGoalsCalled = true;
    return [];
  }

  @override
  Future<Roadmap> getRoadmap(String roadmapId) => throw UnimplementedError();

  @override
  Future<Roadmap> getRoadmapByGoal(String learningGoalId) =>
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
  group('MyLearningScreen', () {
    late FakeAuthRepository authRepository;
    late AuthBloc authBloc;
    late MockRoadmapRepository roadmapRepository;
    late RoadmapBloc roadmapBloc;

    final testRoadmap = Roadmap(
      id: 'rm-100',
      learningGoalId: 'goal-1',
      title: 'Flutter Production Mastery',
      description: 'Comprehensive mobile engineering curriculum.',
      status: 'ACTIVE',
      createdAt: DateTime.parse('2026-11-14T10:00:00.000Z'),
      updatedAt: DateTime.parse('2026-11-14T10:00:00.000Z'),
      topics: [
        RoadmapTopic(
          id: 'top-1',
          roadmapId: 'rm-100',
          title: 'Topic 1',
          description: 'Desc',
          sequence: 1,
          completedAt: DateTime.parse('2026-11-14T10:15:00.000Z'),
          createdAt: DateTime.parse('2026-11-14T10:00:00.000Z'),
          updatedAt: DateTime.parse('2026-11-14T10:15:00.000Z'),
        ),
        RoadmapTopic(
          id: 'top-2',
          roadmapId: 'rm-100',
          title: 'Topic 2',
          description: 'Desc',
          sequence: 2,
          completedAt: null,
          createdAt: DateTime.parse('2026-11-14T10:00:00.000Z'),
          updatedAt: DateTime.parse('2026-11-14T10:00:00.000Z'),
        ),
      ],
    );

    setUp(() {
      authRepository = FakeAuthRepository();
      authBloc = AuthBloc(
        login: Login(authRepository),
        register: Register(authRepository),
        restoreSession: RestoreSession(authRepository),
        logout: Logout(authRepository),
      );

      roadmapRepository = MockRoadmapRepository();
      roadmapBloc = RoadmapBloc(
        getRoadmap: GetRoadmap(roadmapRepository),
        getRoadmapByGoal: GetRoadmapByGoal(roadmapRepository),
        getActiveLearningGoals: GetActiveLearningGoals(roadmapRepository),
      );
    });

    tearDown(() {
      authBloc.close();
      roadmapBloc.close();
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: BlocProvider<AuthBloc>.value(
          value: authBloc,
          child: MyLearningScreen(roadmapBloc: roadmapBloc),
        ),
      );
    }

    testWidgets('renders MyLearningGuestView and does not fetch goals when user is unauthenticated', (
      WidgetTester tester,
    ) async {
      authBloc.emit(const AuthUnauthenticated());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(MyLearningGuestView), findsOneWidget);
      expect(find.text('Track Your Learning Journeys'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);

      // Verify protected repository call was NOT made
      expect(roadmapRepository.getActiveLearningGoalsCalled, isFalse);
    });

    testWidgets('renders empty state when authenticated user has no active roadmaps', (
      WidgetTester tester,
    ) async {
      authBloc.emit(
        const AuthAuthenticated(
          user: AuthUser(
            id: 'u1',
            email: 'user@learno.app',
            role: 'USER',
            status: 'ACTIVE',
          ),
        ),
      );
      roadmapBloc.emit(const RoadmapOverviewEmpty());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('No Active Roadmaps Yet'), findsOneWidget);
      expect(find.text('Start with Ask Learno'), findsOneWidget);
    });

    testWidgets('renders error view with retry button when loading roadmaps fails', (
      WidgetTester tester,
    ) async {
      authBloc.emit(
        const AuthAuthenticated(
          user: AuthUser(
            id: 'u1',
            email: 'user@learno.app',
            role: 'USER',
            status: 'ACTIVE',
          ),
        ),
      );
      roadmapBloc.emit(
        const RoadmapOverviewError(message: 'Server connection timeout'),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('Failed to load learning tracks'), findsOneWidget);
      expect(find.text('Server connection timeout'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('renders list of MyLearningJourneyCard widgets when roadmaps exist', (
      WidgetTester tester,
    ) async {
      authBloc.emit(
        const AuthAuthenticated(
          user: AuthUser(
            id: 'u1',
            email: 'user@learno.app',
            role: 'USER',
            status: 'ACTIVE',
          ),
        ),
      );
      roadmapBloc.emit(RoadmapOverviewLoaded(roadmaps: [testRoadmap]));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('My Learning'), findsOneWidget);
      expect(find.byType(MyLearningJourneyCard), findsOneWidget);
      expect(find.text('Flutter Production Mastery'), findsOneWidget);
      expect(
        find.text('Comprehensive mobile engineering curriculum.'),
        findsOneWidget,
      );
      expect(find.text('2 topics'), findsOneWidget);
      expect(find.text('1 of 2 completed'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
      expect(find.text('View Roadmap'), findsOneWidget);
    });
  });
}
