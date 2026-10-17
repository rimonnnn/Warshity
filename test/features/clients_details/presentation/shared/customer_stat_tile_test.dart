import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warshity/features/clients_details/presentation/widgets/customer_stat_tile.dart';

import '../helpers/client_details_test_helpers.dart';

void main() {
  setUpAll(setUpClientDetailsTestEnvironment);

  testWidgets('shows the title, value and icon', (tester) async {
    await pumpClientDetailsWidget(
      tester,
      const CustomerStatTile(
        title: 'order_count',
        value: '7',
        icon: Icons.shopping_bag_outlined,
      ),
    );

    expect(find.text('order_count'), findsOneWidget);
    expect(find.text('7'), findsOneWidget);
    expect(find.byIcon(Icons.shopping_bag_outlined), findsOneWidget);
  });
}
