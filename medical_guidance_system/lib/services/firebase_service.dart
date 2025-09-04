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

      // Check if already signed in
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

      // Update the profile with the correct user ID
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

      // Update the profile with the correct user ID
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

  // Report Management
  static Future<String?> uploadReport(File file, String fileName) async {
    try {
      String? userId = getCurrentUserId();
      if (userId == null) {
        print('No user ID available for report upload');
        return null;
      }

      print('Uploading report: $fileName for user: $userId');

      // Create a unique filename to avoid conflicts
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

  /// Save detailed report data with OCR results
  static Future<bool> saveReportData(Map<String, dynamic> reportData) async {
    try {
      String? userId = getCurrentUserId();
      if (userId == null) {
        print('No user ID available for saving report data');
        return false;
      }

      print('Saving report data for user: $userId');

      // Add user ID and timestamp
      reportData['userId'] = userId;
      reportData['createdAt'] = FieldValue.serverTimestamp();
      reportData['updatedAt'] = FieldValue.serverTimestamp();

      // Save to reports collection
      DocumentReference docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('reports')
          .add(reportData);

      // If extractedValues exist, also save to separate health_parameters collection for easy querying
      if (reportData['extractedValues'] != null &&
          (reportData['extractedValues'] as Map).isNotEmpty) {
        Map<String, dynamic> healthParams = Map<String, dynamic>.from(
          reportData['extractedValues'],
        );
        healthParams['reportId'] = docRef.id;
        healthParams['reportDate'] = reportData['uploadDate'];
        healthParams['userId'] = userId;
        healthParams['createdAt'] = FieldValue.serverTimestamp();

        await _firestore
            .collection('users')
            .doc(userId)
            .collection('health_parameters')
            .add(healthParams);

        print('✅ Health parameters saved to separate collection');
      }

      print('Report data saved successfully with ID: ${docRef.id}');
      return true;
    } catch (e) {
      print('Error saving report data: $e');
      return false;
    }
  }

  /// Get user reports with detailed OCR data
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

      List<Map<String, dynamic>> reports = snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();

      print('Found ${reports.length} reports');
      return reports;
    } catch (e) {
      print('Error fetching user reports: $e');
      return [];
    }
  }

  /// Get latest health parameters from OCR
  static Future<Map<String, dynamic>?> getLatestHealthParameters() async {
    try {
      String? userId = getCurrentUserId();
      if (userId == null) {
        print('No user ID available for fetching health parameters');
        return null;
      }

      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('health_parameters')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.data() as Map<String, dynamic>;
      }

      return null;
    } catch (e) {
      print('Error fetching health parameters: $e');
      return null;
    }
  }

  /// Get health parameter history
  static Future<List<Map<String, dynamic>>> getHealthParameterHistory({
    int limit = 10,
  }) async {
    try {
      String? userId = getCurrentUserId();
      if (userId == null) {
        print('No user ID available for fetching health parameter history');
        return [];
      }

      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('health_parameters')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    } catch (e) {
      print('Error fetching health parameter history: $e');
      return [];
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

      // Try to write a test document
      await _firestore.collection('test').doc('connection').set({
        'timestamp': FieldValue.serverTimestamp(),
      });

      print('Firebase connection test successful');
      return true;
    } catch (e) {
      print('Firebase connection test failed: $e');
      return false;
    }
  }
}
