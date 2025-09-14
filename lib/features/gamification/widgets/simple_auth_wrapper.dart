// lib/features/gamification/widgets/simple_auth_wrapper.dart

import 'package:flutter/material.dart';
import '../screens/simple_name_entry_screen.dart';
import '../services/user_session_service.dart';
import '../../ai_trainer/screens/home_screen.dart';

class SimpleAuthWrapper extends StatelessWidget {
  const SimpleAuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: UserSessionService.isUserLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Loading screen
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFFF97000),
              ),
            ),
          );
        }

        final isLoggedIn = snapshot.data ?? false;

        if (isLoggedIn) {
          // User has entered name, go to home
          return const HomeScreen();
        } else {
          // Show name entry screen
          return const SimpleNameEntryScreen();
        }
      },
    );
  }
}