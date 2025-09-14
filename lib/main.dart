// lib/main.dart (modification)
import 'package:fitgen/screens/custom_meal_plan_list_screen.dart';
import 'package:fitgen/screens/custom_meal_plan_screen.dart';
import 'package:fitgen/screens/custom_meal_plan_view_screen.dart';
import 'package:fitgen/screens/custom_plan_detail_screen.dart';
import 'package:fitgen/screens/custom_plan_suggestion_screen.dart';
import 'package:fitgen/screens/meal_suggestion_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'screens/profile_screen.dart';
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
        ChangeNotifierProvider(create: (_) => AuthService()), // Add this
      ],
      child: Consumer<AuthService>(
        builder: (context, authService, _) {
          return MaterialApp(
            title: 'Medical Guidance App',
            // theme: AppTheme.lightTheme,
            // darkTheme: AppTheme.darkTheme,
            // themeMode: ThemeMode.dark,

            theme: ThemeData(
              primarySwatch: Colors.orange,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.orange,
                brightness: Brightness.light,
                primary: Colors.orange,
                secondary: Colors.deepOrange,
                surface: Colors.white,
              ),
              scaffoldBackgroundColor: Colors.grey[50],
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                elevation: 2,
                centerTitle: true
              ),
              cardTheme: CardThemeData(
                color: Colors.white,
                elevation: 4,
                shadowColor: Colors.grey.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.orange, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              checkboxTheme: CheckboxThemeData(
                fillColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return Colors.orange;
                  }
                  return Colors.white;
                }),
              ),
              useMaterial3: true,
            ),

            themeMode: ThemeMode.light,

            home:
            authService.currentUser != null
                ? ProfileScreen()
                : ProfileScreen(),
            routes: {
              '/profile': (context) => ProfileScreen(),
              '/meal-suggestion': (context) => MealSuggestionScreen(),
              '/custom-meal-plan': (_) => const CustomMealPlanScreen(),
              '/custom-meal-plan-list': (_) => const CustomMealPlanListScreen(),
              '/custom-meal-plan-view': (_) => const CustomMealPlanViewScreen(),
              '/custom-plan-suggestion': (_) => const CustomPlanSuggestionScreen(),
              '/custom-plan-detail': (_) => const CustomPlanDetailScreen(),
            },
          );
        },
      ),
    );
  }

}



