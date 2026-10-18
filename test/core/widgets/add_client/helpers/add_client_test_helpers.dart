import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warshity/core/theme/app_theme.dart';
import 'package:warshity/core/widgets/add_client_dialog.dart';
import 'package:warshity/core/widgets/primary_button_widget.dart';
import 'package:warshity/features/clients/data/model/customer_model.dart';
import 'package:warshity/features/clients/data/repo/clients_reprosatory.dart';
import 'package:warshity/features/clients/presentation/cubit/add_client_cubit.dart';

/// Test localization loader: untranslated keys remain visible, e.g. `add_client`.
class _KeysAssetLoader extends AssetLoader {
  const _KeysAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async =>
      <String, dynamic>{};
}

Future<void> setUpAddClientTestEnvironment() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  await EasyLocalization.ensureInitialized();
  EasyLocalization.logger.enableLevels = [];
}

/// Lightweight repository fake; the real Cubit/state behavior is retained.
class FakeClientsRepository implements ClientsRepository {
  CustomerModel? addedClient;
  Completer<void>? addClientCompleter;
  Object? addClientError;

  @override
  Future<void> addClient(CustomerModel client) async {
    addedClient = client;
    final completer = addClientCompleter;
    if (completer != null) await completer.future;
    final error = addClientError;
    if (error != null) throw error;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Opens AddClientDialog once after MaterialApp has mounted its Navigator.
/// This avoids a fragile test-only button finder and exercises the dialog route.
class _AddClientDialogLauncher extends StatefulWidget {
  const _AddClientDialogLauncher({required this.cubit});

  final AddClientCubit cubit;

  @override
  State<_AddClientDialogLauncher> createState() =>
      _AddClientDialogLauncherState();
}

class _AddClientDialogLauncherState extends State<_AddClientDialogLauncher> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog<void>(
        context: context,
        builder: (_) => BlocProvider<AddClientCubit>.value(
          value: widget.cubit,
          child: const AddClientDialog(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: SizedBox.expand(),
  );
}

class AddClientTestHarness {
  AddClientTestHarness() {
    repository = FakeClientsRepository();
    cubit = AddClientCubit(repository);
  }

  late final FakeClientsRepository repository;
  late final AddClientCubit cubit;

  Future<void> pumpDialog(
    WidgetTester tester, {
    Size logicalSize = const Size(430, 900),
    double pixelRatio = 1,
  }) async {
    tester.view.physicalSize = logicalSize * pixelRatio;
    tester.view.devicePixelRatio = pixelRatio;
    addTearDown(tester.view.reset);

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
          builder: (context, _) => MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            locale: context.locale,
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            home: _AddClientDialogLauncher(cubit: cubit),
          ),
        ),
      ),
    );

    // ScreenUtilInit and EasyLocalization both schedule work after the first
    // frame. Let those wrappers settle; the launcher opens the dialog on the
    // first completed frame without relying on a finder for a launcher button.
    await tester.pumpAndSettle();
    expect(find.byType(AddClientDialog), findsOneWidget);
  }

  Future<void> fillValidClientForm(
    WidgetTester tester, {
    String name = '  Ahmed Ali  ',
    String phone = '01012345678',
    String address = '  Cairo  ',
  }) async {
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), name);
    await tester.enterText(fields.at(1), phone);
    await tester.enterText(fields.at(2), address);
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pump();
    await tester.tap(finder);
    await tester.pump();
  }

  Future<void> finishSave(WidgetTester tester) async {
    // Advance through the Cubit's async repository call and dialog animation.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();
  }

  Future<void> flushSnackDialog(WidgetTester tester) async {
    // Snack/animated overlay timers should not leak into the next widget test.
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(seconds: 7));
    }
  }

  Future<void> dispose() async {
    await cubit.close();
  }
}

Finder get addClientSaveButton =>
    find.widgetWithText(PrimaryButtonWidget, 'save');

Finder get addClientCancelButton =>
    find.widgetWithText(PrimaryButtonWidget, 'cancel');
