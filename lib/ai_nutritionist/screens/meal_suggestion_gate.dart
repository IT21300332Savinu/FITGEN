import 'package:flutter/material.dart';

import 'profile_screen_meal.dart';

class MealSuggestionGate extends StatefulWidget {
  const MealSuggestionGate({super.key});

  @override
  State<MealSuggestionGate> createState() => _MealSuggestionGateState();
}

class _MealSuggestionGateState extends State<MealSuggestionGate> {
  @override
  void initState() {
    super.initState();

    // 🚀 Navigate immediately to Profile Screen after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // If you use named routes via go_router:
        // context.goNamed('profile');

        // Or if you want to push the widget directly:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // simple splash while redirecting
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(color: Colors.orange),
      ),
    );
  }
}
