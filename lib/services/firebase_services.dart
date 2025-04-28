import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchWorkouts() async {
    var snapshot = await _db.collection('workouts').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}
