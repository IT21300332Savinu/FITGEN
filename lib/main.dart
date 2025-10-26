import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'screens/gym_home.dart';
import 'screens/medical_home.dart';
import 'ai_medical_guidance/services/firebase_config .dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase for both projects using the existing config
  try {
    if (kIsWeb) {
      // Web initialization
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
    } else {
      // Mobile Firebase initialization with both projects
      await FirebaseConfig.initializeFirebase();
    }

    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    debugPrint('⚠️ Firebase initialization error: $e');
    // Continue anyway, Firebase might already be initialized
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FITGEN',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: const HomeChooser(),
      routes: {
        '/gym': (c) => const GymHome(),
        '/medical': (c) => const MedicalHome(),
      },
    );
  }
}

class HomeChooser extends StatelessWidget {
  const HomeChooser({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FITGEN')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/gym'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(220, 56),
                ),
                child: const Text('AI Gym Trainer'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/medical'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(220, 56),
                ),
                child: const Text('AI Medical Guidance'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
