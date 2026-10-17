import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warshity/core/di/injection.dart';
import 'package:warshity/features/clients_details/presentation/layout/mobile_customer_details.dart';

import '../helpers/client_details_test_helpers.dart';

void main() {
  setUpAll(setUpClientDetailsTestEnvironment);

  setUp(() async {
    await ClientDetailsTestHarness.create();
  });
  tearDown(() async {
    await getIt.reset();
  });

  group('MobileCustomerDetails | Actions', () {
    testWidgets('show all opens the all-client-invoices route', (tester) async {
      await pumpClientDetailsWidget(
        tester,
        const MobileCustomerDetails(customerId: 'customer-1'),
        logicalSize: const Size(430, 844),
        pixelRatio: 3,
      );

      await tapVisible(tester, find.text('show_all'));
      await tester.pumpAndSettle();
      expect(find.text(allClientInvoicesMarker), findsOneWidget);
    });
  });
}
