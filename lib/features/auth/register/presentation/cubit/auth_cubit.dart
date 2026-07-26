import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/user_model.dart';
import '../../data/repos/register_repo.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final RegisterRepo registerRepo;

  AuthCubit(this.registerRepo) : super(AuthInitial());

  Future<void> register({
    required UserModel user,
    required String password,
  }) async {
    emit(AuthLoading());

    try {
      await registerRepo.register(
        user: user,
        password: password,
      );

      emit(RegisterSuccess(
        "Account created successfully. Please verify your email.",
      ));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> checkEmailVerification() async {
    emit(AuthLoading());

    try {
      final verified = await registerRepo.isEmailVerified();

      if (verified) {
        emit(RegisterSuccess("Email verified successfully"));
      } else {
        emit(AuthError("Email is not verified yet"));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> resendVerificationEmail() async {
    try {
      await registerRepo.resendEmailVerification();

      emit(
        EmailVerificationSent(
          "Verification email sent successfully",
        ),
      );
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}