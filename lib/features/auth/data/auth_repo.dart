import 'package:firebase_auth/firebase_auth.dart';
import 'package:warshity/features/auth/register/data/models/user_model.dart';

abstract class AuthRepo {
  Future<UserCredential> login({
    required String email,
    required String password,
  });

  Future<UserCredential> signInWithGoogle();

  Future<UserCredential> signInWithFacebook();

  Future<void> logOut();

  Future<void> sendPasswordResetEmail(String email);

  Stream<User?> get authStateChanges;

  User? get currentUser;

  Stream<UserModel?> watchUserData();
  Future<void> changePassword({
  required String currentPassword,
  required String newPassword,
});
}