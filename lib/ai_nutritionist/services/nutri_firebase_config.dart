import 'package:firebase_core/firebase_core.dart';

class NutriFirebaseConfig {
  static Future<void> initializeFirebase() async {
    //  Check if already initialized
    try {
      Firebase.app('AiNutritionist');
      // Already initialized — no need to do it again
      return;
    } catch (e) {
      // Not initialized yet — proceed
    }

    await Firebase.initializeApp(
      name: 'AiNutritionist',
      options: const FirebaseOptions(
        apiKey: "AIzaSyCwN-kude9aGOxi89OEHKMcdlS-P0JMWfQ",
        appId: "1:421282137669:web:e035ad7246c3923252c52c",
        messagingSenderId: "421282137669",
        projectId: "ainutritionist-ca72f",
        storageBucket: "ainutritionist-ca72f.firebasestorage.app",
        authDomain: "ainutritionist-ca72f.firebaseapp.com",
        databaseURL:
        "https://ainutritionist-ca72f-default-rtdb.asia-southeast1.firebasedatabase.app",
        measurementId: "G-N6HTF73B3J",
      ),
    );
  }

  ///  Getter for reuse
  static FirebaseApp get nutritionApp => Firebase.app('AiNutritionist');
}
