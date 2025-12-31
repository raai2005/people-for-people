// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';
import 'package:people/main.dart';

void main() {
  testWidgets('App should build without errors', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PeopleForPeopleApp());

    // Verify the app builds successfully
    expect(find.byType(PeopleForPeopleApp), findsOneWidget);
  });
}
