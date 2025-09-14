// lib/features/gamification/screens/social_feed_screen.dart

import 'package:flutter/material.dart';
// TODO: Temporarily commented out until package issues resolved
// import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/gamification_models.dart';
import '../services/social_service.dart';
import '../services/user_session_service.dart';
import '../widgets/workout_post_widget.dart';
import '../widgets/achievement_post_widget.dart';

class SocialFeedScreen extends StatefulWidget {
  const SocialFeedScreen({Key? key}) : super(key: key);

  @override
  State<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends State<SocialFeedScreen> {
  final ScrollController _scrollController = ScrollController();
  List<SocialPost> _posts = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String _currentUserId = ""; // Will be loaded from session
  String _currentUserName = ""; // Will be loaded from session
  // TODO: Temporarily removed photo upload functionality
  // File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _initializeUser();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _initializeUser() async {
    final userId = await UserSessionService.getCurrentUserId();
    final userName = await UserSessionService.getCurrentUserName();
    setState(() {
      _currentUserId = userId ?? "guest_user";
      _currentUserName = userName ?? "You";
    });
    _loadFeed();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadFeed() async {
    print('Loading feed for user: $_currentUserId');
    setState(() => _isLoading = true);
    
    try {
      final posts = await SocialService.getFeed(_currentUserId);
      print('Received ${posts.length} posts from SocialService');
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
      print('Feed updated with ${_posts.length} posts');
    } catch (e) {
      print('Error loading feed: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoadingMore) return;
    
    setState(() => _isLoadingMore = true);
    
    try {
      final morePosts = await SocialService.getRecentWorkouts(_posts.length);
      setState(() {
        _posts.addAll(morePosts);
        _isLoadingMore = false;
      });
    } catch (e) {
      print('Error loading more posts: $e');
      setState(() => _isLoadingMore = false);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _loadMorePosts();
    }
  }

  Future<void> _likePost(String postId) async {
    try {
      await SocialService.toggleLike(postId, _currentUserId);
      setState(() {
        final postIndex = _posts.indexWhere((post) => post.id == postId);
        if (postIndex != -1) {
          final post = _posts[postIndex];
          final updatedLikes = List<String>.from(post.likes);
          
          if (updatedLikes.contains(_currentUserId)) {
            updatedLikes.remove(_currentUserId);
          } else {
            updatedLikes.add(_currentUserId);
          }
          
          _posts[postIndex] = SocialPost(
            id: post.id,
            userId: post.userId,
            username: post.username,
            userAvatar: post.userAvatar,
            content: post.content,
            postType: post.postType,
            exerciseType: post.exerciseType,
            workoutData: post.workoutData,
            achievementIds: post.achievementIds,
            imageUrl: post.imageUrl,
            createdAt: post.createdAt,
            likes: updatedLikes,
            comments: post.comments,
            isPublic: post.isPublic,
          );
        }
      });
    } catch (e) {
      print('Error liking post: $e');
    }
  }

  Future<void> _addComment(String postId, String comment) async {
    try {
      await SocialService.addComment(
        postId: postId,
        userId: _currentUserId,
        username: _currentUserName.isNotEmpty ? _currentUserName : "You",
        content: comment,
      );
      
      setState(() {
        final postIndex = _posts.indexWhere((post) => post.id == postId);
        if (postIndex != -1) {
          final post = _posts[postIndex];
          final newComment = Comment(
            id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
            userId: _currentUserId,
            username: _currentUserName.isNotEmpty ? _currentUserName : "You",
            content: comment,
            createdAt: DateTime.now(),
          );
          
          _posts[postIndex] = SocialPost(
            id: post.id,
            userId: post.userId,
            username: post.username,
            userAvatar: post.userAvatar,
            content: post.content,
            postType: post.postType,
            exerciseType: post.exerciseType,
            workoutData: post.workoutData,
            achievementIds: post.achievementIds,
            imageUrl: post.imageUrl,
            createdAt: post.createdAt,
            likes: post.likes,
            comments: [...post.comments, newComment],
            isPublic: post.isPublic,
          );
        }
      });
    } catch (e) {
      print('Error adding comment: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Feed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _showCreatePostDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadFeed,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(8),
                itemCount: _posts.length + (_isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _posts.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final post = _posts[index];
                  return _buildPostCard(post);
                },
              ),
            ),
    );
  }

  Widget _buildPostCard(SocialPost post) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: IntrinsicHeight(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Post header
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundImage: post.userAvatar != null 
                    ? NetworkImage(post.userAvatar!)
                    : null,
                child: post.userAvatar == null
                    ? Text(post.username.substring(0, 1).toUpperCase())
                    : null,
              ),
              title: Text(
                post.username,
                style: const TextStyle(fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                _formatTimeAgo(post.createdAt),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: post.userId == _currentUserId
                  ? PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete Post'),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'delete') {
                          _deletePost(post.id);
                        }
                      },
                    )
                  : null,
            ),
            
