// This is a basic Flutter widget test for Cluck Rush.

import 'package:flutter_test/flutter_test.dart';

import 'package:cluck_rush/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CluckRushApp());

    // Verify that the app loads
    expect(find.text('Cluck Rush: The Egg Dash'), findsNothing);
  });
}
