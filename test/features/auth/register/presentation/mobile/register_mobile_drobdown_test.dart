import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/register_test_helpers.dart';

void main() {
  setUpAll(setUpRegisterTestEnvironment);

  late RegisterTestHarness h;
  setUp(() {
    h = RegisterTestHarness();
  });

  group('RegisterMobileLayout | Activity dropdown', () {
    testWidgets('lists the six default activities', (tester) async {
      await h.pumpRegister(tester);

      await h.openActivityDropdown(tester);

      for (final activity in const [
        'activities.carpentry',
        'activities.plumbing',
        'activities.electricity',
        'activities.painting',
        'activities.blacksmith',
        'activities.ac',
      ]) {
        expect(find.text(activity), findsOneWidget, reason: activity);
      }
    });

    testWidgets('merges Firestore categories and removes duplicates', (
      tester,
    ) async {
      await h.pumpRegister(
        tester,
        firestoreCategories: const ['Custom Category', 'activities.carpentry'],
      );

      await h.openActivityDropdown(tester);

      expect(find.text('Custom Category'), findsOneWidget);
      // Already a default activity → listed once, not twice.
      expect(find.text('activities.carpentry'), findsOneWidget);
    });

    testWidgets('shows the add-category button inside the search box', (
      tester,
    ) async {
      await h.pumpRegister(tester);

      await h.openActivityDropdown(tester);

      expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);
    });

    testWidgets('shows the selected activity in the field and closes the list', (
      tester,
    ) async {
      await h.pumpRegister(tester);

      await h.selectActivity(tester);

      expect(
        find.descendant(
          of: activityDropdown,
          matching: find.text(validActivity),
        ),
        findsOneWidget,
      );
      // The popup is closed, so the other activities are gone.
      expect(find.text('activities.carpentry'), findsNothing);
    });
  });
}