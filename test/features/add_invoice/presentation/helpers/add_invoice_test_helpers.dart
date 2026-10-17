import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warshity/core/di/injection.dart';
import 'package:warshity/core/routing/app_routes.dart';
import 'package:warshity/core/theme/app_theme.dart';
import 'package:warshity/core/widgets/primary_button_widget.dart';
import 'package:warshity/features/add_invoices/data/repo/add_invoice_repository.dart';
import 'package:warshity/features/add_invoices/presentation/cubit/add_invoice_cubit.dart';
import 'package:warshity/features/add_invoices/presentation/layout/mobile_add_invoice.dart';
import 'package:warshity/features/add_invoices/presentation/layout/web_add_invoice.dart';
import 'package:warshity/features/clients/data/model/customer_model.dart';
import 'package:warshity/features/clients/data/repo/clients_reprosatory.dart';
import 'package:warshity/features/invoices/data/models/invoice_model.dart';
import 'package:warshity/features/products/data/models/product_model.dart';
import 'package:warshity/features/products/data/repo/products_repository.dart';

const invoiceCheckMarker = 'INVOICE_CHECK_SCREEN_MARKER';

final primaryActionButton = find.byType(PrimaryButtonWidget);

Finder fieldWithHint(String hint) {
  // TextFormField does not expose its InputDecoration as a public getter.
  // InputDecorator does, and is the widget that actually renders the hint.
  final decorator = find.byWidgetPredicate(
    (widget) =>
        widget is InputDecorator && widget.decoration.hintText == hint,
    description: 'input decorator with hint "$hint"',
  );

  // Return the editable field rather than InputDecorator so enterText() works.
  final formField = find.ancestor(
    of: decorator,
    matching: find.byType(TextFormField),
  );
  if (formField.evaluate().isNotEmpty) return formField.first;

  final textField = find.ancestor(
    of: decorator,
    matching: find.byType(TextField),
  );
  if (textField.evaluate().isNotEmpty) return textField.first;

  // Falls back to the decorator to produce a useful missing-field failure.
  return decorator;
}

class _KeysAssetLoader extends AssetLoader {
  const _KeysAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async =>
      <String, dynamic>{};
}

Future<void> setUpAddInvoiceTestEnvironment() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  await EasyLocalization.ensureInitialized();
  EasyLocalization.logger.enableLevels = [];
}

GoRouter _buildRouter(Widget layout) => GoRouter(
  initialLocation: '/add-invoice-test',
  routes: [
    GoRoute(
      path: '/add-invoice-test',
      name: 'add-invoice-test',
      builder: (_, _) => layout,
    ),
    GoRoute(
      path: '/check-invoice-test',
      name: AppRoutes.checkInvoiceScreen,
      builder: (_, _) => const Scaffold(
        body: Text(invoiceCheckMarker),
      ),
    ),
  ],
);

/// Creates isolated fake repositories and registers the dependencies the
/// Add Invoice layouts resolve through getIt.
class AddInvoiceTestHarness {
  AddInvoiceTestHarness._();

  late final FakeClientsRepository clientsRepository;
  late final FakeProductsRepository productsRepository;
  late final FakeInvoicesRepository invoicesRepository;
  late final InvoiceCubit invoiceCubit;

  static Future<AddInvoiceTestHarness> create() async {
    await getIt.reset();

    final h = AddInvoiceTestHarness._();
    h.clientsRepository = FakeClientsRepository();
    h.productsRepository = FakeProductsRepository();
    h.invoicesRepository = FakeInvoicesRepository();
    h.invoiceCubit = InvoiceCubit(h.invoicesRepository);

    getIt.registerSingleton<ClientsRepository>(h.clientsRepository);
    getIt.registerSingleton<ProductsRepository>(h.productsRepository);
    getIt.registerSingleton<InvoiceCubit>(h.invoiceCubit);

    return h;
  }

  Future<void> pumpMobile(
    WidgetTester tester, {
    Size logicalSize = const Size(430, 844),
    double pixelRatio = 3,
  }) => _pumpLayout(
    tester,
    layout: const MobileAddInvoice(),
    logicalSize: logicalSize,
    pixelRatio: pixelRatio,
  );

  Future<void> pumpWeb(
    WidgetTester tester, {
    Size logicalSize = const Size(1440, 900),
    double pixelRatio = 1,
  }) => _pumpLayout(
    tester,
    layout: const WebAddInvoice(),
    logicalSize: logicalSize,
    pixelRatio: pixelRatio,
  );

  Future<void> _pumpLayout(
    WidgetTester tester, {
    required Widget layout,
    required Size logicalSize,
    required double pixelRatio,
  }) async {
    tester.view.physicalSize = logicalSize * pixelRatio;
    tester.view.devicePixelRatio = pixelRatio;
    addTearDown(tester.view.reset);

    final router = _buildRouter(layout);
    addTearDown(router.dispose);

    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        useOnlyLangCode: true,
        path: 'unused',
        assetLoader: const _KeysAssetLoader(),
        child: ScreenUtilInit(
          designSize: logicalSize,
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, _) => MaterialApp.router(
            routerConfig: router,
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            // Use the real app theme so ThemeExtensions such as
            // AppThemeExtension are registered during widget tests.
            theme: AppTheme.lightTheme,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }
}

class FakeClientsRepository implements ClientsRepository {
  final List<CustomerModel> clients = [];

  @override
  Stream<List<CustomerModel>> watchClients() => Stream.value(clients);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeProductsRepository implements ProductsRepository {
  final List<ProductModel> products = [];

  @override
  Stream<List<ProductModel>> watchProducts() => Stream.value(products);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeInvoicesRepository implements InvoicesRepository {
  Completer<void>? stockCheckCompleter;
  InvoiceModel? checkedInvoice;
  var checkStockCalls = 0;

  @override
  Future<void> checkStock(InvoiceModel invoice) async {
    checkedInvoice = invoice;
    checkStockCalls++;
    final completer = stockCheckCompleter;
    if (completer != null) {
      await completer.future;
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final testCustomer = CustomerModel(
  id: 'customer-1',
  name: 'Test Customer',
  phone: '01000000000',
);

final testProduct = ProductModel(
  id: 'product-1',
  name: 'Wood',
  barcode: '12345',
  category: 'Raw Materials',
  price: 10,
  quantity: 20,
  unit: 'piece',
  imageUrl: '',
);

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await tester.pump();
}

/// Advances through snackbar timers so widget tests do not leave pending
/// timers behind at the end of a test.
Future<void> flushSnackBar(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(seconds: 7));
  }
}
