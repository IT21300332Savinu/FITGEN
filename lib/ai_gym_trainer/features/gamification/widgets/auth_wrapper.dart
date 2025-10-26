// lib/features/gamification/widgets/auth_wrapper.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import '../../ai_trainer/screens/home_screen.dart';
import '../../ai_trainer/screens/login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Get fitgen Firebase auth instance (same as Medical Guidance)
    FirebaseAuth auth;
    try {
      auth = FirebaseAuth.instanceFor(app: Firebase.app('fitgen'));
    } catch (e) {
      auth = FirebaseAuth.instance;
    }

    return StreamBuilder<User?>(
      stream: auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Loading screen
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFF97000)),
            ),
          );
        }

        final user = snapshot.data;

        if (user != null) {
          // User is logged in, go to home
          return const HomeScreen();
        } else {
          // User is not logged in, show login screen
          return const LoginScreen();
        }
      },
    );
  }
}
