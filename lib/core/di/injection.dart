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
import 'package:warshity/features/auth/cubit/auth_cubit.dart';
import 'package:warshity/features/auth/data/auth_repo.dart';
import 'package:warshity/features/auth/data/auth_repo_impl.dart';
import 'package:warshity/features/auth/register/data/repos/register_repo.dart';
import 'package:warshity/features/auth/register/data/repos/register_repo_impl.dart';
import 'package:warshity/features/onboarding/data/onboarding_local_data_source.dart';
import 'package:warshity/features/products/data/datascource/categories_remote_data_source.dart';
import 'package:warshity/features/products/data/datascource/products_remote_data_source.dart';
import 'package:warshity/features/products/data/repo/categories_repository.dart';
import 'package:warshity/features/products/data/repo/products_repository.dart';
import 'package:warshity/features/products/presentation/cubit/add_product_cubit.dart';
import 'package:warshity/features/products/presentation/cubit/categories_cubit.dart';
import 'package:warshity/features/products/presentation/cubit/products_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  // ============================================================
  // Shared Preferences
  // ============================================================

  final sharedPreferences = await SharedPreferences.getInstance();

  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // ============================================================
  // Core Services
  // ============================================================

  getIt.registerLazySingleton<ThemeService>(
    () => ThemeService(getIt<SharedPreferences>()),
  );

  getIt.registerLazySingleton<OnboardingLocalDataSource>(
    () => OnboardingLocalDataSource(getIt<SharedPreferences>()),
  );

  // ============================================================
  // Firebase
  // ============================================================

  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  getIt.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );

  // ============================================================
  // Supabase
  // ============================================================

  getIt.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // ============================================================
  // Google Sign-In
  // ============================================================

  getIt.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn());

  // ============================================================
  // Register Feature
  // ============================================================

  getIt.registerLazySingleton<RegisterRepo>(
    () => RegisterRepoImpl(getIt<FirebaseAuth>(), getIt<FirebaseFirestore>()),
  );

  // ============================================================
  // Auth Feature
  // ============================================================

  getIt.registerLazySingleton<AuthRepo>(
    () => AuthRepoImpl(getIt<FirebaseAuth>(), getIt<GoogleSignIn>()),
  );

  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(getIt<RegisterRepo>(), getIt<AuthRepo>()),
  );

  // ============================================================
  // Clients Feature
  // ============================================================

  getIt.registerLazySingleton<ClientsRemoteDataSource>(
    () => ClientsRemoteDataSource(getIt<FirebaseFirestore>()),
  );

  // Debt feature
  getIt.registerFactory<DebtCubit>(() => DebtCubit(getIt()));

  getIt.registerLazySingleton<ClientsRepository>(
    () => ClientsRepository(getIt<ClientsRemoteDataSource>()),
  );

  getIt.registerFactory<ClientsCubit>(
    () => ClientsCubit(getIt<ClientsRepository>()),
  );

  // ============================================================
  // Add Client
  // ============================================================

  getIt.registerFactory<AddClientCubit>(
    () => AddClientCubit(getIt<ClientsRepository>()),
  );

  // ============================================================
  // Products Remote Data Source
  // Firebase + Supabase
  // ============================================================

  getIt.registerLazySingleton<ProductsRemoteDataSource>(
    () => ProductsRemoteDataSource(
      getIt<FirebaseFirestore>(),
      getIt<SupabaseClient>(),
    ),
  );

  // ============================================================
  // Products Repository
  // ============================================================

  getIt.registerLazySingleton<ProductsRepository>(
    () => ProductsRepository(getIt<ProductsRemoteDataSource>()),
  );

  // ============================================================
  // Products Cubit
  // ============================================================

  getIt.registerFactory<ProductsCubit>(
    () => ProductsCubit(getIt<ProductsRepository>()),
  );

  // ============================================================
  // Add Product Cubit
  // ============================================================

  getIt.registerFactory<AddProductCubit>(
    () => AddProductCubit(getIt<ProductsRepository>()),
  );

  // ============================================================
  // Categories Remote Data Source
  // ============================================================

  getIt.registerLazySingleton<CategoriesRemoteDataSource>(
    () => CategoriesRemoteDataSource(getIt<FirebaseFirestore>()),
  );

  // ============================================================
  // Categories Repository
  // ============================================================

  getIt.registerLazySingleton<CategoriesRepository>(
    () => CategoriesRepository(getIt<CategoriesRemoteDataSource>()),
  );

  // ============================================================
  // Categories Cubit
  // ============================================================

  getIt.registerFactory<CategoriesCubit>(
    () => CategoriesCubit(getIt<CategoriesRepository>()),
  );
}
