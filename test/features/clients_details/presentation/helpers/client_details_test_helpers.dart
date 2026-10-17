import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warshity/core/di/injection.dart';
import 'package:warshity/core/routing/app_routes.dart';
import 'package:warshity/core/theme/app_theme.dart';
import 'package:warshity/features/add_invoices/data/repo/add_invoice_repository.dart';
import 'package:warshity/features/clients/data/model/customer_model.dart';
import 'package:warshity/features/clients/data/repo/clients_reprosatory.dart';
import 'package:warshity/features/invoices/data/models/invoice_model.dart';

const allClientInvoicesMarker = 'ALL_CLIENT_INVOICES_SCREEN_MARKER';

class _KeysAssetLoader extends AssetLoader {
  const _KeysAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async =>
      <String, dynamic>{};
}

Future<void> setUpClientDetailsTestEnvironment() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  await EasyLocalization.ensureInitialized();
  EasyLocalization.logger.enableLevels = [];
}

CustomerModel makeCustomer({
  String? id = 'customer-1',
  String? name = 'Ahmed Ali',
  String? phone = '01012345678',
  String? address = 'Cairo',
  num? balance = 150,
  num totalPurchases = 250,
  num orderCount = 3,
}) {
  return CustomerModel(
    id: id,
    name: name,
    phone: phone,
    address: address,
    balance: balance,
    totalPurchases: totalPurchases,
    orderCount: orderCount,
  );
}

InvoiceModel makeInvoice({
  String invoiceId = 'INV-1',
  String customerId = 'customer-1',
  String customerName = 'Ahmed Ali',
  double total = 100,
  double remaining = 0,
  String createdAt = '2026-01-05T10:30:00',
}) {
  return InvoiceModel(
    invoiceId: invoiceId,
    customerId: customerId,
    customerName: customerName,
    createdAt: createdAt,
    items: const [],
    subtotal: total,
    discount: 0,
    total: total,
    paidAmount: total - remaining,
    remainingAmount: remaining,
  );
}

GoRouter _buildRouter(Widget home) => GoRouter(
  initialLocation: '/client-details-test',
  routes: [
    GoRoute(
      path: '/client-details-test',
      name: 'client-details-test',
      builder: (_, _) => home,
    ),
    GoRoute(
      path: '/all-client-invoices-test',
      name: AppRoutes.allClientInvoicesScreen,
      builder: (_, state) => const Scaffold(
        body: Text(allClientInvoicesMarker),
      ),
    ),
  ],
);

/// Pumps any widget/page with the same localization, ScreenUtil and theme setup
/// as the application. Use [settle] = false for screens with an infinite loader.
Future<void> pumpClientDetailsWidget(
  WidgetTester tester,
  Widget child, {
  Size logicalSize = const Size(1200, 1600),
  double pixelRatio = 1,
  bool settle = true,
}) async {
  tester.view.physicalSize = logicalSize * pixelRatio;
  tester.view.devicePixelRatio = pixelRatio;
  addTearDown(tester.view.reset);

  final router = _buildRouter(child);
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
          theme: AppTheme.lightTheme,
        ),
      ),
    ),
  );

  if (settle) {
    await tester.pumpAndSettle();
  } else {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
  }
}

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await tester.pump();
}

class FakeClientsRepository implements ClientsRepository {
  FakeClientsRepository({Stream<CustomerModel>? stream})
    : clientStream = stream ?? Stream<CustomerModel>.value(makeCustomer());

  Stream<CustomerModel> clientStream;

  @override
  Stream<CustomerModel> watchClient(String clientId) => clientStream;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeInvoicesRepository implements InvoicesRepository {
  Stream<List<InvoiceModel>> clientInvoicesStream =
      Stream<List<InvoiceModel>>.value(<InvoiceModel>[]);
  Stream<List<InvoiceModel>> allClientInvoicesStream =
      Stream<List<InvoiceModel>>.value(<InvoiceModel>[]);

  @override
  Stream<List<InvoiceModel>> watchClientInvoices(String customerId) =>
      clientInvoicesStream;

  @override
  Stream<List<InvoiceModel>> watchAllClientInvoices(String customerId) =>
      allClientInvoicesStream;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Registers only the dependencies read directly by Client Details layouts.
/// All repository data is supplied via streams, so tests stay offline.
class ClientDetailsTestHarness {
  ClientDetailsTestHarness._();

  late final FakeClientsRepository clientsRepository;
  late final FakeInvoicesRepository invoicesRepository;

  static Future<ClientDetailsTestHarness> create() async {
    await getIt.reset();
    final harness = ClientDetailsTestHarness._();
    harness.clientsRepository = FakeClientsRepository();
    harness.invoicesRepository = FakeInvoicesRepository();

    getIt.registerSingleton<ClientsRepository>(harness.clientsRepository);
    getIt.registerSingleton<InvoicesRepository>(harness.invoicesRepository);
    return harness;
  }

}

