import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:warshity/features/auth/register/data/models/user_model.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
class AuthRepo {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FacebookAuth _facebookAuth = FacebookAuth.instance;

  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> initGoogle() async {
  await _googleSignIn.initialize(
    clientId:
        '861319834330-i1nejoiep8dkfrmu4ptl3qcd1kejadj6.apps.googleusercontent.com',
  );
}
Future<UserCredential> signInWithGoogle() async {
  UserCredential userCredential;

  if (kIsWeb) {
    final GoogleAuthProvider googleProvider = GoogleAuthProvider();
    userCredential = await _firebaseAuth.signInWithPopup(googleProvider);
  } else {
    await initGoogle();

    final GoogleSignInAccount googleUser =
        await _googleSignIn.authenticate();

    final GoogleSignInAuthentication googleAuth =
        googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    userCredential =
        await _firebaseAuth.signInWithCredential(credential);
  }

  final user = userCredential.user;

  if (user != null) {
    final userDoc = _firestore.collection('users').doc(user.uid);

    final exists = await userDoc.get();

    if (!exists.exists) {
      final newUser = UserModel(
        uid: user.uid,
        shopName: '',
        ownerName: user.displayName ?? '',
        email: user.email ?? '',
        activity: '',
      );

      await userDoc.set(newUser.toMap());
    }
  }

  return userCredential;
}

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
  Future<UserCredential> signInWithFacebook() async {
  final LoginResult result = await _facebookAuth.login();

  if (result.status != LoginStatus.success) {
    throw Exception(result.message ?? 'Facebook login failed');
  }

  final OAuthCredential credential =
      FacebookAuthProvider.credential(
    result.accessToken!.tokenString,
  );

  final userCredential =
      await _firebaseAuth.signInWithCredential(credential);

  final user = userCredential.user;

  if (user != null) {
    final userDoc = _firestore.collection('users').doc(user.uid);

    if (!(await userDoc.get()).exists) {
      await userDoc.set(
        UserModel(
          uid: user.uid,
          shopName: '',
          ownerName: user.displayName ?? '',
          email: user.email ?? '',
          activity: '',
        ).toMap(),
      );
    }
  }

  return userCredential;
}
}
abstract class AuthRepo {
  Future<void> login({required String email, required String password});

  Future<void> sendPasswordResetEmail(String email);

  Future<void> logout();
}
