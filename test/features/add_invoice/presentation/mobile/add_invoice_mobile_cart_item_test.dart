import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warshity/features/add_invoices/presentation/widgets/cart_item.dart';

Widget _wrap(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    builder: (_, __) => MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );
}

void main() {
  group('CartItem', () {
    testWidgets('displays product name, unit price, quantity, and subtotal', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          CartItem(
            productName: 'Wood',
            unitPrice: 10,
            quantity: 2,
            onQuantityChanged: (_) {},
            onDelete: () {},
          ),
        ),
      );

      expect(find.text('Wood'), findsOneWidget);
      expect(find.text('\$10.0 × 2'), findsOneWidget);
      expect(find.text('\$20.0'), findsOneWidget);
    });

    testWidgets('plus button increases quantity', (tester) async {
      int? newQuantity;

      await tester.pumpWidget(
        _wrap(
          CartItem(
            productName: 'Wood',
            unitPrice: 10,
            quantity: 2,
            onQuantityChanged: (quantity) => newQuantity = quantity,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      expect(newQuantity, 3);
    });

    testWidgets('minus button decreases quantity when quantity is above one', (
      tester,
    ) async {
      int? newQuantity;

      await tester.pumpWidget(
        _wrap(
          CartItem(
            productName: 'Wood',
            unitPrice: 10,
            quantity: 3,
            onQuantityChanged: (quantity) => newQuantity = quantity,
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();

      expect(newQuantity, 2);
    });

    testWidgets('delete button calls onDelete when quantity is one', (
      tester,
    ) async {
      var deleted = false;

      await tester.pumpWidget(
        _wrap(
          CartItem(
            productName: 'Wood',
            unitPrice: 10,
            quantity: 1,
            onQuantityChanged: (_) {},
            onDelete: () => deleted = true,
          ),
        ),
      );

      expect(find.byIcon(Icons.remove), findsNothing);

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pump();

      expect(deleted, isTrue);
    });

    testWidgets('can be built without quantity callbacks', (tester) async {
      await tester.pumpWidget(
        _wrap(const CartItem(productName: 'Wood', unitPrice: 10, quantity: 2)),
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
