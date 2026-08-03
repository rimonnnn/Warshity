import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warshity/core/theme/theme_service.dart';
import 'package:warshity/features/auth/cubit/auth_cubit.dart';
import 'package:warshity/features/auth/data/auth_repo.dart';
import 'package:warshity/features/auth/data/auth_repo_impl.dart';
import 'package:warshity/features/auth/register/data/repos/register_repo.dart';
import 'package:warshity/features/auth/register/data/repos/register_repo_impl.dart';
import 'package:warshity/features/onboarding/data/onboarding_local_data_source.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);
  getIt.registerLazySingleton(() => ThemeService(getIt()));
  getIt.registerLazySingleton(() => OnboardingLocalDataSource(getIt()));

  // Firebase Core Instances
  getIt.registerLazySingleton(() => FirebaseAuth.instance);
  getIt.registerLazySingleton(() => FirebaseFirestore.instance);

  // Google Sign-In
  getIt.registerLazySingleton(() => GoogleSignIn());

  // Register feature
  getIt.registerLazySingleton<RegisterRepo>(
    () => RegisterRepoImpl(getIt(), getIt()),
  );

  // Auth feature (login, forgot password, logout, google/facebook sign-in)
  getIt.registerLazySingleton<AuthRepo>(() => AuthRepoImpl(getIt(), getIt()));

  // AuthCubit محتاجة الاتنين مع بعض
  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(getIt<RegisterRepo>(), getIt<AuthRepo>()),
  );
}
