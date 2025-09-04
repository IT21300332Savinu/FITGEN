import 'package:firebase_core/firebase_core.dart';

class FirebaseConfig {
  static Future<void> initializeFirebase() async {
    // Initialize your main app's Firebase (for user profiles, reports, etc.)
    await Firebase.initializeApp(
      name: 'HealthTracker', // Your main app
      options: const FirebaseOptions(
        // Your main app's Firebase configuration
        apiKey: 'your-main-app-api-key',
        appId: 'your-main-app-id',
        messagingSenderId: 'your-sender-id',
        projectId: 'your-main-project-id',
        // Add other required options
      ),
    );

    // Initialize IoT Firebase app (FitgenMedical)
    await Firebase.initializeApp(
      name: 'FitgenMedical', // IoT database
      options: const FirebaseOptions(
        // Your IoT Firebase configuration
        apiKey: 'fitgen-medical-api-key',
        appId: 'fitgen-medical-app-id',
        messagingSenderId: 'fitgen-medical-sender-id',
        projectId:
            'fitgen-medical-project-id', // This should be 'fitgenmedical' based on your screenshot
        // Add other required options
      ),
    );
  }

  // Helper method to get IoT Firebase instance
  static FirebaseApp get iotApp => Firebase.app('FitgenMedical');

  // Helper method to get main app Firebase instance
  static FirebaseApp get mainApp => Firebase.app('HealthTracker');
}
