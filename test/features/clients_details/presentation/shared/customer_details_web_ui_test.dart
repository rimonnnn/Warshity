import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warshity/features/clients/data/model/customer_model.dart';
import 'package:warshity/core/di/injection.dart';
import 'package:warshity/core/widgets/app_loading_indicator.dart';
import 'package:warshity/features/clients_details/presentation/layout/web_customer_details.dart';
import 'package:warshity/features/clients_details/presentation/widgets/customer_balance_card.dart';
import 'package:warshity/features/clients_details/presentation/widgets/customer_error_view.dart';
import 'package:warshity/features/clients_details/presentation/widgets/customer_header_bar.dart';
import 'package:warshity/features/clients_details/presentation/widgets/customer_invoices_card.dart';
import 'package:warshity/features/clients_details/presentation/widgets/customer_profile_card.dart';
import 'package:warshity/features/clients_details/presentation/widgets/customer_stats_section.dart';

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

  group('WebCustomerDetails | UI', () {
    testWidgets('shows profile, invoices, debt and customer statistics', (tester) async {
      await pumpClientDetailsWidget(
        tester,
        const WebCustomerDetails(customerId: 'customer-1'),
        logicalSize: const Size(1440, 900),
      );

      expect(find.byType(WebCustomerDetails), findsOneWidget);
      expect(find.byType(CustomerHeaderBar), findsOneWidget);
      expect(find.byType(CustomerProfileCard), findsOneWidget);
      expect(find.byType(CustomerBalanceCard), findsOneWidget);
      expect(find.byType(CustomerStatsSection), findsOneWidget);
      expect(find.byType(CustomerInvoicesCard), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('stacks content at a narrow web viewport', (tester) async {
      await pumpClientDetailsWidget(
        tester,
        const WebCustomerDetails(customerId: 'customer-1'),
        logicalSize: const Size(700, 1000),
      );

      expect(find.byType(CustomerProfileCard), findsOneWidget);
      expect(find.byType(CustomerBalanceCard), findsOneWidget);
      expect(find.byType(CustomerStatsSection), findsOneWidget);
      expect(find.byType(CustomerInvoicesCard), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows loading indicator while waiting for customer data', (tester) async {
      h.clientsRepository.clientStream = Stream<CustomerModel>.multi((_) {});
      await pumpClientDetailsWidget(
        tester,
        const WebCustomerDetails(customerId: 'customer-1'),
        logicalSize: const Size(1440, 900),
        settle: false,
      );

      expect(find.byType(AppLoadingIndicator), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows error view when customer stream fails', (tester) async {
      h.clientsRepository.clientStream = Stream<CustomerModel>.error(StateError('offline'));
      await pumpClientDetailsWidget(
        tester,
        const WebCustomerDetails(customerId: 'customer-1'),
        logicalSize: const Size(1440, 900),
      );

      expect(find.byType(CustomerErrorView), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
