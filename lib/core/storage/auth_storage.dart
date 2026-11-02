import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/features/auth/data/models/login_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const accessTokenKey = 'auth.accessToken';
  static const refreshTokenKey = 'auth.refreshToken';
  static const userIdKey = 'auth.userId';
  static const roleKey = 'auth.role';
  final FlutterSecureStorage storage;

  const AuthStorage(this.storage);

  Future<void> saveLogin(LoginResponse response) async {
    await storage.write(key: accessTokenKey, value: response.accessToken);
    await storage.write(key: refreshTokenKey, value: response.refreshToken);
    await storage.write(key: userIdKey, value: response.userId.toString());
    await storage.write(key: roleKey, value: response.role);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nickname', response.nickname);
    await prefs.setString('email', response.email);
  }

  Future<String?> readAccessToken() {
    return storage.read(key: accessTokenKey);
  }

  Future<String?> readRefreshToken() {
    return storage.read(key: refreshTokenKey);
  }

  Future<void> clear() async {
    await storage.deleteAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('nickname');
    await prefs.remove('email');
  }

  Future<void> clearPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> updateTokens(String accessToken, String refreshToken) async {
    await storage.write(key: accessTokenKey, value: accessToken);
    await storage.write(key: refreshTokenKey, value: refreshToken);
  }
}
