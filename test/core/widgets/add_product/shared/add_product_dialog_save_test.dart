import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warshity/core/widgets/add_product_dialog.dart';
import 'package:warshity/core/widgets/primary_button_widget.dart';

import '../helpers/add_product_dialog_test_helpers.dart';

void main() {
  setUpAll(setUpAddProductDialogTestEnvironment);

  group('AddProductDialog | Save action', () {
    testWidgets('saves trimmed product details and closes on success', (
      tester,
    ) async {
      final h = AddProductDialogTestHarness();
      await h.pumpDialog(tester);
      await h.fillValidProductForm(tester);
      await h.selectCategory(tester);
      await h.tapVisible(tester, addProductSaveButton);
      await h.finishSave(tester);

      final product = h.productCubit.submittedProduct;
      expect(h.productCubit.saveCalls, 1);
      expect(product, isNotNull);
      expect(product!.name, 'Wooden Desk');
      expect(product.barcode, 'SKU-TEST-001');
      expect(product.category, 'Tools');
      expect(product.price, 250.50);
      expect(product.quantity, 6);
      expect(product.unit, 'Piece');
      expect(product.imageUrl, isEmpty);
      expect(find.byType(AddProductDialog), findsNothing);

      await h.flushSnackBar(tester);
    });

    testWidgets('disables both action buttons while saving is pending', (
      tester,
    ) async {
      final h = AddProductDialogTestHarness();
      h.productCubit.saveCompleter = Completer<void>();
      await h.pumpDialog(tester);
      await h.fillValidProductForm(tester);
      await h.selectCategory(tester);
      await h.tapVisible(tester, addProductSaveButton);
      await tester.pump();

      final buttons = tester.widgetList<PrimaryButtonWidget>(
        find.byType(PrimaryButtonWidget),
      ).toList();
      expect(buttons, hasLength(2));

      final cancelButton = buttons.singleWhere(
        (button) => button.buttonText == 'Cancel',
      );
      final saveButton = buttons.singleWhere(
        (button) => button.buttonText == 'save',
      );
      expect(cancelButton.onPress, isNull);
      expect(saveButton.isLoading, isTrue);

      final materialButtons = tester.widgetList<ElevatedButton>(
        find.descendant(
          of: find.byType(PrimaryButtonWidget),
          matching: find.byType(ElevatedButton),
        ),
      );
      expect(materialButtons, hasLength(2));
      expect(materialButtons.every((button) => button.onPressed == null), isTrue);
      expect(find.byType(AddProductDialog), findsOneWidget);

      h.productCubit.saveCompleter!.complete();
      await h.finishSave(tester);

      expect(find.byType(AddProductDialog), findsNothing);
      await h.flushSnackBar(tester);
    });

    testWidgets('keeps the dialog open and shows error when saving fails', (
      tester,
    ) async {
      final h = AddProductDialogTestHarness();
      h.productCubit.saveError = Exception('offline');
      await h.pumpDialog(tester);
      await h.fillValidProductForm(tester);
      await h.selectCategory(tester);
      await h.tapVisible(tester, addProductSaveButton);
      await h.finishSave(tester);

      expect(find.byType(AddProductDialog), findsOneWidget);
      expect(find.text('Exception: offline'), findsOneWidget);
      expect(h.productCubit.saveCalls, 1);
      await h.flushSnackBar(tester);
    });
  });
}
