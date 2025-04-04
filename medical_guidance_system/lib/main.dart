import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/health_dashboard.dart'; // Import the HealthDashboard screen
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

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
      providers: [ChangeNotifierProvider(create: (_) => AuthService())],
      child: Consumer<AuthService>(
        builder: (context, authService, _) {
          return MaterialApp(
            title: 'Medical Guidance App',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            home:
                authService.currentUser != null
                    ? HomeScreen(
                      title: 'Home',
                      value: 42.toString(),
                      unit: 'units',
                      status: 'active',
                      icon: Icons.home,
                      progress: 0.75,
                      color: Colors.blue,
                    )
                    : LoginScreen(),
            routes: {
              '/login': (context) => LoginScreen(),

              '/signup': (context) => SignupScreen(),
              '/home':
                  (context) => HomeScreen(
                    title: 'Home',
                    value: 42.toString(),
                    unit: 'units',
                    status: 'active',
                    icon: Icons.home,
                    progress: 0.75,
                    color: Colors.blue,
                  ),
              '/profile': (context) => ProfileScreen(),

              '/dashboard':
                  (context) => HealthDashboard(), // Correct route for dashboard
            },
          );
        },
      ),
    );
  }
}
