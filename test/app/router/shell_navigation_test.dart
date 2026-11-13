import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learno/app/learno_app.dart';
import 'package:learno/core/di/injection.dart';
import 'package:learno/features/ask_learno/presentation/screens/ask_learno_screen.dart';
import 'package:learno/features/home/presentation/screens/home_screen.dart';
import 'package:learno/features/home/presentation/widgets/learno_bottom_nav.dart';
import 'package:learno/features/my_learning/presentation/screens/my_learning_screen.dart';
import 'package:learno/features/profile/presentation/screens/profile_screen.dart';
import 'package:learno/features/progress/presentation/screens/progress_screen.dart';

void main() {
  setUp(() async {
    await resetDependencies();
    await configureDependencies();
  });

  tearDown(() async {
    await resetDependencies();
  });

  group('Shell Navigation', () {
    testWidgets(
      'all five primary destinations are reachable through the shell',
      (WidgetTester tester) async {
        await tester.pumpWidget(const LearnoApp());
        await tester.pumpAndSettle();

        // 1. Initial destination is Home
        expect(find.byType(HomeScreen), findsOneWidget);
        expect(find.byType(LearnoBottomNav), findsOneWidget);

        // 2. Navigate to Branch 1: My Learning
        await tester.tap(find.text('My Learning'));
        await tester.pumpAndSettle();
        expect(find.byType(MyLearningScreen), findsOneWidget);
        expect(find.text('Roadmaps Coming Soon'), findsOneWidget);

        // 3. Navigate to Branch 2: Ask Learno (Central Distinct Action)
        await tester.tap(find.text('Ask Learno'));
        await tester.pumpAndSettle();
        expect(find.byType(AskLearnoScreen), findsOneWidget);
        expect(find.text('AI Mentor Coming Soon'), findsOneWidget);

        // 4. Navigate to Branch 3: Progress
        await tester.tap(find.text('Progress'));
        await tester.pumpAndSettle();
        expect(find.byType(ProgressScreen), findsOneWidget);
        expect(find.text('Analytics In Development'), findsOneWidget);

        // 5. Navigate to Branch 4: Profile
        await tester.tap(find.text('Profile'));
        await tester.pumpAndSettle();
        expect(find.byType(ProfileScreen), findsOneWidget);
        expect(find.text('Guest Learner'), findsOneWidget);

        // 6. Navigate back to Home (Branch 0)
        await tester.tap(find.text('Home'));
        await tester.pumpAndSettle();
        expect(find.byType(HomeScreen), findsOneWidget);
      },
    );

    testWidgets('switching branches preserves navigation state across tabs', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const LearnoApp());
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);

      // Switch to Ask Learno
      await tester.tap(find.text('Ask Learno'));
      await tester.pumpAndSettle();
      expect(find.byType(AskLearnoScreen), findsOneWidget);

      // Switch to Profile
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();
      expect(find.byType(ProfileScreen), findsOneWidget);

      // Return to Ask Learno
      await tester.tap(find.text('Ask Learno'));
      await tester.pumpAndSettle();
      expect(find.byType(AskLearnoScreen), findsOneWidget);

      // Return to Home
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('Ask Learno central action navigates to named destination', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const LearnoApp());
      await tester.pumpAndSettle();

      // Find the center Ask Learno button icon
      final askButtonFinder = find.widgetWithIcon(
        Container,
        Icons.auto_awesome_rounded,
      );
      expect(askButtonFinder, findsWidgets);

      await tester.tap(find.text('Ask Learno'));
      await tester.pumpAndSettle();

      expect(find.byType(AskLearnoScreen), findsOneWidget);
      expect(find.text('Your conversational AI mentor.'), findsOneWidget);
    });
  });
}
