import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warshity/features/clients_details/presentation/widgets/customer_stat_card.dart';

import '../helpers/client_details_test_helpers.dart';

void main() {
  setUpAll(setUpClientDetailsTestEnvironment);

  testWidgets('shows the title, value and icon', (tester) async {
    await pumpClientDetailsWidget(
      tester,
      const CustomerStatCard(
        title: 'total_purchases',
        value: '500.00',
        icon: Icons.trending_up,
      ),
    );

    expect(find.text('total_purchases'), findsOneWidget);
    expect(find.text('500.00'), findsOneWidget);
    expect(find.byIcon(Icons.trending_up), findsOneWidget);
  });
}
