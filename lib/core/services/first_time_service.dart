import 'package:shared_preferences/shared_preferences.dart';

class FirstTimeService {
  static const String _hasSeenWelcomeKey = 'hasSeenWelcome';
  static const String _isLoggedInKey = 'isLoggedIn';

  /// Check if this is the first time the user is opening the app
  static Future<bool> isFirstTimeUser() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenWelcome = prefs.getBool(_hasSeenWelcomeKey);
    return hasSeenWelcome != true;
  }

  /// Mark that the user has seen the welcome screen
  static Future<void> markWelcomeAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenWelcomeKey, true);
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  /// Set user login status
  static Future<void> setLoggedIn(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, isLoggedIn);
  }

  /// Clear all user data (for logout or reset)
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_hasSeenWelcomeKey);
    await prefs.remove(_isLoggedInKey);
  }

  /// Reset app to first-time user state (useful for testing)
  static Future<void> resetToFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_hasSeenWelcomeKey);
    await prefs.remove(_isLoggedInKey);
  }
}
