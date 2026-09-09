import '../models/user_model.dart';

abstract class RegisterRepo {
  /// إنشاء حساب جديد
  Future<void> register({
    required UserModel user,
    required String password,
  });

  /// إضافة Business Activity جديدة
  Future<void> addCategory(String categoryName);

  /// جلب Business Activities من Firestore
  Stream<List<String>> watchCategories();

  /// إرسال رسالة تفعيل إلى البريد الإلكتروني
  Future<void> sendEmailVerification();

  /// إعادة إرسال رسالة التفعيل
  Future<void> resendEmailVerification();

  /// التحقق هل البريد الإلكتروني تم تفعيله أم لا
  Future<bool> isEmailVerified();
}