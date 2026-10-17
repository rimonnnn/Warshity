import 'package:flutter_test/flutter_test.dart';
import 'package:warshity/core/di/injection.dart';
import 'package:warshity/features/clients_details/presentation/widgets/customer_stats_section.dart';
import 'package:warshity/features/invoices/data/models/invoice_model.dart';

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

  group('CustomerStatsSection', () {
    testWidgets('shows dashes when the customer has no id', (tester) async {
      await pumpClientDetailsWidget(
        tester,
        CustomerStatsSection(customer: makeCustomer(id: null)),
      );

      expect(find.text('customer_details'), findsOneWidget);
      expect(find.text('—'), findsNWidgets(2));
    });

    testWidgets('calculates purchases total and invoice count from stream', (
      tester,
    ) async {
      h.invoicesRepository.allClientInvoicesStream = Stream.value([
        makeInvoice(invoiceId: 'INV-1', total: 100),
        makeInvoice(invoiceId: 'INV-2', total: 50),
      ]);

      await pumpClientDetailsWidget(
        tester,
        CustomerStatsSection(customer: makeCustomer()),
      );

      expect(find.text('150.00'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('shows placeholders while invoice stats are loading', (
      tester,
    ) async {
      h.invoicesRepository.allClientInvoicesStream =
          Stream<List<InvoiceModel>>.multi((_) {});

      await pumpClientDetailsWidget(
        tester,
        CustomerStatsSection(customer: makeCustomer()),
        settle: false,
      );

      expect(find.text('...'), findsNWidgets(2));
    });

    testWidgets('shows dashes when the invoice stats stream fails', (
      tester,
    ) async {
      h.invoicesRepository.allClientInvoicesStream =
          Stream<List<InvoiceModel>>.error(StateError('offline'));

      await pumpClientDetailsWidget(
        tester,
        CustomerStatsSection(customer: makeCustomer()),
      );

      expect(find.text('—'), findsNWidgets(2));
    });
  });
}
