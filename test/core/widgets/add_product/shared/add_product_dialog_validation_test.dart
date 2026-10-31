import 'package:flutter_test/flutter_test.dart';

import '../helpers/add_product_dialog_test_helpers.dart';

void main() {
  setUpAll(setUpAddProductDialogTestEnvironment);

  group('AddProductDialog | Validation', () {
    testWidgets('rejects an empty form and does not save a product', (
      tester,
    ) async {
      final h = AddProductDialogTestHarness();
      await h.pumpDialog(tester);
      await h.tapVisible(tester, addProductSaveButton);

      expect(find.text('Product name is required'), findsOneWidget);
      expect(h.productCubit.saveCalls, 0);
      expect(h.productCubit.submittedProduct, isNull);
      expect(tester.takeException(), isNull);
    });

    testWidgets('rejects an invalid selling price', (tester) async {
      final h = AddProductDialogTestHarness();
      await h.pumpDialog(tester);
      await h.fillValidProductForm(tester, price: 'not-a-number');
      await h.selectCategory(tester);
      await h.tapVisible(tester, addProductSaveButton);

      expect(h.productCubit.saveCalls, 0);
      expect(h.productCubit.submittedProduct, isNull);
      expect(tester.takeException(), isNull);
    });

    testWidgets('requires a category before saving', (tester) async {
      final h = AddProductDialogTestHarness();
      await h.pumpDialog(tester);
      await h.fillValidProductForm(tester);
      await h.tapVisible(tester, addProductSaveButton);
      await h.waitForSnackBar(tester);

      expect(h.productCubit.saveCalls, 0);
      expect(h.productCubit.submittedProduct, isNull);
      expect(
        find.text('Please select a category', skipOffstage: false),
        findsOneWidget,
      );
      await h.flushSnackBar(tester);
    });
  });
}
