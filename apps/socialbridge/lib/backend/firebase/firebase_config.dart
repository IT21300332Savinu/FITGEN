import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

Future initFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyB5GFy_H4OUQ3kEauWbvPS07Etrh4oLK9w",
            authDomain: "fitgen-socialbridge-ihkwov.firebaseapp.com",
            projectId: "fitgen-socialbridge-ihkwov",
            storageBucket: "fitgen-socialbridge-ihkwov.firebasestorage.app",
            messagingSenderId: "358273804497",
            appId: "1:358273804497:web:74a6d2a9475541eec2bdf0"));
  } else {
    await Firebase.initializeApp();
  }
}
