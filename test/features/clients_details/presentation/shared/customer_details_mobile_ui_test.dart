import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warshity/features/clients/data/model/customer_model.dart';
import 'package:warshity/core/di/injection.dart';
import 'package:warshity/features/clients_details/presentation/layout/mobile_customer_details.dart';
import 'package:warshity/features/clients_details/presentation/widgets/customer_debt_card.dart';
import 'package:warshity/features/clients_details/presentation/widgets/customer_details_shimmer.dart';
import 'package:warshity/features/clients_details/presentation/widgets/customer_header_card.dart';
import 'package:warshity/features/clients_details/presentation/widgets/customer_stat_card.dart';
import 'package:warshity/features/clients_details/presentation/widgets/invoice_list.dart';

import '../helpers/client_details_test_helpers.dart';

void main() {
  setUpAll(setUpClientDetailsTestEnvironment);

  late ClientDetailsTestHarness h;
  setUp(() async {
    h = await ClientDetailsTestHarness.create();
  });
  tearDown(() async {
    await getIt.reset();
  });

  group('MobileCustomerDetails | UI', () {
    testWidgets('shows customer details, debt, recent invoices and stats', (tester) async {
      await pumpClientDetailsWidget(
        tester,
        const MobileCustomerDetails(customerId: 'customer-1'),
        logicalSize: const Size(430, 844),
        pixelRatio: 3,
      );

      expect(find.byType(MobileCustomerDetails), findsOneWidget);
      expect(find.text('customer_details'), findsOneWidget);
      expect(find.byType(CustomerHeaderCard), findsOneWidget);
      expect(find.byType(CustomerDebtCard), findsOneWidget);
      expect(find.text('recent_invoices'), findsOneWidget);
      expect(find.byType(InvoiceList), findsOneWidget);
      expect(find.byType(CustomerStatCard), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows shimmer while customer stream is waiting', (tester) async {
      h.clientsRepository.clientStream = Stream<CustomerModel>.multi((_) {});
      await pumpClientDetailsWidget(
        tester,
        const MobileCustomerDetails(customerId: 'customer-1'),
        logicalSize: const Size(430, 844),
        pixelRatio: 3,
        settle: false,
      );

      expect(find.byType(CustomerDetailsShimmer), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows an error message when customer stream fails', (tester) async {
      h.clientsRepository.clientStream = Stream<CustomerModel>.error(StateError('offline'));
      await pumpClientDetailsWidget(
        tester,
        const MobileCustomerDetails(customerId: 'customer-1'),
        logicalSize: const Size(430, 844),
        pixelRatio: 3,
      );

      expect(find.text('something_error'), findsOneWidget);
      expect(find.byType(CustomerHeaderCard), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
