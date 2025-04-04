import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/health_data.dart';

class HealthService {
  final CollectionReference healthCollection = FirebaseFirestore.instance
      .collection('healthMetrics');

  Future<void> saveHealthData(HealthData data) async {
    await healthCollection.doc(data.userId).set(data.toMap());
  }

  Future<HealthData?> fetchHealthData(String userId) async {
    DocumentSnapshot doc = await healthCollection.doc(userId).get();
    if (doc.exists) {
      return HealthData.fromFirestore(doc);
    }
    return null;
  }
}
