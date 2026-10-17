import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warshity/features/clients_details/presentation/widgets/customer_header_bar.dart';

import '../helpers/client_details_test_helpers.dart';

void main() {
  setUpAll(setUpClientDetailsTestEnvironment);

  testWidgets('shows the title and back control', (tester) async {
    await pumpClientDetailsWidget(tester, const CustomerHeaderBar());
    expect(find.text('customer_details'), findsOneWidget);
    expect(find.byIcon(Icons.people_alt_outlined), findsOneWidget);
    expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
  });
}
