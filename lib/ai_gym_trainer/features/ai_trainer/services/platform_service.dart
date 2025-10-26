// lib/features/ai_trainer/services/platform_service.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Simple platform check utilities
class PlatformService {
  /// Check if running on web
  static bool get isWeb => kIsWeb;
  
  /// Check if running on mobile
  static bool get isMobile => !kIsWeb;
  
  /// Get platform-specific camera constraints
  static Map<String, dynamic> getCameraConstraints() {
    if (isWeb) {
      return {
        'video': {
          'facingMode': 'user',
          'width': {'ideal': 640},
          'height': {'ideal': 480}
        },
        'audio': false
      };
    } else {
      // Mobile constraints are handled by camera plugin
      return {};
    }
  }
  
  /// Show platform-specific permission message
  static String getPermissionMessage() {
    if (isWeb) {
      return 'Please allow camera access when prompted by your browser';
    } else {
      return 'Camera permission is required for pose detection';
    }
  }
  
  /// Get platform-specific error handling
  static void handlePlatformError(String error, BuildContext context) {
    String message;
    
    if (isWeb) {
      if (error.contains('camera')) {
        message = 'Camera access denied. Please refresh and allow camera access.';
      } else {
        message = 'Web error: $error';
      }
    } else {
      if (error.contains('permission')) {
        message = 'Camera permission required. Please enable in settings.';
      } else if (error.contains('camera')) {
        message = 'Camera unavailable. Please check if camera is being used by another app.';
      } else {
        message = 'Mobile error: $error';
      }
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}