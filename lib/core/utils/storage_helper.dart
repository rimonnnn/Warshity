import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageHelper {
  final storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      // ignore: deprecated_member_use
      encryptedSharedPreferences: true, // Works without biometrics
    ),
  );
  Future saveToken(String accessToken, String refreshToken) async {
    await storage.write(key: "accessToken", value: accessToken);
    await storage.write(key: "refreshToken", value: refreshToken);
  }

  Future<String?> getAccessToken() async {
    return await storage.read(key: "accessToken") ?? "";
  }

  Future<String?> getRefreshToken() async {
    return await storage.read(key: "refreshToken") ?? "";
  }

  Future<void> clearTokens() async {
    await storage.delete(key: "accessToken");
    await storage.delete(key: "refreshToken");
  }
}
