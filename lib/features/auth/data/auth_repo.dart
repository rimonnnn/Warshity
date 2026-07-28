abstract class AuthRepo {
  Future<void> login({required String email, required String password});

  Future<void> sendPasswordResetEmail(String email);

  Future<void> logout();
}
