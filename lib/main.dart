import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// Import for web-specific features

import 'features/ai_trainer/screens/home_screen.dart';
import 'features/ai_trainer/screens/login_screen.dart';
import 'features/ai_trainer/screens/signup_screen.dart';
import 'features/ai_trainer/screens/profile_setup_screen.dart';
import 'features/ai_trainer/services/firebase_service.dart';

// Add the following imports to main.dart

// // Add to your main.dart
// void _checkCameraPermissions() async {
//   if (kIsWeb) {
//     // For web, we'll check at the time of camera initialization
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Please allow camera access when prompted'),
//         duration: Duration(seconds: 3),
//       ),
//     );
//   } else {
//     // For mobile, check permissions here
//   }
//}

// Then in the main() function:
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  if (kIsWeb) {
    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyDZawBGupkkbzaF_M_RN1gvnsNP3IjlnoA",
          authDomain: "fitgen-bd7d8.firebaseapp.com",
          projectId: "fitgen-bd7d8",
          storageBucket: "fitgen-bd7d8.firebasestorage.app",
          messagingSenderId: "47999782996",
          appId: "1:47999782996:web:6e92b59c6139c9f03f5dc1",
          measurementId: "G-3ETVGV9BRT",
        ),
      );
      debugPrint('Firebase initialized for web successfully');
    } catch (e) {
      debugPrint('Firebase initialization error: $e');
    }
  } else {
    // Mobile Firebase initialization
    await Firebase.initializeApp();
    debugPrint('Firebase initialized for mobile successfully');
  }

  runApp(const MyApp());
}
// Rest of the code remains the same as in your previous main.dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<FirebaseService>(
      create: (_) => FirebaseService(),
      child: MaterialApp(
        title: 'FITGEN',
        theme: ThemeData(
          primarySwatch: createMaterialColor(const Color(0xFFF97000)), // Orange
          visualDensity: VisualDensity.adaptivePlatformDensity,
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: createMaterialColor(
              const Color(0xFFF97000),
            ), // Orange
            brightness: Brightness.light,
            accentColor: const Color(0xFFF97000), // Orange accent
          ),
        ),
        darkTheme: ThemeData(
          primarySwatch: createMaterialColor(const Color(0xFFF97000)), // Orange
          visualDensity: VisualDensity.adaptivePlatformDensity,
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: createMaterialColor(
              const Color(0xFFF97000),
            ), // Orange
            brightness: Brightness.dark,
            accentColor: const Color(0xFFF97000), // Orange accent
          ),
        ),
        themeMode: ThemeMode.system,
        home: const AuthenticationWrapper(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/profile_setup': (context) => const ProfileSetupScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }

  // Existing createMaterialColor method remains the same
  MaterialColor createMaterialColor(Color color) {
    List<double> strengths = <double>[.05, .1, .2, .3, .4, .5, .6, .7, .8, .9];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}

// Rest of the code remains the same

  // Existing createMaterialColor method remains the same
  MaterialColor createMaterialColor(Color color) {
    List<double> strengths = <double>[.05, .1, .2, .3, .4, .5, .6, .7, .8, .9];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }


// Existing AuthenticationWrapper remains the same (from previous main.dart)
class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;

          if (user == null) {
            return const LoginScreen();
          }

          // Check if user has a profile
          return FutureBuilder<bool>(
            future: _hasUserProfile(context, user.uid),
            builder: (context, profileSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final hasProfile = profileSnapshot.data ?? false;

              if (hasProfile) {
                return const HomeScreen();
              } else {
                return const ProfileSetupScreen();
              }
            },
          );
        }

        // Show a loading screen while checking authentication state
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }

  Future<bool> _hasUserProfile(BuildContext context, String userId) async {
    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );
    final profile = await firebaseService.getUserProfile();
    return profile != null;
  }
}