            // Post content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                post.content,
                maxLines: 10,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            // Workout or achievement data
            if (post.workoutData != null)
              Flexible(
                child: WorkoutPostWidget(workoutData: WorkoutSession.fromJson(post.workoutData!)),
              )
            else if (post.achievementIds != null && post.achievementIds!.isNotEmpty)
              Flexible(
                child: AchievementPostWidget(achievementIds: post.achievementIds!),
              ),
            
            // Post image
            if (post.imageUrl != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    post.imageUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                  ),
                ),
              ),
            
            // Post actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      post.likes.contains(_currentUserId)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: post.likes.contains(_currentUserId)
                          ? Colors.red
                          : null,
                    ),
                    onPressed: () => _likePost(post.id),
                  ),
                  Text('${post.likes.length}'),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.comment_outlined),
                    onPressed: () => _showCommentsDialog(post),
                  ),
                  Text('${post.comments.length}'),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.share_outlined),
                    onPressed: () => _sharePost(post),
                  ),
                ],
              ),
            ),
            
            // Show latest comments
            if (post.comments.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (post.comments.length > 2)
                      GestureDetector(
                        onTap: () => _showCommentsDialog(post),
                        child: Text(
                          'View all ${post.comments.length} comments',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ...post.comments.take(2).map((comment) => Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: RichText(
                            text: TextSpan(
                              style: Theme.of(context).textTheme.bodyMedium,
                              children: [
                                TextSpan(
                                  text: '${comment.username} ',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(text: comment.content),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showCreatePostDialog() {
    final TextEditingController contentController = TextEditingController();
    File? selectedImage;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create Post'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  hintText: 'What\'s on your mind?',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                maxLength: 280,
              ),
              const SizedBox(height: 16),
              
              // Photo selection section
              if (selectedImage != null)
                Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      selectedImage!,
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey.shade300,
                      style: BorderStyle.solid,
                    ),
                    color: Colors.grey.shade50,
                  ),
                  child: Icon(
                    Icons.add_photo_alternate,
                    color: Colors.grey.shade400,
                    size: 48,
                  ),
                ),
              
              const SizedBox(height: 12),
              
              // Photo action buttons (temporarily disabled)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    onPressed: null, // TODO: Re-enable when image_picker package is working
                    icon: Icon(Icons.camera_alt, color: Colors.grey[400]),
                    label: Text(
                      'Camera',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: null, // TODO: Re-enable when image_picker package is working
                    icon: Icon(Icons.photo_library, color: Colors.grey[400]),
                    label: Text(
                      'Gallery',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ),
                  if (selectedImage != null)
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          selectedImage = null;
                        });
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text(
                        'Remove',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (contentController.text.trim().isNotEmpty) {
                  Navigator.pop(context);
                  await _createPost(
                    contentController.text.trim(),
                    selectedImage,
                  );
                }
              },
              child: const Text('Post'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createPost(String content, [File? imageFile]) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Creating post...'),
          duration: Duration(seconds: 1),
        ),
      );

      // For now, we'll just pass null for imageUrl since we're not implementing
      // full Firebase Storage upload in this demo
      String? imageUrl;
      if (imageFile != null) {
        // TODO: Upload to Firebase Storage and get URL
        // For demo purposes, we'll use a placeholder
        imageUrl = 'local_image_${DateTime.now().millisecondsSinceEpoch}';
      }

      print('Creating post from social feed screen...');
      await SocialService.createPost(
        userId: _currentUserId,
        username: _currentUserName.isNotEmpty ? _currentUserName : "You",
        content: content,
        imageUrl: imageUrl,
        postType: PostType.general,
      );

      print('Post created, waiting a moment for Firestore to process...');
      // Wait a moment for Firestore to process the serverTimestamp
      await Future.delayed(const Duration(milliseconds: 500));

      // Refresh the feed to show the new post
      print('Refreshing feed...');
      await _loadFeed();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Post created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      print('Error creating post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to create post. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showCommentsDialog(SocialPost post) {
    final TextEditingController commentController = TextEditingController();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'Comments',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: post.comments.length,
                  itemBuilder: (context, index) {
                    final comment = post.comments[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(comment.username.substring(0, 1)),
                      ),
                      title: Text(comment.username),
                      subtitle: Text(comment.content),
                      trailing: Text(_formatTimeAgo(comment.createdAt)),
                    );
                  },
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: commentController,
                      decoration: const InputDecoration(
                        hintText: 'Add a comment...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      if (commentController.text.isNotEmpty) {
                        _addComment(post.id, commentController.text);
                        commentController.clear();
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sharePost(SocialPost post) {
    // TODO: Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon!')),
    );
  }

  void _deletePost(String postId) {
    setState(() {
      _posts.removeWhere((post) => post.id == postId);
    });
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}