import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:warshity/core/theme/services/theme_service.dart';
import 'package:warshity/features/Cleints/data/data_source/clients_remote_data_source.dart';
import 'package:warshity/features/Cleints/data/repo/clients_reprosatory.dart';
import 'package:warshity/features/Cleints/presentation/cubit/add_client_cubit.dart';
import 'package:warshity/features/Cleints/presentation/cubit/clients_cubit.dart';
import 'package:warshity/features/Cleints/presentation/cubit/debt_cubit.dart';
import 'package:warshity/features/Cleints/presentation/cubit/remove_clients_state.dart';
import 'package:warshity/features/add_invoices/data/data_source/add_invoice_remote_data.dart';
import 'package:warshity/features/add_invoices/data/repo/add_invoice_repository.dart';
import 'package:warshity/features/add_invoices/presentation/cubit/add_invoice_cubit.dart';
import 'package:warshity/features/auth/cubit/auth_cubit.dart';
import 'package:warshity/features/auth/data/auth_repo.dart';
import 'package:warshity/features/auth/data/auth_repo_impl.dart';
import 'package:warshity/features/auth/register/data/repos/register_repo.dart';
import 'package:warshity/features/auth/register/data/repos/register_repo_impl.dart';
import 'package:warshity/features/invoices/data/datasource/invoices_remote_data_source.dart';
import 'package:warshity/features/invoices/data/repo/invoices_repository.dart';
import 'package:warshity/features/onboarding/data/onboarding_local_data_source.dart';
import 'package:warshity/features/products/data/datascource/categories_remote_data_source.dart';
import 'package:warshity/features/products/data/datascource/products_remote_data_source.dart';
import 'package:warshity/features/products/data/repo/categories_repository.dart';
import 'package:warshity/features/products/data/repo/products_repository.dart';
import 'package:warshity/features/products/presentation/cubit/add_product_cubit.dart';
import 'package:warshity/features/products/presentation/cubit/categories_cubit.dart';
import 'package:warshity/features/products/presentation/cubit/products_cubit.dart';
import 'package:warshity/features/settings/data/datascource/settings_remote_data_source.dart';
import 'package:warshity/features/settings/data/repo/settings_repositery.dart';
import 'package:warshity/features/settings/presentation/cubit/settings_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  final sharedPreferences = await SharedPreferences.getInstance();

  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  getIt.registerLazySingleton<ThemeService>(
    () => ThemeService(getIt<SharedPreferences>()),
  );

  getIt.registerLazySingleton<OnboardingLocalDataSource>(
    () => OnboardingLocalDataSource(getIt<SharedPreferences>()),
  );

  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );

  getIt.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  getIt.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn());

  getIt.registerLazySingleton<RegisterRepo>(
    () => RegisterRepoImpl(getIt<FirebaseAuth>(), getIt<FirebaseFirestore>()),
  );

  getIt.registerLazySingleton<AuthRepo>(
    () => AuthRepoImpl(getIt<FirebaseAuth>(), getIt<GoogleSignIn>()),
  );

  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(getIt<RegisterRepo>(), getIt<AuthRepo>()),
  );

  getIt.registerLazySingleton<ClientsRemoteDataSource>(
    () => ClientsRemoteDataSource(getIt<FirebaseFirestore>()),
  );

  getIt.registerFactory<DebtCubit>(() => DebtCubit(getIt()));

  getIt.registerLazySingleton<ClientsRepository>(
    () => ClientsRepository(getIt<ClientsRemoteDataSource>()),
  );

  getIt.registerFactory<ClientsCubit>(
    () => ClientsCubit(getIt<ClientsRepository>()),
  );

  getIt.registerFactory<AddClientCubit>(
    () => AddClientCubit(getIt<ClientsRepository>()),
  );

  getIt.registerLazySingleton<ProductsRemoteDataSource>(
    () => ProductsRemoteDataSource(
      getIt<FirebaseFirestore>(),
      getIt<SupabaseClient>(),
    ),
  );

  getIt.registerLazySingleton<ProductsRepository>(
    () => ProductsRepository(getIt<ProductsRemoteDataSource>()),
  );

  getIt.registerFactory<ProductsCubit>(
    () => ProductsCubit(getIt<ProductsRepository>()),
  );

  getIt.registerFactory<AddProductCubit>(
    () => AddProductCubit(getIt<ProductsRepository>()),
  );

  getIt.registerLazySingleton<CategoriesRemoteDataSource>(
    () => CategoriesRemoteDataSource(getIt<FirebaseFirestore>()),
  );

  getIt.registerLazySingleton<CategoriesRepository>(
    () => CategoriesRepository(getIt<CategoriesRemoteDataSource>()),
  );

  getIt.registerFactory<CategoriesCubit>(
    () => CategoriesCubit(getIt<CategoriesRepository>()),
  );
  getIt.registerLazySingleton<SettingsRemoteDataSource>(
    () => SettingsRemoteDataSource(getIt<FirebaseAuth>()),
  );

  getIt.registerLazySingleton<SettingsRepositery>(
    () => SettingsRepositery(getIt<SettingsRemoteDataSource>()),
  );

  getIt.registerFactory<SettingsCubit>(
    () => SettingsCubit(getIt<SettingsRepositery>()),
  );
  getIt.registerFactory<RemoveClientCubit>(
    () => RemoveClientCubit(getIt<ClientsRepository>()),
  );
  getIt.registerLazySingleton<InvoicesRemoteDataSource>(
  () => InvoicesRemoteDataSource(
    getIt<FirebaseFirestore>(),
  ),
);

getIt.registerLazySingleton<InvoicesRepository>(
  () => InvoicesRepository(
    getIt<InvoicesRemoteDataSource>(),
  ),
);

getIt.registerFactory<InvoiceCubit>(
  () => InvoiceCubit(
    getIt<InvoicesRepository>(),
  ),
);
  getIt.registerLazySingleton<InvoicesRemoteDataSources>(
  () => InvoicesRemoteDataSources(
    getIt<FirebaseFirestore>(),
  ),
);

getIt.registerLazySingleton<InvoiceRepository>(
  () => InvoiceRepository(
    getIt<InvoicesRemoteDataSources>(),
  ),
);

}
