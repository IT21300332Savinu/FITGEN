import 'package:flutter/material.dart';
import 'package:fitgen/ai_medical_guidance/screens/profile_screen.dart';

class MedicalHome extends StatelessWidget {
  const MedicalHome({super.key});

  @override
  Widget build(BuildContext context) {
    // Navigate directly to the medical guidance profile/dashboard screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ProfileScreen(isUpdate: false),
        ),
      );
    });

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
