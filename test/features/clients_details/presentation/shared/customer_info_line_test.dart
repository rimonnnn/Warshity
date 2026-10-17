import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warshity/features/clients_details/presentation/widgets/customer_info_line.dart';

import '../helpers/client_details_test_helpers.dart';

void main() {
  setUpAll(setUpClientDetailsTestEnvironment);

  testWidgets('shows its icon and text', (tester) async {
    await pumpClientDetailsWidget(
      tester,
      const CustomerInfoLine(icon: Icons.phone_outlined, text: '0101'),
    );

    expect(find.byIcon(Icons.phone_outlined), findsOneWidget);
    expect(find.text('0101'), findsOneWidget);
  });
}
