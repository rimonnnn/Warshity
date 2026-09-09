import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:warshity/features/auth/register/data/models/user_model.dart';
import 'package:warshity/features/auth/register/data/repos/register_repo.dart';

class RegisterRepoImpl implements RegisterRepo {
  RegisterRepoImpl(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  Future<void> register({
    required UserModel user,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: user.email,
        password: password,
      );

      log("User Created: ${credential.user?.email}");

      await credential.user!.sendEmailVerification();

      log("Verification Email Sent");

      final newUser = user.copyWith(
        uid: credential.user!.uid,
      );

      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(newUser.toMap());

      log("User Saved Successfully");
    } on FirebaseAuthException catch (e) {
      log("CODE: ${e.code}");
      log("MESSAGE: ${e.message}");
      rethrow;
    }
  }

@override
Future<void> addCategory(String categoryName) async {
  try {
    final name = categoryName.trim();

    if (name.isEmpty) {
      throw Exception('enter_category_name');
    }

    final existingCategory = await _firestore
        .collection('business_categories')
        .where('name', isEqualTo: name)
        .limit(1)
        .get();

    if (existingCategory.docs.isNotEmpty) {
      throw Exception('category_already_exists');
    }

    await _firestore
        .collection('business_categories')
        .add({
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
    });

    log(
      'Category Added Successfully: $name',
    );
  } catch (e) {
    log(
      'Add Category Error: $e',
    );

    rethrow;
  }
}
  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;

      if (user == null) {
        throw Exception('No current user found');
      }

      await user.sendEmailVerification();

      log("Verification Email Sent");
    } on FirebaseAuthException catch (e) {
      log("CODE: ${e.code}");
      log("MESSAGE: ${e.message}");
      rethrow;
    }
  }

  @override
  Future<void> resendEmailVerification() async {
    await sendEmailVerification();
  }

  @override
  Future<bool> isEmailVerified() async {
    await _auth.currentUser?.reload();

    return _auth.currentUser?.emailVerified ?? false;
  }
  @override
Stream<List<String>> watchCategories() {
  return _firestore
      .collection('business_categories')
      .orderBy('name')
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map(
              (doc) => doc.data()['name']?.toString() ?? '',
            )
            .where((name) => name.isNotEmpty)
            .toList(),
      );
}
}