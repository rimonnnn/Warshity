import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:warshity/features/auth/data/auth_repo.dart';
import 'package:warshity/features/auth/register/data/models/user_model.dart';

class AuthRepoImpl implements AuthRepo {
  AuthRepoImpl(this._auth);

  final FirebaseAuth _auth;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FacebookAuth _facebookAuth = FacebookAuth.instance;

  @override
  Future<void> login({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
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

  @override
  Future<UserCredential> signInWithGoogle() async {
    UserCredential userCredential;

    if (kIsWeb) {
      final googleProvider = GoogleAuthProvider();

      userCredential = await _auth.signInWithPopup(
        googleProvider,
      );
    } else {
      await initGoogle();

      final GoogleSignInAccount googleUser =
          await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth =
          googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      userCredential = await _auth.signInWithCredential(
        credential,
      );
    }

    await _saveUser(userCredential.user);

    return userCredential;
  }

  @override
  Future<UserCredential> signInWithFacebook() async {
    final LoginResult result = await _facebookAuth.login();

    if (result.status != LoginStatus.success) {
      throw Exception(result.message ?? 'Facebook login failed');
    }

    final credential = FacebookAuthProvider.credential(
      result.accessToken!.tokenString,
    );

    final userCredential = await _auth.signInWithCredential(
      credential,
    );

    await _saveUser(userCredential.user);

    return userCredential;
  }

  Future<void> _saveUser(User? user) async {
    if (user == null) return;

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

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(
      email: email,
    );
  }

  @override
  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _facebookAuth.logOut();
    await _auth.signOut();
  }

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  User? get currentUser => _auth.currentUser;
}