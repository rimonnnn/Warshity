import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warshity/features/clients_details/presentation/widgets/customer_header_card.dart';

import '../helpers/client_details_test_helpers.dart';

void main() {
  setUpAll(setUpClientDetailsTestEnvironment);

  group('CustomerHeaderCard', () {
    testWidgets('shows name, phone, address and call button', (tester) async {
      await pumpClientDetailsWidget(
        tester,
        const CustomerHeaderCard(name: 'Ahmed Ali', phone: '0101', address: 'Cairo'),
      );

      expect(find.text('Ahmed Ali'), findsOneWidget);
      expect(find.text('Cairo'), findsOneWidget);
      expect(find.text('0101'), findsOneWidget);
      expect(find.byIcon(Icons.phone_outlined), findsOneWidget);
    });

    testWidgets('hides an empty or whitespace address', (tester) async {
      await pumpClientDetailsWidget(
        tester,
        const CustomerHeaderCard(name: 'Ahmed', phone: '0101', address: '  '),
      );

      expect(find.text('  '), findsNothing);
      expect(find.text('Ahmed'), findsOneWidget);
    });

    testWidgets('hides the call button when showCallButton is false', (
      tester,
    ) async {
      await pumpClientDetailsWidget(
        tester,
        const CustomerHeaderCard(name: 'Ahmed', phone: '0101', showCallButton: false),
      );

      expect(find.byIcon(Icons.phone_outlined), findsNothing);
    });
  });
}
