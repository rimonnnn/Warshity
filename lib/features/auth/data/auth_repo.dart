import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepo {
  Future<void> login({
    required String email,
    required String password,
  });

  Future<UserCredential> signInWithGoogle();

  Future<UserCredential> signInWithFacebook();

  Future<void> sendPasswordResetEmail(String email);

  Future<void> logout();

  Stream<User?> get authStateChanges;

  User? get currentUser;
}