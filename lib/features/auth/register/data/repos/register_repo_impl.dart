import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';
import 'register_repo.dart';

class RegisterRepoImpl implements RegisterRepo {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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

try {
  ("Before sendEmailVerification");

  await credential.user!.sendEmailVerification();

  ("After sendEmailVerification");
} catch (e, s) {
  ("Send verification failed: $e");
  (s);
}

     
      final newUser = user.copyWith(uid: credential.user!.uid);

      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(newUser.toMap());
      ("4");
    } on FirebaseAuthException catch (e) {
      log("CODE: ${e.code}");
      log("MESSAGE: ${e.message}");
      rethrow;
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  @override
  Future<void> resendEmailVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  @override
  Future<bool> isEmailVerified() async {
    await _auth.currentUser?.reload();

    return _auth.currentUser?.emailVerified ?? false;
  }
}
