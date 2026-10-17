import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warshity/features/clients_details/presentation/widgets/customer_error_view.dart';

import '../helpers/client_details_test_helpers.dart';

void main() {
  setUpAll(setUpClientDetailsTestEnvironment);

  testWidgets('shows the error icon and localized message key', (tester) async {
    await pumpClientDetailsWidget(tester, const CustomerErrorView());

    expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    expect(find.text('something_error'), findsOneWidget);
  });
}
