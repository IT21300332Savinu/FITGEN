import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch User Health Data from Firestore
  Future<Map<String, dynamic>?> getUserHealthData(String userId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print("Error fetching user health data: $e");
      return null;
    }
  }

  // Save User Health Data to Firestore
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
      print("Error saving user health data: $e");
    }
  }
}
