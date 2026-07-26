// import 'package:ecommerce_app/core/networking/dio_helper.dart';
// import 'package:ecommerce_app/core/utils/storage_helper.dart';
// import 'package:ecommerce_app/features/auth/cubit/auth_cubit.dart';
// import 'package:ecommerce_app/features/auth/repo/auth_repo.dart';
// import 'package:ecommerce_app/features/cart_screen/cart_local_data_source.dart';
// import 'package:ecommerce_app/features/cart_screen/cubit/cart_cubit.dart';
// import 'package:ecommerce_app/features/favorite_screen/cubit/favorite_cubit.dart';
// import 'package:ecommerce_app/features/favorite_screen/favorite_local_data_source.dart';
// import 'package:ecommerce_app/features/home_screen/cubit/categories_cubit.dart';
// import 'package:ecommerce_app/features/home_screen/cubit/products_cubit.dart';
// import 'package:ecommerce_app/features/home_screen/repo/home_repo.dart';
// import 'package:get_it/get_it.dart';

// GetIt sl = GetIt.instance;

// void setupServicesLocator() {
//   DioHelper dio = DioHelper();

//   sl.registerLazySingleton<DioHelper>(() => dio);
//   sl.registerLazySingleton<AuthRepo>(() => AuthRepo(sl()));
//   sl.registerLazySingleton<HomeRepo>(() => HomeRepo(sl()));
//   sl.registerLazySingleton(() => StorageHelper());
//   sl.registerFactory(() => AuthCubit(sl<AuthRepo>(), sl<StorageHelper>()));
//   sl.registerFactory(() => ProductsCubit(sl<HomeRepo>()));
//   sl.registerFactory(() => CategoriesCubit(sl<HomeRepo>()));

//   // Scoped by ShellRoute: same instance shared across Main/ProductDetails/Cart
//   sl.registerLazySingleton<CartLocalDataSource>(() => CartLocalDataSource());

//   sl.registerLazySingleton<CartCubit>(
//     () => CartCubit(sl<CartLocalDataSource>()),
//   );
//   sl.registerLazySingleton<FavoriteLocalDataSource>(
//     () => FavoriteLocalDataSource(),
//   );

//   // Scoped globally: نفس الـ instance في كل التطبيق عشان الـ favorites تفضل متزامنة
//   sl.registerLazySingleton<FavoriteCubit>(
//     () => FavoriteCubit(sl<FavoriteLocalDataSource>()),
//   );
// }
import 'package:get_it/get_it.dart';
import 'package:warshity/features/auth/register/data/repos/register_repo.dart';
import 'package:warshity/features/auth/register/data/repos/register_repo_impl.dart';
import 'package:warshity/features/auth/register/presentation/cubit/auth_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
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