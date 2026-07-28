import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warshity/core/theme/theme_service.dart';
import 'package:warshity/features/auth/data/auth_repo.dart';
import 'package:warshity/features/auth/register/data/repos/register_repo.dart';
import 'package:warshity/features/auth/register/data/repos/register_repo_impl.dart';
import 'package:warshity/features/auth/cubit/auth_cubit.dart';
import 'package:warshity/features/onboarding/data/onboarding_local_data_source.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);
  getIt.registerLazySingleton(() => ThemeService(getIt()));
  getIt.registerLazySingleton(() => OnboardingLocalDataSource(getIt()));

  // Firebase
  getIt.registerLazySingleton(() => FirebaseAuth.instance);
  getIt.registerLazySingleton(() => FirebaseFirestore.instance);

  // Auth
  getIt.registerLazySingleton<RegisterRepo>(
    () => RegisterRepoImpl(getIt(), getIt()),
  );
  getIt.registerFactory<AuthCubit>(() => AuthCubit(getIt<RegisterRepo>(),getIt<AuthRepo>()));
   // Repository
  getIt.registerLazySingleton<AuthRepo>(
    () => AuthRepo(),
  );
}

