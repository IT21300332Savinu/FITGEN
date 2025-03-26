import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save user health data
  Future<void> saveUserHealthData(
    String userId,
    Map<String, dynamic> healthData,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .set(healthData, SetOptions(merge: true));
    } catch (e) {
      throw Exception("Error saving data: $e");
    }
  }

  // Get user health data
  Future<Map<String, dynamic>?> getUserHealthData(String userId) async {
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('users').doc(userId).get();
      return snapshot.exists ? snapshot.data() as Map<String, dynamic> : null;
    } catch (e) {
      throw Exception("Error fetching data: $e");
    }
  }
}
