import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:warshity/core/theme/theme_service.dart';
import 'package:warshity/features/auth/register/data/repos/register_repo.dart';
import 'package:warshity/features/auth/register/data/repos/register_repo_impl.dart';
import 'package:warshity/features/auth/register/presentation/cubit/auth_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);
  getIt.registerLazySingleton(() => ThemeService(getIt()));
   // Firebase Repository
  getIt.registerLazySingleton<RegisterRepo>(
    () => RegisterRepoImpl(),
  );

  // Auth Cubit
  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(
      getIt<RegisterRepo>(),
    ),
  );
}