import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/add_product_dialog_test_helpers.dart';

void main() {
  setUpAll(setUpAddProductDialogTestEnvironment);

  group('AddProductDialog | Actions', () {
    testWidgets('Cancel closes the dialog without saving', (tester) async {
      final h = AddProductDialogTestHarness();
      await h.pumpDialog(tester);
      await h.tapVisible(tester, addProductCancelButton);
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsNothing);
      expect(h.productCubit.saveCalls, 0);
    });

    testWidgets('close icon closes the dialog without saving', (tester) async {
      final h = AddProductDialogTestHarness();
      await h.pumpDialog(tester);
      await h.tapVisible(tester, find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsNothing);
      expect(h.productCubit.saveCalls, 0);
    });
  });
}
