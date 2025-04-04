// lib/main.dart (modification)
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'providers/health_provider.dart';
import 'providers/mock_wearable_provider.dart'; // Add this
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/health_dashboard.dart';
import 'screens/profile_screen.dart';
import 'screens/exercise_guide.dart';
import 'screens/workout_planner.dart';
import 'screens/pain_detection.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Firebase initialization error: $e');
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => HealthProvider()),
        ChangeNotifierProvider(
          create: (_) => MockWearableProvider(),
        ), // Add this
      ],
      child: Consumer<AuthService>(
        builder: (context, authService, _) {
          return MaterialApp(
            title: 'Medical Guidance App',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            home:
                authService.currentUser != null
                    ? HealthDashboard()
                    : LoginScreen(),
            routes: {
              '/login': (context) => LoginScreen(),
              '/signup': (context) => SignupScreen(),
              '/dashboard': (context) => HealthDashboard(),
              '/profile': (context) => ProfileScreen(),
              '/exercise_guide': (context) => ExerciseGuide(),
              '/workout_planner': (context) => WorkoutPlanner(),
              '/pain_detection': (context) => PainDetection(),
            },
          );
        },
      ),
    );
  }
}
