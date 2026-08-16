import 'package:warshity/features/products/data/datascource/categories_remote_data_source.dart';
import 'package:warshity/features/products/data/models/category_model.dart';

class CategoriesRepository {
  final CategoriesRemoteDataSource remoteDataSource;

  CategoriesRepository(this.remoteDataSource);

  Stream<List<CategoryModel>> watchCategories() {
    return remoteDataSource.watchCategories();
  }

  Future<void> addCategory(String name) async {
    await remoteDataSource.addCategory(name);
  }
}