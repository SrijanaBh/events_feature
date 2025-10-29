/*
import 'package:shared_preferences/shared_preferences.dart';

class AuthManager {
  static const _authTokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userNameKey = 'user_name';
  static const _userEmailKey = 'user_email';
  static const _userPhoneKey = 'user_phone';
  static const _userIdKey = 'user_id';
  static const _clubIdKey = 'club_id';

  // 🔹 Save login session
  static Future<void> saveLoginSession({
    required String authToken,
    required String refreshToken,
    required int userId,
    required int clubId,
    String? name,
    String? email,
    String? phone,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, authToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
    await prefs.setInt(_userIdKey, userId);
    await prefs.setInt(_clubIdKey, clubId);
    if (name != null) await prefs.setString(_userNameKey, name);
    if (email != null) await prefs.setString(_userEmailKey, email);
    if (phone != null) await prefs.setString(_userPhoneKey, phone);
  }

  // 🔹 Retrieve saved info
  static Future<Map<String, dynamic>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'authToken': prefs.getString(_authTokenKey),
      'refreshToken': prefs.getString(_refreshTokenKey),
      'name': prefs.getString(_userNameKey),
      'email': prefs.getString(_userEmailKey),
      'phone': prefs.getString(_userPhoneKey),
      'userId': prefs.getInt(_userIdKey),
      'clubId': prefs.getInt(_clubIdKey),
    };
  }

  // 🔹 Check if logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey) != null;
  }

  // 🔹 Logout and clear all data
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

*/

import 'package:shared_preferences/shared_preferences.dart';

class AuthManager {
  static const _authTokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userNameKey = 'user_name';
  static const _userEmailKey = 'user_email';
  static const _userPhoneKey = 'user_phone';
  static const _clubIdKey = 222;
  static const _userIDKey = 1;

  // Save login session
  static Future<void> saveLoginSession({
    required String authToken,
    required String refreshToken,
    String? name,
    String? email,
    String? phone,
    int? clubId,
    int? userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, authToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
    if (name != null) await prefs.setString(_userNameKey, name);
    if (email != null) await prefs.setString(_userEmailKey, email);
    if (phone != null) await prefs.setString(_userPhoneKey, phone);
  }

  // Get stored user info
  static Future<Map<String, String?>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'authToken': prefs.getString(_authTokenKey),
      'refreshToken': prefs.getString(_refreshTokenKey),
      'name': prefs.getString(_userNameKey),
      'email': prefs.getString(_userEmailKey),
      'phone': prefs.getString(_userPhoneKey),
      'clubId': _clubIdKey.toString(),
      'userId': _userIDKey.toString(),
    };
  }

  // Check if logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey) != null;
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}


/*
import 'package:shared_preferences/shared_preferences.dart';

class AuthManager {
  static const _authTokenKey = 'auth_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _isLoggedInKey = 'is_logged_in';

  /// ✅ Save tokens & login status
  static Future<void> saveLoginSession({
    required String authToken,
    required String refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, authToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
    await prefs.setBool(_isLoggedInKey, true);
  }

  /// ✅ Clear all tokens and mark logged out
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.setBool(_isLoggedInKey, false);
  }

  /// ✅ Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  /// ✅ Retrieve tokens when needed
  static Future<String?> getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }
}
*/