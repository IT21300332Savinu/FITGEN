import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  // Sign up with email and password
  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String name,
    required int age,
    required double height,
    required double weight,
  }) async {
    try {
      // Create user with email and password
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create default health metrics and empty conditions list
      HealthMetrics defaultMetrics = HealthMetrics(
        restingHeartRate: 70,
        bloodPressureSystolic: 120,
        bloodPressureDiastolic: 80,
        respiratoryRate: 14,
        bloodGlucose: 5.0,
      );

      // Create user model
      UserModel user = UserModel(
        uid: result.user!.uid,
        email: email,
        name: name,
        age: age,
        height: height,
        weight: weight,
        conditions: [],
        healthMetrics: defaultMetrics,
      );

      // Save user data to Firestore
      await _firestore
          .collection('users')
          .doc(result.user!.uid)
          .set(user.toJson());

      notifyListeners();
      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Sign in with email and password
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get user data from Firestore
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(result.user!.uid).get();

      if (doc.exists) {
        UserModel user = UserModel.fromJson(doc.data() as Map<String, dynamic>);
        notifyListeners();
        return user;
      }

      return null;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  // Get current user data
  Future<UserModel?> getCurrentUserData() async {
    try {
      if (currentUser == null) return null;

      DocumentSnapshot doc =
          await _firestore.collection('users').doc(currentUser!.uid).get();

      if (doc.exists) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Update user data
  Future<void> updateUserData(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).update(user.toJson());
      notifyListeners();
    } catch (e) {
      print(e.toString());
    }
  }

  // Add medical condition
  Future<void> addMedicalCondition(
    String userId,
    MedicalCondition condition,
  ) async {
    try {
      // Get current user data
      UserModel? user = await getCurrentUserData();
      if (user == null) return;

      // Add condition to list
      List<MedicalCondition> updatedConditions = [
        ...user.conditions,
        condition,
      ];

      // Update user data
      UserModel updatedUser = user.copyWith(conditions: updatedConditions);
      await updateUserData(updatedUser);
    } catch (e) {
      print(e.toString());
    }
  }

  // Update health metrics
  Future<void> updateHealthMetrics(String userId, HealthMetrics metrics) async {
    try {
      // Get current user data
      UserModel? user = await getCurrentUserData();
      if (user == null) return;

      // Update user data
      UserModel updatedUser = user.copyWith(healthMetrics: metrics);
      await updateUserData(updatedUser);
    } catch (e) {
      print(e.toString());
    }
  }
}
