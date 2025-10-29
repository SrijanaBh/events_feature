import 'package:shared_preferences/shared_preferences.dart'; 
class SessionManager 
{ 
  static final SessionManager _instance = SessionManager._internal(); 
  factory SessionManager() => _instance; SessionManager._internal(); 
  String? authToken; String? refreshToken; String? userName; 
  String? userEmail; String? userPhone; 
  // 🔹 Load session data into memory 
  Future<void> loadSession() async { 
    final prefs = await SharedPreferences.getInstance(); 
    authToken = prefs.getString('auth_token'); 
    refreshToken = prefs.getString('refresh_token'); 
    userName = prefs.getString('user_name'); 
    userEmail = prefs.getString('user_email'); 
    userPhone = prefs.getString('user_phone'); 
    } /// 🔹 Clear session when user logs out 
    Future<void> clearSession() async { 
      final prefs = await SharedPreferences.getInstance(); 
      await prefs.clear(); 
      authToken = null; 
      refreshToken = null; 
      userName = null; 
      userEmail = null; 
      userPhone = null; 
  } }