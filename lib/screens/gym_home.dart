import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fitgen/ai_gym_trainer/features/ai_trainer/screens/home_screen.dart';
import 'package:fitgen/ai_gym_trainer/features/ai_trainer/services/firebase_service.dart';

class GymHome extends StatefulWidget {
  const GymHome({super.key});

  @override
  State<GymHome> createState() => _GymHomeState();
}

class _GymHomeState extends State<GymHome> {
  bool _isInitializing = true;
  String? _errorMessage;
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _initializeGymAuth();
  }

  Future<void> _initializeGymAuth() async {
    try {
      // Get fitgen Firebase auth instance (same as Medical Guidance)
      FirebaseAuth auth;
      try {
        auth = FirebaseAuth.instanceFor(app: Firebase.app('fitgen'));
      } catch (e) {
        auth = FirebaseAuth.instance;
      }

      // Check if user is already signed in
      final currentUser = auth.currentUser;

      if (currentUser == null) {
        // Sign in anonymously for seamless experience
        debugPrint('🔐 No gym user found, signing in anonymously...');
        final userCredential = await auth.signInAnonymously();
        debugPrint(
          '✅ Anonymous sign-in successful: ${userCredential.user?.uid}',
        );

        // Initialize anonymous user profile and gamification
        await _firebaseService.initializeAnonymousUser();
      } else {
        debugPrint('✅ Gym user already signed in: ${currentUser.uid}');

        // Initialize if anonymous user doesn't have profile yet
        if (currentUser.isAnonymous) {
          await _firebaseService.initializeAnonymousUser();
        }
      }

      setState(() {
        _isInitializing = false;
      });
    } catch (e) {
      debugPrint('❌ Error initializing gym auth: $e');
      setState(() {
        _errorMessage = 'Authentication failed: $e';
        _isInitializing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFFF97000)),
              SizedBox(height: 16),
              Text('Initializing AI Gym Trainer...'),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _errorMessage = null;
                    _isInitializing = true;
                  });
                  _initializeGymAuth();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Authentication successful, show home screen
    return const HomeScreen();
  }
}
