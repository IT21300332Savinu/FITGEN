// lib/features/gamification/services/social_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/gamification_models.dart';
import 'user_session_service.dart';

class SocialService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Get user's social feed with real Firebase data
  static Future<List<SocialPost>> getFeed(String userId) async {
    try {
      print('Fetching feed for user: $userId');
      
      // First try to get posts without ordering by timestamp to avoid Timestamp serialization issues
      QuerySnapshot querySnapshot;
      try {
        querySnapshot = await _firestore
            .collection('social_posts')
            .orderBy('timestamp', descending: true)
            .limit(20)
            .get();
      } catch (e) {
        print('Error with timestamp ordering, trying without ordering: $e');
        // Fallback: get posts without timestamp ordering
        querySnapshot = await _firestore
            .collection('social_posts')
            .limit(20)
            .get();
      }

      print('Found ${querySnapshot.docs.length} documents in social_posts collection');

      final posts = <SocialPost>[];
      for (final doc in querySnapshot.docs) {
        try {
          print('Processing document: ${doc.id}');
          final data = doc.data() as Map<String, dynamic>;
          final post = SocialPost.fromJson({
            'id': doc.id,
            ...data,
          });
          posts.add(post);
          print('Successfully parsed post: ${post.id} by ${post.username}');
        } catch (e) {
          print('Error parsing document ${doc.id}: $e');
          print('Document data: ${doc.data()}');
          // Continue with other posts even if one fails
        }
      }

      print('Successfully parsed ${posts.length} posts out of ${querySnapshot.docs.length} documents');

      // Sort posts by timestamp after parsing (in case we couldn't order in Firestore)
      posts.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // If no posts exist, create some sample posts for demo
      if (posts.isEmpty) {
        print('No posts found, creating sample posts');
        return await _createSamplePosts();
      }

      return posts;
    } catch (e) {
      print('Error fetching feed: $e');
      print('Stack trace: ${StackTrace.current}');
      // Return sample posts as fallback
      return await _createSamplePosts();
    }
  }

  /// Create sample posts for demonstration with real user data
  static Future<List<SocialPost>> _createSamplePosts() async {
    // Get current user's name for more personalized content
    final currentUserName = await UserSessionService.getCurrentUserName() ?? 'You';
    final currentUserId = await UserSessionService.getCurrentUserId() ?? 'current_user';
    
    return [
      // Add a post from the current user
      SocialPost(
        id: 'post_current',
        userId: currentUserId,
        username: currentUserName,
        userAvatar: null,
        content: 'Just started my fitness journey with FITGEN! 🚀 Ready to get stronger!',
        postType: PostType.general,
        exerciseType: null,
        workoutData: null,
        achievementIds: null,
        imageUrl: null,
        createdAt: DateTime.now().subtract(Duration(minutes: 30)),
        likes: ['user1', 'user2'],
        comments: [
          Comment(
            id: 'comment_welcome',
            userId: 'user1',
            username: 'FitnessKing',
            content: 'Welcome to the community! 🎉',
            createdAt: DateTime.now().subtract(Duration(minutes: 15)),
          ),
        ],
        isPublic: true,
      ),
      SocialPost(
        id: 'post1',
        userId: 'user1',
        username: 'FitnessKing',
        userAvatar: null,
        content: 'Just crushed a 30-minute workout! 💪 Feeling stronger every day!',
        postType: PostType.workout,
        exerciseType: 'bicepCurl',
        workoutData: WorkoutSession(
          id: 'workout1',
          userId: 'user1',
          exerciseType: 'bicepCurl',
          repsCompleted: 45,
          averageFormScore: 92.5,
          xpEarned: 380,
          duration: Duration(minutes: 30),
          startTime: DateTime.now().subtract(Duration(hours: 2)),
          endTime: DateTime.now().subtract(Duration(hours: 1, minutes: 30)),
          achievementsUnlocked: [],
        ).toJson(),
        achievementIds: null,
        imageUrl: null,
        createdAt: DateTime.now().subtract(Duration(hours: 2)),
        likes: ['user2', 'user3', 'user4'],
        comments: [
          Comment(
            id: 'comment1',
            userId: 'user2',
            username: 'GymQueen',
            content: 'Amazing work! 🔥',
            createdAt: DateTime.now().subtract(Duration(hours: 1)),
          ),
        ],
        isPublic: true,
      ),
      SocialPost(
        id: 'post2',
        userId: 'user2',
        username: 'GymQueen',
        userAvatar: null,
        content: 'Unlocked a new achievement! Week Warrior badge earned! 🏆',
        postType: PostType.achievement,
        exerciseType: null,
        workoutData: null,
        achievementIds: ['workout_streak_7'],
        imageUrl: null,
        createdAt: DateTime.now().subtract(Duration(hours: 4)),
        likes: ['user1', 'user3', 'user5'],
        comments: [
          Comment(
            id: 'comment2',
            userId: 'user1',
            username: 'FitnessKing',
            content: 'Congrats! Keep up the streak!',
            createdAt: DateTime.now().subtract(Duration(hours: 3)),
          ),
          Comment(
            id: 'comment3',
            userId: 'user3',
            username: 'MuscleBuilder',
            content: 'Inspiring! 💪',
            createdAt: DateTime.now().subtract(Duration(hours: 2)),
          ),
        ],
        isPublic: true,
      ),
      SocialPost(
        id: 'post3',
        userId: 'user3',
        username: 'MuscleBuilder',
        userAvatar: null,
        content: 'Perfect form day! Hit 95% form score on squats 🎯',
        postType: PostType.workout,
        exerciseType: 'squat',
        workoutData: WorkoutSession(
          id: 'workout2',
          userId: 'user3',
          exerciseType: 'squat',
          repsCompleted: 32,
          averageFormScore: 95.2,
          xpEarned: 420,
          duration: Duration(minutes: 25),
          startTime: DateTime.now().subtract(Duration(hours: 6)),
          endTime: DateTime.now().subtract(Duration(hours: 5, minutes: 35)),
          achievementsUnlocked: ['perfect_form_workout'],
        ).toJson(),
        achievementIds: null,
        imageUrl: null,
        createdAt: DateTime.now().subtract(Duration(hours: 6)),
        likes: ['user1', 'user2'],
        comments: [],
        isPublic: true,
      ),
      SocialPost(
        id: 'post4',
        userId: 'user4',
        username: 'PowerLifter',
        userAvatar: null,
        content: 'Level up! Just reached Level 10! 🚀 The grind never stops!',
        postType: PostType.achievement,
        exerciseType: null,
        workoutData: null,
        achievementIds: ['level_10'],
        imageUrl: null,
        createdAt: DateTime.now().subtract(Duration(hours: 8)),
        likes: ['user1', 'user2', 'user3', 'user5', 'user6'],
        comments: [
          Comment(
            id: 'comment4',
            userId: 'user1',
            username: 'FitnessKing',
            content: 'Beast mode! 🔥',
            createdAt: DateTime.now().subtract(Duration(hours: 7)),
          ),
        ],
        isPublic: true,
      ),
      SocialPost(
        id: 'post5',
        userId: 'user5',
        username: 'CardioMaster',
        userAvatar: null,
        content: 'Morning workout complete! Push-ups hitting different today 💯',
        postType: PostType.workout,
        exerciseType: 'pushup',
        workoutData: WorkoutSession(
          id: 'workout3',
          userId: 'user5',
          exerciseType: 'pushup',
          repsCompleted: 50,
          averageFormScore: 88.7,
          xpEarned: 320,
          duration: Duration(minutes: 20),
          startTime: DateTime.now().subtract(Duration(hours: 10)),
          endTime: DateTime.now().subtract(Duration(hours: 9, minutes: 40)),
          achievementsUnlocked: [],
        ).toJson(),
        achievementIds: null,
        imageUrl: null,
        createdAt: DateTime.now().subtract(Duration(hours: 10)),
        likes: ['user2', 'user3'],
        comments: [],
        isPublic: true,
      ),
      SocialPost(
        id: 'post6',
        userId: 'user6',
        username: 'FitnessNewbie',
        userAvatar: null,
        content: 'First time hitting 15 reps! Small victories matter! 🎉',
        postType: PostType.general,
        exerciseType: 'bicepCurl',
        workoutData: null,
        achievementIds: null,
        imageUrl: null,
        createdAt: DateTime.now().subtract(Duration(hours: 12)),
        likes: ['user1', 'user2', 'user3', 'user4', 'user5'],
        comments: [
          Comment(
            id: 'comment5',
            userId: 'user1',
            username: 'FitnessKing',
            content: 'Every rep counts! Keep going! 💪',
            createdAt: DateTime.now().subtract(Duration(hours: 11)),
          ),
        ],
        isPublic: true,
      ),
    ];
  }

  /// Get recent workouts for feed
  static Future<List<SocialPost>> getRecentWorkouts(int offset) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    return [
      SocialPost(
        id: 'workout_post_${offset + 1}',
        userId: 'user6',
        username: 'FitnessNewbie',
        userAvatar: null,
        content: 'Just finished a quick bicep session! Form getting better! 💪',
        postType: PostType.workout,
        exerciseType: 'bicepCurl',
        workoutData: WorkoutSession(
          id: 'workout${offset + 1}',
          userId: 'user6',
          exerciseType: 'bicepCurl',
          repsCompleted: 15,
          averageFormScore: 78.5,
          xpEarned: 150,
          duration: Duration(minutes: 15),
          startTime: DateTime.now().subtract(Duration(hours: 14 + offset)),
          endTime: DateTime.now().subtract(Duration(hours: 13 + offset, minutes: 45)),
          achievementsUnlocked: [],
        ).toJson(),
        achievementIds: null,
        imageUrl: null,
        createdAt: DateTime.now().subtract(Duration(hours: 14 + offset)),
        likes: ['user1'],
        comments: [],
        isPublic: true,
      ),
    ];
  }

  /// Create a social post for workout completion
  static Future<SocialPost> createWorkoutPost({
    required String userId,
    required String username,
    required String content,
    required WorkoutSession? workoutData,
    String? exerciseType,
    List<String>? achievementIds,
  }) async {
    try {
      final post = SocialPost(
        id: '', // Will be set by Firebase
        userId: userId,
        username: username,
        userAvatar: null,
        content: content,
        postType: workoutData != null ? PostType.workout : PostType.general,
        exerciseType: exerciseType,
        workoutData: workoutData?.toJson(),
        achievementIds: achievementIds,
        imageUrl: null,
        timestamp: DateTime.now(),
        likes: [],
        comments: [],
        isPublic: true,
      );

      // Save to Firebase
      final docRef = await _firestore
          .collection('social_posts')
          .add(post.toJson());

      // Return post with Firebase-generated ID
      return SocialPost(
        id: docRef.id,
        userId: post.userId,
        username: post.username,
        userAvatar: post.userAvatar,
        content: post.content,
        postType: post.postType,
        exerciseType: post.exerciseType,
        workoutData: post.workoutData,
        achievementIds: post.achievementIds,
        imageUrl: post.imageUrl,
        timestamp: post.timestamp,
        likes: post.likes,
        comments: post.comments,
        isPublic: post.isPublic,
      );
    } catch (e) {
      print('Error creating workout post: $e');
      rethrow;
    }
  }

  /// Create a new social post
  static Future<String> createPost({
    required String userId,
    required String username,
    required String content,
    String? imageUrl,
    PostType postType = PostType.general,
    String? exerciseType,
    Map<String, dynamic>? workoutData,
    List<String>? achievementIds,
  }) async {
    try {
      final postId = 'post_${DateTime.now().millisecondsSinceEpoch}';
      
      print('Creating post with ID: $postId');
      print('User: $username ($userId)');
      print('Content: $content');
      
      final postData = {
        'id': postId,
        'userId': userId,
        'username': username,
        'userAvatar': null,
        'content': content,
        'postType': postType.toString().split('.').last,
        'exerciseType': exerciseType,
        'workoutData': workoutData,
        'achievementIds': achievementIds,
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'likes': <String>[],
        'comments': <Map<String, dynamic>>[],
        'isPublic': true,
      };

      print('Saving post data: $postData');

      await _firestore
          .collection('social_posts')
          .doc(postId)
          .set(postData);

      print('Post saved successfully with ID: $postId');
      return postId;
    } catch (e) {
      print('Error creating post: $e');
      rethrow;
    }
  }

  /// Like/unlike a post
  static Future<void> toggleLike(String postId, String userId) async {
    try {
      if (postId.isEmpty) {
        print('Error: Post ID cannot be empty');
        return;
      }
      
      final docRef = _firestore.collection('social_posts').doc(postId);
      
      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);
        if (!doc.exists) return;

        final data = doc.data()!;
        final likes = List<String>.from(data['likes'] ?? []);

        if (likes.contains(userId)) {
          likes.remove(userId);
        } else {
          likes.add(userId);
        }

        transaction.update(docRef, {'likes': likes});
      });
    } catch (e) {
      print('Error toggling like: $e');
    }
  }

  /// Add a comment to a post
  static Future<Comment> addComment({
    required String postId,
    required String userId,
    required String username,
    required String content,
  }) async {
    try {
      final comment = Comment(
        id: '', // Will be generated
        userId: userId,
        username: username,
        content: content,
        createdAt: DateTime.now(),
      );

      final docRef = _firestore.collection('social_posts').doc(postId);
      
      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(docRef);
        if (!doc.exists) return;

        final data = doc.data()!;
        final comments = List<Map<String, dynamic>>.from(data['comments'] ?? []);
        
        final commentData = comment.toJson();
        commentData['id'] = 'comment_${DateTime.now().millisecondsSinceEpoch}';
        comments.add(commentData);

        transaction.update(docRef, {'comments': comments});
      });

      return Comment(
        id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
        userId: comment.userId,
        username: comment.username,
        content: comment.content,
        createdAt: comment.createdAt,
      );
    } catch (e) {
      print('Error adding comment: $e');
      rethrow;
    }
  }

  /// Share workout achievement
  static Future<void> shareWorkoutAchievement({
    required String userId,
    required String username,
    required WorkoutSession workoutData,
    required List<String> unlockedAchievements,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // In real implementation, this would create a new social post
  }

  /// Get user activity summary for sharing
  static Future<Map<String, dynamic>> getUserActivitySummary(String userId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    return {
      'totalWorkouts': 25,
      'totalXP': 3420,
      'currentLevel': 8,
      'weeklyWorkouts': 5,
      'favoriteExercise': 'bicepCurl',
      'bestStreak': 7,
    };
  }
}