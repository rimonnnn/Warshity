import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:warshity/features/add_invoices/presentation/widgets/invoice_summary_card.dart';

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
  group('InvoiceSummaryCard', () {
    testWidgets('displays subtotal and final total', (tester) async {
      await tester.pumpWidget(
        _wrap(const InvoiceSummaryCard(subtotal: 100, discount: 0, total: 100)),
      );

      expect(find.text('invoice_summary'), findsOneWidget);
      expect(find.text('subtotal'), findsOneWidget);
      expect(find.text('final_total'), findsOneWidget);
      expect(find.text('\$100.0'), findsNWidgets(2));
    });

    testWidgets('hides the discount row when discount is zero', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const InvoiceSummaryCard(subtotal: 100, discount: 0, total: 100)),
      );

      expect(find.text('discount'), findsNothing);
    });

    testWidgets('shows the discount row when discount is greater than zero', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const InvoiceSummaryCard(subtotal: 100, discount: 10, total: 90)),
      );

      expect(find.text('discount'), findsOneWidget);
      expect(find.text('- \$10.0'), findsOneWidget);
      expect(find.text('\$90.0'), findsOneWidget);
    });
  });
}
