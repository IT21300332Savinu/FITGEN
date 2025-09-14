import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Fixed import paths
import 'features/ai_trainer/screens/home_screen.dart';
import 'features/ai_trainer/screens/login_screen.dart';
import 'features/ai_trainer/screens/signup_screen.dart';
import 'features/ai_trainer/screens/profile_setup_screen.dart';
import 'features/ai_trainer/services/firebase_service.dart';

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider<FirebaseService>(
      create: (_) => FirebaseService(),
      child: MaterialApp(
        title: 'FITGEN',
        theme: ThemeData(
          // Light theme only - removed dark theme
          primarySwatch: createMaterialColor(const Color(0xFFF97000)), // Orange
          visualDensity: VisualDensity.adaptivePlatformDensity,
          brightness: Brightness.light,

          // Enhanced light theme
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: createMaterialColor(
              const Color(0xFFF97000),
            ), // Orange
            brightness: Brightness.light,
            accentColor: const Color(0xFFF97000), // Orange accent
            backgroundColor: Colors.white,
          ).copyWith(
            surface: Colors.white,
            onSurface: Colors.black87,
            secondary: const Color(0xFFF97000),
            onSecondary: Colors.white,
          ),

          // App bar theme
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFF97000),
            foregroundColor: Colors.white,
            elevation: 2,
            centerTitle: true,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Scaffold theme
          scaffoldBackgroundColor: Colors.white,

          // Card theme
          cardTheme: const CardThemeData(
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),

          // Button themes
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF97000),
              foregroundColor: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),

          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFFF97000),
            foregroundColor: Colors.white,
          ),

          // Input decoration theme
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFF97000), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),

          // Text themes
          textTheme: const TextTheme(
            displayLarge: TextStyle(color: Colors.black87),
            displayMedium: TextStyle(color: Colors.black87),
            displaySmall: TextStyle(color: Colors.black87),
            headlineLarge: TextStyle(color: Colors.black87),
            headlineMedium: TextStyle(color: Colors.black87),
            headlineSmall: TextStyle(color: Colors.black87),
            titleLarge: TextStyle(color: Colors.black87),
            titleMedium: TextStyle(color: Colors.black87),
            titleSmall: TextStyle(color: Colors.black87),
            bodyLarge: TextStyle(color: Colors.black87),
            bodyMedium: TextStyle(color: Colors.black87),
            bodySmall: TextStyle(color: Colors.black87),
            labelLarge: TextStyle(color: Colors.black87),
            labelMedium: TextStyle(color: Colors.black87),
            labelSmall: TextStyle(color: Colors.black87),
          ),

          // Bottom navigation theme
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
            selectedItemColor: Color(0xFFF97000),
            unselectedItemColor: Colors.grey,
            elevation: 8,
          ),

          // Divider theme
          dividerTheme: DividerThemeData(
            color: Colors.grey.shade300,
            thickness: 1,
          ),
        ),

        // Remove dark theme completely
        themeMode: ThemeMode.light, // Force light theme only

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
                  backgroundColor: Colors.white, // Light background
                  body: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFF97000), // Orange loading indicator
                    ),
                  ),
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
        return const Scaffold(
          backgroundColor: Colors.white, // Light background
          body: Center(
            child: CircularProgressIndicator(
              color: Color(0xFFF97000), // Orange loading indicator
            ),
          ),
        );
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
