import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:warshity/features/products/data/models/category_model.dart';

class CategoriesRemoteDataSource {
  final FirebaseFirestore firestore;

  CategoriesRemoteDataSource(this.firestore);

  Stream<List<CategoryModel>> watchCategories() {
    return firestore
        .collection('categories')
        .orderBy('name')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => CategoryModel.fromFirestore(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  Future<void> addCategory(String name) async {
    final categoryName = name.trim();

    if (categoryName.isEmpty) {
      throw Exception('Category name is required');
    }

    // منع تكرار نفس الاسم
    final existing = await firestore
        .collection('categories')
        .where('name', isEqualTo: categoryName)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception('Category already exists');
    }

    await firestore.collection('categories').add({
      'name': categoryName,
    });
  }
}