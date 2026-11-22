import 'package:flutter_test/flutter_test.dart';
import 'package:winnerlife/main.dart';

void main() {
  testWidgets('WinnerLife app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const WinnerLifeApp());
    await tester.pump(const Duration(seconds: 2));

    // Verify Dashboard title exists
    expect(find.text('WinnerLife Dashboard'), findsOneWidget);
  });
}
