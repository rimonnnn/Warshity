import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:warshity/main.dart';

void main() {
  // This is the original Flutter counter-template test, not a Warshity
  // widget test. It is deliberately skipped because MyApp requires the app's
  // GetIt dependency setup (including ThemeService). Replace this with an
  // application widget test once the project's test dependency setup is
  // available; do not treat this skipped template as app coverage.
  testWidgets(
    'Counter increments smoke test (obsolete Flutter template)',
    (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      expect(find.text('0'), findsOneWidget);
      expect(find.text('1'), findsNothing);

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(find.text('0'), findsNothing);
      expect(find.text('1'), findsOneWidget);
    },
    skip: true,
  );
}
