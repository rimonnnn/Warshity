import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:warshity/features/auth/register/data/models/user_model.dart';

import 'auth_repo.dart';

class AuthRepoImpl implements AuthRepo {
  AuthRepoImpl(
    this._auth,
    this._googleSignIn,
    this._firestore,
  );

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  @override
  Future<UserCredential> login({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> logOut() async {
    await Future.wait([
      _auth.signOut(),
      FacebookAuth.instance.logOut(),
    ]);
  }

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Stream<UserModel?> watchUserData() {
    final uid = _auth.currentUser?.uid;

    if (uid == null) {
      return Stream.value(null);
    }

    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists || snapshot.data() == null) {
            return null;
          }

          return UserModel.fromMap(snapshot.data()!);
        });
  }

  @override
  Future<UserCredential> signInWithGoogle() async {
    await _googleSignIn.signOut();

    final googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      throw Exception('google_sign_in_cancelled');
    }

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _auth.signInWithCredential(credential);
  }

  @override
  Future<UserCredential> signInWithFacebook() async {
    final result = await FacebookAuth.instance.login(
      permissions: ['email', 'public_profile'],
    );

    if (result.status != LoginStatus.success) {
      if (result.status == LoginStatus.cancelled) {
        throw Exception('facebook_sign_in_cancelled');
      }

      throw Exception(
        result.message ?? 'facebook_sign_in_failed',
      );
    }

    final accessToken = result.accessToken;

    if (accessToken == null) {
      throw Exception('facebook_sign_in_failed');
    }

    final credential = FacebookAuthProvider.credential(
      accessToken.tokenString,
    );

    return await _auth.signInWithCredential(credential);
  }
  @override
Future<void> changePassword({
  required String currentPassword,
  required String newPassword,
}) async {
  final user = _auth.currentUser;

  if (user == null) {
    throw Exception('no_current_user'.tr());
  }

  final email = user.email;

  if (email == null || email.isEmpty) {
    throw Exception('email_not_found'.tr());
  }

  final credential = EmailAuthProvider.credential(
    email: email,
    password: currentPassword,
  );

  await user.reauthenticateWithCredential(
    credential,
  );

  await user.updatePassword(
    newPassword,
  );
}
}