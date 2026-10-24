import 'package:flutter_test/flutter_test.dart';
import 'package:learno/app/learno_app.dart';

void main() {
  testWidgets('LearnoApp smoke test', (WidgetTester tester) async {
    // Build LearnoApp and trigger a frame.
    await tester.pumpWidget(const LearnoApp());

    // Verify that the initial placeholder and title render.
    expect(find.text('Learno'), findsOneWidget);
  });
}
