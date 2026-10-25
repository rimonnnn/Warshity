import 'dart:async';
import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warshity/core/theme/app_theme.dart';
import 'package:warshity/core/widgets/add_product_dialog.dart';
import 'package:warshity/core/widgets/primary_button_widget.dart';
import 'package:warshity/features/products/data/models/category_model.dart';
import 'package:warshity/features/products/data/models/product_model.dart';
import 'package:warshity/features/products/data/repo/categories_repository.dart';
import 'package:warshity/features/products/data/repo/products_repository.dart';
import 'package:warshity/features/products/presentation/cubit/add_product_cubit.dart';
import 'package:warshity/features/products/presentation/cubit/add_product_state.dart';
import 'package:warshity/features/products/presentation/cubit/categories_cubit.dart';

/// Empty translations intentionally leave localization keys visible in tests.
class _KeysAssetLoader extends AssetLoader {
  const _KeysAssetLoader();

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async =>
      <String, dynamic>{};
}

Future<void> setUpAddProductDialogTestEnvironment() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  await EasyLocalization.ensureInitialized();
  EasyLocalization.logger.enableLevels = [];
}

/// In-memory category repository; no Firebase/Firestore access is performed.
class FakeCategoriesRepository implements CategoriesRepository {
  FakeCategoriesRepository({List<CategoryModel>? categories})
    : categories = categories ??
          <CategoryModel>[
            CategoryModel(id: 'category-tools', name: 'Tools'),
            CategoryModel(id: 'category-materials', name: 'Materials'),
          ];

  final List<CategoryModel> categories;
  final List<String> addedCategoryNames = [];
  Object? addCategoryError;

  @override
  Stream<List<CategoryModel>> watchCategories() =>
      Stream<List<CategoryModel>>.value(List<CategoryModel>.of(categories));

  @override
  Future<void> addCategory(String name) async {
    final error = addCategoryError;
    if (error != null) throw error;
    addedCategoryNames.add(name);
    categories.add(
      CategoryModel(id: 'category-${categories.length + 1}', name: name),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Repository placeholder for the cubit's constructor. Tests control the
/// Cubit result directly so no backend or image storage is contacted.
class FakeProductsRepository implements ProductsRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Deterministic Cubit fake which retains the real AddProductState types used
/// by AddProductDialog, while allowing pending and failing saves to be tested.
class TestAddProductCubit extends AddProductCubit {
  TestAddProductCubit(super.repository);

  String barcode = 'SKU-TEST-001';
  int generateBarcodeCalls = 0;
  Object? barcodeError;
  Completer<String>? barcodeCompleter;

  ProductModel? submittedProduct;
  Uint8List? submittedImageBytes;
  String? submittedImageName;
  Completer<void>? saveCompleter;
  Object? saveError;
  int saveCalls = 0;

  @override
  Future<String> generateProductBarcode() async {
    generateBarcodeCalls++;
    final completer = barcodeCompleter;
    if (completer != null) return completer.future;
    final error = barcodeError;
    if (error != null) throw error;
    return barcode;
  }

  @override
  Future<List<String>> getCustomUnits() async => <String>[];

  @override
  Future<void> addCustomUnit(String name) async {}

  @override
  Future<void> addProduct({
    required ProductModel product,
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    saveCalls++;
    submittedProduct = product;
    submittedImageBytes = imageBytes;
    submittedImageName = imageName;
    emit(AddProductLoading());

    try {
      final completer = saveCompleter;
      if (completer != null) await completer.future;
      final error = saveError;
      if (error != null) throw error;
      emit(AddProductSuccess());
    } catch (error) {
      emit(AddProductError(error.toString()));
    }
  }
}

/// Opens the actual dialog route after MaterialApp has mounted its Navigator.
class _AddProductDialogLauncher extends StatefulWidget {
  const _AddProductDialogLauncher({
    required this.productCubit,
    required this.categoriesCubit,
  });

  final AddProductCubit productCubit;
  final CategoriesCubit categoriesCubit;

  @override
  State<_AddProductDialogLauncher> createState() =>
      _AddProductDialogLauncherState();
}

class _AddProductDialogLauncherState extends State<_AddProductDialogLauncher> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog<void>(
        context: context,
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider<AddProductCubit>.value(value: widget.productCubit),
            BlocProvider<CategoriesCubit>.value(value: widget.categoriesCubit),
          ],
          child: const AddProductDialog(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: SizedBox.expand(),
  );
}

class AddProductDialogTestHarness {
  AddProductDialogTestHarness() {
    productsRepository = FakeProductsRepository();
    categoriesRepository = FakeCategoriesRepository();
    productCubit = TestAddProductCubit(productsRepository);
    categoriesCubit = CategoriesCubit(categoriesRepository)..watchCategories();
  }

  late final FakeProductsRepository productsRepository;
  late final FakeCategoriesRepository categoriesRepository;
  late final TestAddProductCubit productCubit;
  late final CategoriesCubit categoriesCubit;

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
            home: _AddProductDialogLauncher(
              productCubit: productCubit,
              categoriesCubit: categoriesCubit,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.byType(AddProductDialog), findsOneWidget);

    // Remove the dialog tree before closing its Cubits to avoid lingering
    // route animations or controller disposals after a test has ended.
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await dispose();
    });
  }

  Future<void> fillValidProductForm(
    WidgetTester tester, {
    String name = '  Wooden Desk  ',
    String price = '250.50',
    String quantity = '6',
  }) async {
    final fields = find.byType(TextFormField);
    await _enterTextVisible(tester, fields.at(0), name);
    await _enterTextVisible(tester, fields.at(2), price);
    await _enterTextVisible(tester, fields.at(3), quantity);
  }

  Future<void> selectCategory(
    WidgetTester tester, {
    String category = 'Tools',
  }) async {
    final dropdown = find.byType(DropdownButtonFormField<String>).first;
    await tapVisible(tester, dropdown);
    await tester.pumpAndSettle();
    final option = find.text(category).last;
    await tester.tap(option);
    await tester.pumpAndSettle();
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pump();
    await tester.tap(finder);
    await tester.pump();
  }

  Future<void> finishSave(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
  }

  Future<void> flushSnackBar(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  }

  Future<void> _enterTextVisible(
    WidgetTester tester,
    Finder finder,
    String value,
  ) async {
    await tester.ensureVisible(finder);
    await tester.pump();
    await tester.enterText(finder, value);
    await tester.pump();
  }

  Future<void> dispose() async {
    await productCubit.close();
    await categoriesCubit.close();
  }
}

Finder get addProductSaveButton =>
    find.widgetWithText(PrimaryButtonWidget, 'save');

Finder get addProductCancelButton =>
    find.widgetWithText(PrimaryButtonWidget, 'Cancel');
