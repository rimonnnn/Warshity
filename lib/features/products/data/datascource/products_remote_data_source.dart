import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:warshity/features/products/data/models/product_model.dart';

class ProductsRemoteDataSource {
  final FirebaseFirestore firestore;
  final SupabaseClient supabase;

  ProductsRemoteDataSource(
    this.firestore,
    this.supabase,
  );

  // ============================================================
  // Watch Products
  // ============================================================

  Stream<List<ProductModel>> watchProducts() {
    return firestore.collection('products').snapshots().map(
      (snapshot) {
        return snapshot.docs
            .map(
              (doc) => ProductModel.fromFirestore(
                doc.id,
                doc.data(),
              ),
            )
            .toList();
      },
    );
  }

  // ============================================================
  // Upload Product Image
  // ============================================================

  Future<String> uploadProductImage(File imageFile) async {
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';

    final filePath = 'products/$fileName';

    await supabase.storage.from('products').upload(
      filePath,
      imageFile,
      fileOptions: const FileOptions(
        upsert: false,
      ),
    );

    final imageUrl = supabase.storage
        .from('products')
        .getPublicUrl(filePath);

    return imageUrl;
  }

  // ============================================================
  // Add Product
  // ============================================================

  Future<void> addProduct(ProductModel product) async {
    await firestore
        .collection('products')
        .add(product.toFirestore());
  }
}