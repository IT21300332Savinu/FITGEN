import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class HealthProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  Map<String, dynamic>? userHealthData;

  Future<void> fetchUserHealthData(String userId) async {
    userHealthData = await _firebaseService.getUserHealthData(userId);
    notifyListeners();
  }

  Future<void> updateUserHealthData(
    String userId,
    Map<String, dynamic> healthData,
  ) async {
    await _firebaseService.saveUserHealthData(userId, healthData);
    await fetchUserHealthData(userId);
  }
}
