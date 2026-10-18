import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warshity/core/widgets/add_client_dialog.dart';
import 'package:warshity/core/widgets/customer_balance_type.dart';
import 'package:warshity/core/widgets/primary_button_widget.dart';
import 'package:warshity/core/widgets/primary_text_field.dart';

import '../helpers/add_client_test_helpers.dart';

void main() {
  setUpAll(setUpAddClientTestEnvironment);

  late AddClientTestHarness h;
  setUp(() => h = AddClientTestHarness());
  tearDown(() => h.dispose());

  group('AddClientDialog | Shared responsive UI', () {
    testWidgets('renders the form and fields on a mobile viewport', (
      tester,
    ) async {
      await h.pumpDialog(tester, logicalSize: const Size(430, 900));

      expect(find.byType(AddClientDialog), findsOneWidget);
      expect(find.text('add_client'), findsOneWidget);
      expect(find.byType(CustomTextField), findsNWidgets(3));
      expect(find.byType(TextFormField), findsNWidgets(3));
      expect(find.byType(CustomerBalanceType), findsOneWidget);
      expect(find.byType(PrimaryButtonWidget), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders the same form on a desktop viewport', (tester) async {
      await h.pumpDialog(tester, logicalSize: const Size(1280, 900));

      expect(find.byType(AddClientDialog), findsOneWidget);
      expect(find.text('add_client'), findsOneWidget);
      expect(find.byType(CustomTextField), findsNWidgets(3));
      expect(find.byType(CustomerBalanceType), findsOneWidget);
      expect(find.byType(PrimaryButtonWidget), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });

    testWidgets('uses stacked action buttons on a very narrow viewport', (
      tester,
    ) async {
      await h.pumpDialog(tester, logicalSize: const Size(360, 800));

      final cancelRect = tester.getRect(addClientCancelButton);
      final saveRect = tester.getRect(addClientSaveButton);

      expect(saveRect.top, greaterThan(cancelRect.bottom - 1));
      expect(tester.takeException(), isNull);
    });

    testWidgets('uses a horizontal action row on a desktop viewport', (
      tester,
    ) async {
      await h.pumpDialog(tester, logicalSize: const Size(1280, 900));

      final cancelRect = tester.getRect(addClientCancelButton);
      final saveRect = tester.getRect(addClientSaveButton);

      expect((saveRect.center.dy - cancelRect.center.dy).abs(), lessThan(2));
    });

    testWidgets('does not show the debt amount field until debit is selected', (
      tester,
    ) async {
      await h.pumpDialog(tester);

      expect(find.byType(TextFormField), findsNWidgets(3));
      expect(find.text('debt_amount'), findsNothing);

      await h.tapVisible(tester, find.text('debit'));
      expect(find.byType(TextFormField), findsNWidgets(4));
      expect(find.text('debt_amount'), findsOneWidget);
    });
  });

  group('AddClientDialog | Validation', () {
    testWidgets('shows required errors for an empty form', (tester) async {
      await h.pumpDialog(tester);
      await h.tapVisible(tester, addClientSaveButton);

      expect(find.text('validator_client_name_required'), findsOneWidget);
      expect(find.text('validator_phone_required'), findsOneWidget);
      expect(find.text('validator_address_required'), findsOneWidget);
      expect(h.repository.addedClient, isNull);
    });

    testWidgets('rejects an invalid phone number', (tester) async {
      await h.pumpDialog(tester);
      await h.fillValidClientForm(tester, phone: '123');
      await h.tapVisible(tester, addClientSaveButton);

      expect(find.text('validator_phone_invalid'), findsOneWidget);
      expect(h.repository.addedClient, isNull);
    });

    testWidgets('requires a debt amount only when debit is selected', (
      tester,
    ) async {
      await h.pumpDialog(tester);
      await h.fillValidClientForm(tester);
      await h.tapVisible(tester, find.text('debit'));
      await h.tapVisible(tester, addClientSaveButton);

      expect(find.text('amount_required'), findsOneWidget);
      expect(h.repository.addedClient, isNull);
    });
  });

  group('AddClientDialog | Save action', () {
    testWidgets('saves trimmed customer details', (tester) async {
      await h.pumpDialog(tester);
      await h.fillValidClientForm(tester);
      await h.tapVisible(tester, addClientSaveButton);
      await h.finishSave(tester);

      final client = h.repository.addedClient;
      expect(client, isNotNull);
      expect(client!.name, 'Ahmed Ali');
      expect(client.phone, '01012345678');
      expect(client.address, 'Cairo');
      expect(client.balance, 0);
      expect(client.hasDebt, isFalse);
      expect(find.byType(AddClientDialog), findsNothing);

      await h.flushSnackDialog(tester);
    });

    testWidgets('saves the debt amount when debit is selected', (tester) async {
      await h.pumpDialog(tester, logicalSize: const Size(1280, 900));
      await h.fillValidClientForm(tester);
      await h.tapVisible(tester, find.text('debit'));
      await tester.enterText(find.byType(TextFormField).at(3), '125.50');
      await h.tapVisible(tester, addClientSaveButton);
      await h.finishSave(tester);

      final client = h.repository.addedClient;
      expect(client, isNotNull);
      expect(client!.hasDebt, isTrue);
      expect(client.balance, 125.5);
      expect(find.byType(AddClientDialog), findsNothing);

      await h.flushSnackDialog(tester);
    });
  });

  group('AddClientDialog | Loading and error states', () {
    testWidgets('disables action buttons while save is pending', (
      tester,
    ) async {
      h.repository.addClientCompleter = Completer<void>();
      await h.pumpDialog(tester, logicalSize: const Size(1280, 900));
      await h.fillValidClientForm(tester);
      await h.tapVisible(tester, addClientSaveButton);
      await tester.pump();

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      final buttons = tester.widgetList<PrimaryButtonWidget>(
        find.byType(PrimaryButtonWidget),
      );
      expect(buttons, hasLength(2));
      for (final button in buttons) {
        expect(button.onPress, isNull);
      }

      h.repository.addClientCompleter!.complete();
      await h.finishSave(tester);
      expect(find.byType(AddClientDialog), findsNothing);
      await h.flushSnackDialog(tester);
    });

    testWidgets('keeps the dialog open when saving fails', (tester) async {
      h.repository.addClientError = Exception('offline');
      await h.pumpDialog(tester);
      await h.fillValidClientForm(tester);
      await h.tapVisible(tester, addClientSaveButton);
      await h.finishSave(tester);

      expect(find.byType(AddClientDialog), findsOneWidget);
      expect(find.text('something_error'), findsOneWidget);
      await h.flushSnackDialog(tester);
    });
  });
}
