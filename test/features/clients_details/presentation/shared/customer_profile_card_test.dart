import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warshity/features/clients_details/presentation/widgets/customer_profile_card.dart';

import '../helpers/client_details_test_helpers.dart';

void main() {
  setUpAll(setUpClientDetailsTestEnvironment);

  group('CustomerProfileCard', () {
    testWidgets('shows name, phone and address', (tester) async {
      await pumpClientDetailsWidget(
        tester,
        CustomerProfileCard(customer: makeCustomer()),
      );

      expect(find.text('Ahmed Ali'), findsOneWidget);
      expect(find.text('01012345678'), findsOneWidget);
      expect(find.text('Cairo'), findsOneWidget);
    });

    testWidgets('shows a dash when the name is empty', (tester) async {
      await pumpClientDetailsWidget(
        tester,
        CustomerProfileCard(customer: makeCustomer(name: '  ')),
      );

      expect(find.text('—'), findsOneWidget);
    });

    testWidgets('hides phone and address rows when both are empty', (
      tester,
    ) async {
      await pumpClientDetailsWidget(
        tester,
        CustomerProfileCard(customer: makeCustomer(phone: '', address: '')),
      );

      expect(find.byIcon(Icons.phone_outlined), findsNothing);
      expect(find.byIcon(Icons.location_on_outlined), findsNothing);
    });
  });
}
