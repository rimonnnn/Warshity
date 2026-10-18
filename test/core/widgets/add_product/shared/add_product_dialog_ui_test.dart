import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warshity/core/widgets/add_product_dialog.dart';
import 'package:warshity/core/widgets/add_product_form_fields.dart';
import 'package:warshity/core/widgets/primary_button_widget.dart';
import 'package:warshity/core/widgets/primary_text_field.dart';
import 'package:warshity/core/widgets/product_image_picker.dart';
import 'package:warshity/features/products/presentation/widgets/category_dropdown.dart';

import '../helpers/add_product_dialog_test_helpers.dart';

void main() {
  setUpAll(setUpAddProductDialogTestEnvironment);

  group('AddProductDialog | Shared responsive UI', () {
    testWidgets('renders all product fields on a mobile viewport', (
      tester,
    ) async {
      final h = AddProductDialogTestHarness();
      await h.pumpDialog(tester, logicalSize: const Size(430, 900));

      expect(find.byType(AddProductDialog), findsOneWidget);
      expect(find.text('Add New Product'), findsOneWidget);
      expect(find.byType(AddProductFormFields), findsOneWidget);
      expect(find.byType(ProductImagePicker), findsOneWidget);
      expect(find.byType(CustomTextField), findsNWidgets(4));
      expect(find.byType(CategoryDropdown), findsOneWidget);
      expect(find.byType(PrimaryButtonWidget), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });

    testWidgets('generates and displays the product code', (tester) async {
      final h = AddProductDialogTestHarness();
      await h.pumpDialog(tester);

      expect(h.productCubit.generateBarcodeCalls, 1);
      final barcodeFieldFinder = find.byType(TextFormField).at(1);
      final barcodeField = tester.widget<TextFormField>(barcodeFieldFinder);
      final barcodeTextField = tester.widget<TextField>(
        find.descendant(
          of: barcodeFieldFinder,
          matching: find.byType(TextField),
        ),
      );

      expect(barcodeField.controller?.text, 'SKU-TEST-001');
      expect(barcodeTextField.readOnly, isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('keeps code and price fields stacked on a narrow viewport', (
      tester,
    ) async {
      final h = AddProductDialogTestHarness();
      await h.pumpDialog(tester, logicalSize: const Size(360, 800));

      final fields = find.byType(TextFormField);
      final codeRect = tester.getRect(fields.at(1));
      final priceRect = tester.getRect(fields.at(2));

      expect(priceRect.top, greaterThan(codeRect.bottom - 1));
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without layout exceptions at desktop-sized width', (
      tester,
    ) async {
      final h = AddProductDialogTestHarness();
      await h.pumpDialog(tester, logicalSize: const Size(1280, 900));

      expect(find.byType(AddProductDialog), findsOneWidget);
      expect(find.byType(CustomTextField), findsNWidgets(4));
      expect(find.byType(PrimaryButtonWidget), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });
  });
}
