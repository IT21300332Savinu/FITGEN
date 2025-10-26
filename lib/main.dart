import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

// Screens
import 'screens/gym_home.dart';
import 'screens/medical_home.dart';
import 'social_bridge_app.dart';

// Firebase configurations
import 'backend/firebase/firebase_config.dart';
import 'ai_medical_guidance/services/firebase_config .dart';

// Social Bridge (Special User flow) - Using updated paths
import 'social_bridge/f_i_t_g_e_n_app/authentication/f_i_t_g_e_n_first_page/f_i_t_g_e_n_first_page_widget.dart';

// Nutritionist
import 'ai_nutritionist/screens/meal_suggestion_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize all Firebase apps
  try {
    // 1. Social Bridge (Default Firebase)
    await initFirebase(); // From backend/firebase/firebase_config.dart
    debugPrint('✅ Social Bridge Firebase initialized');

    // 2. AI Nutritionist (Uses default Firebase or separate - check requirements)
    // Nutritionist uses Flask API backend, no separate Firebase needed

    // 3. AI Gym Trainer - Uses 'fitgen' Firebase (same as Medical Guidance)
    // No separate Firebase initialization needed - will use 'fitgen' app

    // 4. AI Medical Guidance (Separate Firebase)
    if (!kIsWeb) {
      await FirebaseConfig.initializeFirebase(); // Initialize medical Firebase
      debugPrint('✅ Medical Guidance Firebase initialized');
    }

  } catch (e) {
    debugPrint('⚠️ Firebase initialization error: $e');
  }

  runApp(const FitGenApp());
}

class FitGenApp extends StatelessWidget {
  const FitGenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FITGEN',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.orange,
          brightness: Brightness.light,
        ),
        primaryColor: Colors.orange,
        fontFamily: 'Outfit',
      ),
      home: const UserTypeChooser(),
      routes: {
        '/functions': (c) => const FunctionChooser(),
        '/gym': (c) => const GymHome(),
        '/medical': (c) => const MedicalHome(),
      },
    );
  }
}

// User Type Selection Screen
class UserTypeChooser extends StatelessWidget {
  const UserTypeChooser({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.orange.shade50,
              Colors.orange.shade100,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo/Title
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.fitness_center,
                          size: 80,
                          color: Colors.orange.shade700,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'FITGEN',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade800,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Your AI-Powered Fitness Companion',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 60),
                  
                  // User Type Selection
                  Text(
                    'Choose Your Experience',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Special User Button
                  _UserTypeButton(
                    icon: Icons.star_rounded,
                    title: 'Special User',
                    subtitle: 'Full Social & Fitness Platform',
                    color: Colors.deepOrange,
                    onTap: () {
                      // Navigate to FlutterFlow's Special User flow with full router support
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const SocialBridgeApp(),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Normal User Button
                  _UserTypeButton(
                    icon: Icons.person,
                    title: 'Normal User',
                    subtitle: 'Access AI Features Directly',
                    color: Colors.orange,
                    onTap: () => Navigator.pushNamed(context, '/functions'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UserTypeButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _UserTypeButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color, width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, size: 40, color: color),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

// Function Chooser for Normal Users
class FunctionChooser extends StatelessWidget {
  const FunctionChooser({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose AI Feature'),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.orange.shade700,
              Colors.orange.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              children: [
                _FeatureCard(
                  icon: Icons.fitness_center_rounded,
                  title: 'AI Gym\nTrainer',
                  gradient: [Colors.red.shade400, Colors.red.shade700],
                  onTap: () => Navigator.pushNamed(context, '/gym'),
                ),
                _FeatureCard(
                  icon: Icons.medical_services_rounded,
                  title: 'AI Medical\nGuidance',
                  gradient: [Colors.blue.shade400, Colors.blue.shade700],
                  onTap: () => Navigator.pushNamed(context, '/medical'),
                ),
                _FeatureCard(
                  icon: Icons.restaurant_menu_rounded,
                  title: 'AI\nNutritionist',
                  gradient: [Colors.green.shade400, Colors.green.shade700],
                  onTap: () {
                    // Navigate to nutritionist
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const MealSuggestionGate(),
                      ),
                    );
                  },
                ),
                _FeatureCard(
                  icon: Icons.people_rounded,
                  title: 'Social\nBridge',
                  gradient: [Colors.purple.shade400, Colors.purple.shade700],
                  onTap: () {
                    // Navigate to social bridge
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const FITGENFirstPageWidget(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: gradient[1].withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 64, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
