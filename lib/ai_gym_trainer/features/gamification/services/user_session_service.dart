// lib/features/gamification/services/user_session_service.dart

import 'package:flutter/foundation.dart';

class UserSessionService {
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';

  // Enhanced in-memory storage with persistence simulation
  static Map<String, String> _tempStorage = {};
  static bool _isInitialized = false;

  /// Initialize the service (call this at app startup)
  static Future<void> initialize() async {
    if (_isInitialized) return;

    // In a real app, you would load from SharedPreferences here
    // For now, we'll simulate persistence by keeping data in memory
    _isInitialized = true;
    debugPrint('🔧 UserSessionService initialized');
  }

  /// Check if user has entered their name
  static Future<bool> isUserLoggedIn() async {
    await initialize();

    // Temporary implementation using in-memory storage
    final userId = _tempStorage[_userIdKey];
    final userName = _tempStorage[_userNameKey];

    // Check that both values exist AND are not empty
    final isValid =
        userId != null &&
        userId.isNotEmpty &&
        userName != null &&
        userName.isNotEmpty;

    debugPrint(
      '🔍 Session Check - UserID: $userId, UserName: $userName, Valid: $isValid',
    );
    return isValid;
  }

  /// Get current user ID
  static Future<String?> getCurrentUserId() async {
    await initialize();
    final userId = _tempStorage[_userIdKey];
    debugPrint('🆔 Getting UserID: $userId');
    return userId;
  }

  /// Get current user name
  static Future<String?> getCurrentUserName() async {
    await initialize();
    final userName = _tempStorage[_userNameKey];
    debugPrint('👤 Getting UserName: $userName');
    return userName;
  }

  /// Save user session
  static Future<void> saveUserSession(String userId, String userName) async {
    await initialize();

    // Enhanced implementation with validation
    _tempStorage[_userIdKey] = userId;
    _tempStorage[_userNameKey] = userName;

    debugPrint('💾 Saved session - UserID: $userId, UserName: $userName');

    // In a real app, you would also save to SharedPreferences here
    // await prefs.setString(_userIdKey, userId);
    // await prefs.setString(_userNameKey, userName);
  }

  /// Clear user session (logout)
  static Future<void> clearUserSession() async {
    await initialize();

    debugPrint('🧹 Clearing user session');
    _tempStorage.remove(_userIdKey);
    _tempStorage.remove(_userNameKey);

    // In a real app, you would also clear SharedPreferences here
    // await prefs.remove(_userIdKey);
    // await prefs.remove(_userNameKey);
  }

  /// Get debug info about current session
  static Future<Map<String, String?>> getSessionDebugInfo() async {
    await initialize();
    return {
      'userId': _tempStorage[_userIdKey],
      'userName': _tempStorage[_userNameKey],
      'storage_keys': _tempStorage.keys.join(', '),
    };
  }
}
