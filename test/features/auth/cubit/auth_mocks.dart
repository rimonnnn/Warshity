import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/annotations.dart';

import 'package:warshity/features/auth/data/auth_repo.dart';
import 'package:warshity/features/auth/register/data/repos/register_repo.dart';

@GenerateMocks([
  AuthRepo,
  RegisterRepo,
  UserCredential,
])
void main() {}
