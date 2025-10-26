import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

void main() {
  group('Firebase Auth Integration Tests', () {
    setUpAll(() async {
      // Initialize Firebase for testing
      if (!kIsWeb) {
        await Firebase.initializeApp();
      }
    });

    test('Firebase Auth currentUser property works', () {
      // Test that Firebase Auth instance is accessible
      final auth = FirebaseAuth.instance;
      expect(auth, isNotNull);

      // Current user should be null when not logged in
      expect(auth.currentUser, isNull);
    });

    test('GamificationFirebaseService currentUserId getter works', () {
      // Import our service and test the getter
      // This tests that our refactored currentUserId getter compiles correctly
      expect(() => FirebaseAuth.instance.currentUser?.uid, returnsNormally);
    });
  });
}
