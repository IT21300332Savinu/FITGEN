import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'views/home_screen.dart';
import 'views/health_dashboard.dart';
import 'views/workout_planner.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI Medical Guidance',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/', // Home Screen
      routes: {
        '/': (context) => const HomeScreen(),
        '/dashboard': (context) => const HealthDashboard(),
        '/workout': (context) => const WorkoutPlanner(),
      },
    );
  }
}
