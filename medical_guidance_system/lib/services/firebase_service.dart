import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_profile.dart';
import '../models/health_data.dart';
import 'dart:io';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // User Authentication
  static Future<User?> signInAnonymously() async {
    try {
      print('Attempting anonymous sign in...');

      if (_auth.currentUser != null) {
        print('User already signed in: ${_auth.currentUser!.uid}');
        return _auth.currentUser;
      }

      UserCredential result = await _auth.signInAnonymously();
      print('Anonymous sign in successful: ${result.user?.uid}');
      return result.user;
    } catch (e) {
      print('Error signing in anonymously: $e');
      return null;
    }
  }

  static String? getCurrentUserId() {
    final userId = _auth.currentUser?.uid;
    print('Current user ID: $userId');
    return userId;
  }

  // Profile Management
  static Future<bool> createUserProfile(UserProfile profile) async {
    try {
      String? userId = getCurrentUserId();
      if (userId == null) {
        print('No user ID available for profile creation');
        return false;
      }

      print('Creating profile for user: $userId');

      final updatedProfile = profile.copyWith(id: userId);

      await _firestore
          .collection('users')
          .doc(userId)
          .set(updatedProfile.toMap());

      print('Profile created successfully');
      return true;
    } catch (e) {
      print('Error creating user profile: $e');
      return false;
    }
  }

  static Future<bool> updateUserProfile(UserProfile profile) async {
    try {
      String? userId = getCurrentUserId();
      if (userId == null) {
        print('No user ID available for profile update');
        return false;
      }

      print('Updating profile for user: $userId');

      final updatedProfile = profile.copyWith(id: userId);

      await _firestore
          .collection('users')
          .doc(userId)
          .set(updatedProfile.toMap(), SetOptions(merge: true));

      print('Profile updated successfully');
      return true;
    } catch (e) {
      print('Error updating user profile: $e');
      return false;
    }
  }

  static Future<UserProfile?> getUserProfile() async {
    try {
      String? userId = getCurrentUserId();
      if (userId == null) {
        print('No user ID available for fetching profile');
        return null;
      }

      print('Fetching profile for user: $userId');

      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists && doc.data() != null) {
        print('Profile found for user');
        return UserProfile.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        print('No profile found for user');
        return null;
      }
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  // Report Management - Fixed
  static Future<String?> uploadReport(File file, String fileName) async {
    try {
      String? userId = getCurrentUserId();
      if (userId == null) {
        print('No user ID available for report upload');
        return null;
      }

      print('Uploading report: $fileName for user: $userId');

      String uniqueFileName =
          '${DateTime.now().millisecondsSinceEpoch}_$fileName';

      Reference ref = _storage.ref().child('reports/$userId/$uniqueFileName');
      UploadTask uploadTask = ref.putFile(file);

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();

      print('Report uploaded successfully: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('Error uploading report: $e');
      return null;
    }
  }

  static Future<bool> saveReportData(Map<String, dynamic> reportData) async {
    try {
      String? userId = getCurrentUserId();
      if (userId == null) {
        print('No user ID available for saving report data');
        return false;
      }

      print('Saving report data for user: $userId');

      // Add user ID to report data
      reportData['userId'] = userId;
      reportData['createdAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('reports')
          .add(reportData);

      print('Report data saved successfully');
      return true;
    } catch (e) {
      print('Error saving report data: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> getUserReports() async {
    try {
      String? userId = getCurrentUserId();
      if (userId == null) {
        print('No user ID available for fetching reports');
        return [];
      }

      print('Fetching reports for user: $userId');

      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('reports')
          .orderBy('uploadDate', descending: true)
          .get();

      List<Map<String, dynamic>> reports = [];

      for (var doc in snapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        reports.add(data);
      }

      print('Found ${reports.length} reports');
      return reports;
    } catch (e) {
      print('Error fetching user reports: $e');
      // Try alternative field name if uploadDate doesn't exist
      try {
        QuerySnapshot snapshot = await _firestore
            .collection('users')
            .doc(getCurrentUserId()!)
            .collection('reports')
            .orderBy('createdAt', descending: true)
            .get();

        List<Map<String, dynamic>> reports = [];

        for (var doc in snapshot.docs) {
          var data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          reports.add(data);
        }

        print('Found ${reports.length} reports (using createdAt)');
        return reports;
      } catch (e2) {
        print('Error with alternative query: $e2');
        return [];
      }
    }
  }

  // Health Data Management
  static Future<bool> saveHealthData(HealthData healthData) async {
    try {
      String? userId = getCurrentUserId();
      if (userId == null) {
        print('No user ID available for saving health data');
        return false;
      }

      print('Saving health data for user: $userId');

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('healthData')
          .add(healthData.toMap());

      print('Health data saved successfully');
      return true;
    } catch (e) {
      print('Error saving health data: $e');
      return false;
    }
  }

  static Future<List<HealthData>> getLatestHealthData({int limit = 10}) async {
    try {
      String? userId = getCurrentUserId();
      if (userId == null) {
        print('No user ID available for fetching health data');
        return [];
      }

      print('Fetching latest health data for user: $userId');

      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('healthData')
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      List<HealthData> healthDataList = snapshot.docs
          .map((doc) => HealthData.fromMap(doc.data() as Map<String, dynamic>))
          .toList();

      print('Found ${healthDataList.length} health data entries');
      return healthDataList;
    } catch (e) {
      print('Error fetching health data: $e');
      return [];
    }
  }

  // Real-time health data stream
  static Stream<List<HealthData>> getHealthDataStream() {
    String? userId = getCurrentUserId();
    if (userId == null) {
      print('No user ID available for health data stream');
      return Stream.value([]);
    }

    print('Setting up health data stream for user: $userId');

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('healthData')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => HealthData.fromMap(doc.data()))
              .toList(),
        );
  }

  // Test Firebase connection
  static Future<bool> testConnection() async {
    try {
      print('Testing Firebase connection...');

      await _firestore.collection('test').doc('connection').set({
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'connected',
      });

      print('Firebase connection test successful');
      return true;
    } catch (e) {
      print('Firebase connection test failed: $e');
      return false;
    }
  }

  // Debug method to check collections
  static Future<void> debugCollections() async {
    try {
      String? userId = getCurrentUserId();
      if (userId == null) {
        print('No user ID for debugging');
        return;
      }

      print('=== DEBUGGING FIREBASE COLLECTIONS ===');

      // Check user profile
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      print('User profile exists: ${userDoc.exists}');
      if (userDoc.exists) {
        print('User data: ${userDoc.data()}');
      }

      // Check reports subcollection
      QuerySnapshot reportsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('reports')
          .get();

      print('Reports found: ${reportsSnapshot.docs.length}');
      for (var doc in reportsSnapshot.docs) {
        print('Report: ${doc.id} - ${doc.data()}');
      }

      // Check FitgenMedical IoT collection
      QuerySnapshot iotSnapshot = await _firestore
          .collection('FitgenMedical')
          .limit(5)
          .get();

      print('IoT data entries: ${iotSnapshot.docs.length}');
      for (var doc in iotSnapshot.docs) {
        print('IoT: ${doc.id} - ${doc.data()}');
      }
    } catch (e) {
      print('Debug error: $e');
    }
  }
}
