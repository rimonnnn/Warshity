import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'auth_repo.dart';

class AuthRepoImpl implements AuthRepo {
  AuthRepoImpl(this._auth, this._googleSignIn);

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

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
    // مهم: تسجيل الخروج من Facebook SDK نفسه كمان، مش بس Firebase
    // وإلا المستخدم هيلاقي نفسه "متسجل دخول" في Facebook SDK رغم إنه عمل logout من التطبيق
    await Future.wait([_auth.signOut(), FacebookAuth.instance.logOut()]);
  }

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  User? get currentUser => _auth.currentUser;

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
      // المستخدم لغى العملية، أو حصل رفض إذن — مش خطأ تقني حقيقي
      if (result.status == LoginStatus.cancelled) {
        throw Exception('facebook_sign_in_cancelled');
      }
      throw Exception(result.message ?? 'facebook_sign_in_failed');
    }

    final accessToken = result.accessToken;
    if (accessToken == null) {
      throw Exception('facebook_sign_in_failed');
    }

    final credential = FacebookAuthProvider.credential(accessToken.tokenString);
    return await _auth.signInWithCredential(credential);
  }
}
