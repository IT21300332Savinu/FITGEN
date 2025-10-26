import 'package:firebase_core/firebase_core.dart';

class FirebaseConfig {
  static Future<void> initializeFirebase() async {
    // Initialize your main app's Firebase (for user profiles, reports, etc.)
    await Firebase.initializeApp(
      name: 'fitgen', // Your main app
      options: const FirebaseOptions(
        // Your main app's Firebase configuration
        apiKey: 'AIzaSyC4m5cSrqo4a4noB3NWyMUDsJfEerZ3WpI',
        appId: '1:28582013230:android:38837813f1fa72da8af2bf',
        messagingSenderId: '28582013230',
        projectId: 'fitgen-8df00',
        // Add other required options
      ),
    );

    // Initialize IoT Firebase app (FitgenMedical)
    await Firebase.initializeApp(
      name: 'FitgenMedical', // IoT database
      options: const FirebaseOptions(
        // Your IoT Firebase configuration
        apiKey: 'AIzaSyCM1GSBbBwBBOa-mxHNKNL6teLiPkmHTyk',
        appId: '1:872949407728:android:70f26d18948b36e9228735',
        messagingSenderId: '872949407728',
        projectId:
            'fitgenmedical', // This should be 'fitgenmedical' based on your screenshot
        // Add other required options
      ),
    );
  }

  // Helper method to get IoT Firebase instance
  static FirebaseApp get iotApp => Firebase.app('FitgenMedical');

  // Helper method to get main app Firebase instance
  static FirebaseApp get mainApp => Firebase.app('fitgen');
}
