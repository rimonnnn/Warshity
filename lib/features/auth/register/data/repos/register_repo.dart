import '../models/user_model.dart';

abstract class RegisterRepo {
  /// إنشاء حساب جديد
  Future<void> register({
    required UserModel user,
    required String password,
  });

  /// إرسال رسالة تفعيل إلى البريد الإلكتروني
  Future<void> sendEmailVerification();

  /// إعادة إرسال رسالة التفعيل
  Future<void> resendEmailVerification();

  /// التحقق هل البريد الإلكتروني تم تفعيله أم لا
  Future<bool> isEmailVerified();
}