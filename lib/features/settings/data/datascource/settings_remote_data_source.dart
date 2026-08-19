import 'package:firebase_auth/firebase_auth.dart';

class SettingsRemoteDataSource {
  SettingsRemoteDataSource(this._auth);

  final FirebaseAuth _auth;

  Future<void> logOut() async {
    await _auth.signOut();
  }
}