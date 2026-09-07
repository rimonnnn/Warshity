import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:warshity/features/products/data/models/product_model.dart';

class ProductsRemoteDataSource {
  final FirebaseFirestore firestore;
  final SupabaseClient supabase;

  ProductsRemoteDataSource(this.firestore, this.supabase);

  Stream<List<ProductModel>> watchProducts() {
    return firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc.id, doc.data()))
          .toList();
    });
  }

  Future<String> uploadProductImage(
    Uint8List imageBytes,
    String originalFileName,
  ) async {
    final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    final String safeFileName = originalFileName.replaceAll(
      RegExp(r'[^a-zA-Z0-9._-]'),
      '_',
    );

    final String filePath = 'products/${timestamp}_$safeFileName';

    await supabase.storage
        .from('products')
        .uploadBinary(
          filePath,
          imageBytes,
          fileOptions: const FileOptions(upsert: false),
        );

    final String imageUrl = supabase.storage
        .from('products')
        .getPublicUrl(filePath);

    return imageUrl;
  }

  Future<void> addProduct(ProductModel product) async {
    await firestore.collection('products').add(product.toFirestore());
  }

  Future<void> deleteProduct(String productId) async {
    await firestore.collection('products').doc(productId).delete();
  }
  Future<void> decreaseProductQuantity(
  String productId,
  int quantity,
) async {
  await firestore.collection('products').doc(productId).update({
    'quantity': FieldValue.increment(-quantity),
  });
}
}
