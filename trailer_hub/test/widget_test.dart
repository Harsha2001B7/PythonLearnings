// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:trailer_hub/main.dart';

void main() {
  testWidgets('TrailerHub app starts and displays', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const TrailerHubApp(),
    );

    // Verify that the app starts without crashing
    expect(find.byType(TrailerHubApp), findsOneWidget);

    // Verify that TrailerHub title appears (from AppBar)
    expect(find.text('TrailerHub'), findsWidgets);
  });
}
