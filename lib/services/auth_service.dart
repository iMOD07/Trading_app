import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  static const _tokenKey    = 'auth_token';
  static const _usernameKey = 'username';
  static const _roleKey     = 'role';

  static Future<void> saveToken(String token, String username, {String role = 'USER'}) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_tokenKey, token);
    await p.setString(_usernameKey, username);
    await p.setString(_roleKey, role);
  }

  static Future<String?> getToken() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_tokenKey);
  }

  static Future<String?> getUsername() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_usernameKey);
  }

  static Future<String> getRole() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_roleKey) ?? 'USER';
  }

  static Future<bool> isAdmin() async {
    final role = await getRole();
    return role == 'ADMIN';
  }

  static Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_tokenKey);
    await p.remove(_usernameKey);
    await p.remove(_roleKey);
    ApiService.resetInstance();
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
