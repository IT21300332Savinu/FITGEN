// file: lib/services/firebase_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_profile.dart';
import '../models/workout_session.dart';
import '../models/achievement.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //final FirebaseStorage _storage = FirebaseStorage.instance;

  // Authentication methods
  Future<UserCredential> signUp(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error during sign up: $e');
      rethrow;
    }
  }

  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error during sign in: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    return await _auth.signOut();
  }

  // User profile methods
  Future<void> createUserProfile(UserProfile profile) async {
    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .set(profile.toMap());
    } catch (e) {
      print('Error creating user profile: $e');
      rethrow;
    }
  }

  Future<UserProfile?> getUserProfile() async {
    try {
      DocumentSnapshot doc =
          await _firestore
              .collection('users')
              .doc(_auth.currentUser?.uid)
              .get();

      if (doc.exists) {
        return UserProfile.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');

      // Instead of rethrowing, handle the offline case
      if (e.toString().contains('offline')) {
        // Return a default profile for offline mode
        return UserProfile(
          userId: _auth.currentUser?.uid ?? 'offline-user',
          name: 'Offline User',
          age: 30,
          weight: 70.0,
          height: 175.0,
          fitnessGoal: 'muscle_gain',
          // Other fields will use their default values as defined in the class
        );
      }

      // For other errors, you can still rethrow or return null
      return null;
    }
  }

  // Workout session methods
  Future<void> saveWorkoutSession(WorkoutSession session) async {
    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .collection('workoutSessions')
          .add(session.toMap());

      // Update user stats after workout
      await updateUserStats(session);
    } catch (e) {
      print('Error saving workout session: $e');
      rethrow;
    }
  }

  Future<List<WorkoutSession>> getWorkoutHistory() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore
              .collection('users')
              .doc(_auth.currentUser?.uid)
              .collection('workoutSessions')
              .orderBy('timestamp', descending: true)
              .get();

      return querySnapshot.docs
          .map(
            (doc) => WorkoutSession.fromMap(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      print('Error getting workout history: $e');
      rethrow;
    }
  }

  // Gamification methods
  Future<void> updateUserStats(WorkoutSession session) async {
    try {
      // Get the current user stats
      DocumentSnapshot userDoc =
          await _firestore
              .collection('users')
              .doc(_auth.currentUser?.uid)
              .get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        // Update total workouts, calories, etc.
        int totalWorkouts = (userData['totalWorkouts'] ?? 0) + 1;
        int totalCalories =
            (userData['totalCaloriesBurned'] ?? 0) + session.caloriesBurned;
        int totalMinutes =
            (userData['totalWorkoutMinutes'] ?? 0) + session.durationMinutes;
        int experiencePoints =
            (userData['experiencePoints'] ?? 0) + calculateXP(session);

        // Update the user document
        await _firestore
            .collection('users')
            .doc(_auth.currentUser?.uid)
            .update({
              'totalWorkouts': totalWorkouts,
              'totalCaloriesBurned': totalCalories,
              'totalWorkoutMinutes': totalMinutes,
              'experiencePoints': experiencePoints,
              'lastWorkout': FieldValue.serverTimestamp(),
            });

        // Check for new achievements
        await checkAndUpdateAchievements(
          totalWorkouts,
          totalCalories,
          totalMinutes,
          experiencePoints,
        );
      }
    } catch (e) {
      print('Error updating user stats: $e');
      rethrow;
    }
  }

  int calculateXP(WorkoutSession session) {
    // Base XP from duration
    int baseXP = session.durationMinutes * 5;

    // Bonus XP from form quality
    int formBonus = (session.averageFormScore / 20).round();

    // Bonus XP from calories
    int calorieBonus = (session.caloriesBurned / 10).round();

    return baseXP + formBonus + calorieBonus;
  }

  Future<void> checkAndUpdateAchievements(
    int totalWorkouts,
    int totalCalories,
    int totalMinutes,
    int experiencePoints,
  ) async {
    try {
      // Define achievement thresholds
      List<Achievement> possibleAchievements = [
        Achievement(
          id: 'workout_5',
          title: 'Getting Started',
          description: 'Complete 5 workouts',
          iconUrl: 'assets/icons/workout_5.png',
          isUnlocked: totalWorkouts >= 5,
        ),
        Achievement(
          id: 'workout_20',
          title: 'Consistent Athlete',
          description: 'Complete 20 workouts',
          iconUrl: 'assets/icons/workout_20.png',
          isUnlocked: totalWorkouts >= 20,
        ),
        Achievement(
          id: 'calories_1000',
          title: 'Calorie Crusher',
          description: 'Burn 1000 total calories',
          iconUrl: 'assets/icons/calories_1000.png',
          isUnlocked: totalCalories >= 1000,
        ),
        Achievement(
          id: 'time_300',
          title: 'Dedicated',
          description: 'Spend 300 minutes working out',
          iconUrl: 'assets/icons/time_300.png',
          isUnlocked: totalMinutes >= 300,
        ),
        Achievement(
          id: 'xp_1000',
          title: 'Fitness Explorer',
          description: 'Earn 1000 XP',
          iconUrl: 'assets/icons/xp_1000.png',
          isUnlocked: experiencePoints >= 1000,
        ),
      ];

      // Get current user achievements
      QuerySnapshot achievementSnapshot =
          await _firestore
              .collection('users')
              .doc(_auth.currentUser?.uid)
              .collection('achievements')
              .get();

      // Current achievement IDs
      List<String> currentAchievementIds =
          achievementSnapshot.docs.map((doc) => doc.id).toList();

      // Check for new achievements
      for (var achievement in possibleAchievements) {
        if (achievement.isUnlocked &&
            !currentAchievementIds.contains(achievement.id)) {
          // Add new achievement
          await _firestore
              .collection('users')
              .doc(_auth.currentUser?.uid)
              .collection('achievements')
              .doc(achievement.id)
              .set({
                'title': achievement.title,
                'description': achievement.description,
                'iconUrl': achievement.iconUrl,
                'unlockedAt': FieldValue.serverTimestamp(),
              });

          // Add notification for new achievement
          await _firestore
              .collection('users')
              .doc(_auth.currentUser?.uid)
              .collection('notifications')
              .add({
                'title': 'New Achievement Unlocked!',
                'message':
                    'You\'ve earned the "${achievement.title}" achievement!',
                'timestamp': FieldValue.serverTimestamp(),
                'isRead': false,
                'type': 'achievement',
              });
        }
      }
    } catch (e) {
      print('Error checking achievements: $e');
      rethrow;
    }
  }

  // Storage methods for workout videos/images
  /*
  Future<String> uploadFormVideo(String filePath, String exerciseName) async {
    try {
      String fileName =
          '${_auth.currentUser?.uid}_${DateTime.now().millisecondsSinceEpoch}_$exerciseName.mp4';
      Reference ref = _storage.ref().child('workout_videos/$fileName');

      UploadTask uploadTask = ref.putFile(File(filePath));
      TaskSnapshot taskSnapshot = await uploadTask;

      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading video: $e');
      rethrow;
    }
  }
  */

  // Health data integration
  Future<void> saveHealthData(Map<String, dynamic> healthData) async {
    try {
      await _firestore
          .collection('users')
          .doc(_auth.currentUser?.uid)
          .collection('healthData')
          .add({...healthData, 'timestamp': FieldValue.serverTimestamp()});
    } catch (e) {
      print('Error saving health data: $e');
      rethrow;
    }
  }
}
