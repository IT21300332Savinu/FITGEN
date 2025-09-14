// lib/features/gamification/screens/achievements_screen.dart

import 'package:flutter/material.dart';
import '../models/gamification_models.dart';
import '../services/achievement_service.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Achievement> _allAchievements = [];
  List<Achievement> _unlockedAchievements = [];
  List<Achievement> _lockedAchievements = [];
  
  // Mock user data - in a real app, this would come from your user service
  final Set<String> _userUnlockedAchievements = {
    'first_workout',
    'workout_streak_3',
    'total_workouts_10',
    'perfect_form_workout',
    'rep_master_50',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAchievements();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadAchievements() {
    _allAchievements = AchievementService.getAllAchievements();
    
    _unlockedAchievements = _allAchievements
        .where((achievement) => _userUnlockedAchievements.contains(achievement.id))
        .toList();
    
    _lockedAchievements = _allAchievements
        .where((achievement) => !_userUnlockedAchievements.contains(achievement.id))
        .toList();
    
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: const Icon(Icons.emoji_events),
              text: 'All (${_allAchievements.length})',
            ),
            Tab(
              icon: const Icon(Icons.lock_open),
              text: 'Unlocked (${_unlockedAchievements.length})',
            ),
            Tab(
              icon: const Icon(Icons.lock),
              text: 'Locked (${_lockedAchievements.length})',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAchievementsList(_allAchievements, showAll: true),
          _buildAchievementsList(_unlockedAchievements, showAll: false),
          _buildAchievementsList(_lockedAchievements, showAll: false),
        ],
      ),
    );
  }

  Widget _buildAchievementsList(List<Achievement> achievements, {required bool showAll}) {
    if (achievements.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No achievements here yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Keep working out to unlock more!',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Group achievements by category
    Map<AchievementCategory, List<Achievement>> groupedAchievements = {};
    for (var achievement in achievements) {
      if (!groupedAchievements.containsKey(achievement.category)) {
        groupedAchievements[achievement.category] = [];
      }
      groupedAchievements[achievement.category]!.add(achievement);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary card
        if (showAll) _buildSummaryCard(),
        
        // Achievement categories
        ...groupedAchievements.entries.map((entry) {
          return _buildCategorySection(entry.key, entry.value);
        }).toList(),
      ],
    );
  }

  Widget _buildSummaryCard() {
    final totalXP = _unlockedAchievements.fold<int>(
      0, 
      (sum, achievement) => sum + achievement.xpReward,
    );
    
    final completionRate = (_unlockedAchievements.length / _allAchievements.length * 100).round();

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Achievement Progress',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Unlocked',
                    '${_unlockedAchievements.length}',
                    Icons.emoji_events,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Total XP',
                    '$totalXP',
                    Icons.star,
                  ),
                ),
                Expanded(
                  child: _buildSummaryItem(
                    'Complete',
                    '$completionRate%',
                    Icons.check_circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _unlockedAchievements.length / _allAchievements.length,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection(AchievementCategory category, List<Achievement> achievements) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Icon(
                _getCategoryIcon(category),
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                _getCategoryTitle(category),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        ...achievements.map((achievement) => _buildAchievementCard(achievement)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    final isUnlocked = _userUnlockedAchievements.contains(achievement.id);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isUnlocked 
                ? _getBadgeColor(achievement.badgeType)
                : Colors.grey[300],
          ),
          child: Icon(
            Icons.emoji_events,
            color: isUnlocked ? Colors.white : Colors.grey[600],
            size: 24,
          ),
        ),
        title: Text(
          achievement.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isUnlocked ? null : Colors.grey[600],
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              achievement.description,
              style: TextStyle(
                color: isUnlocked ? null : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getBadgeColor(achievement.badgeType).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getBadgeTitle(achievement.badgeType),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getBadgeColor(achievement.badgeType),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '+${achievement.xpReward} XP',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isUnlocked ? Colors.green : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: isUnlocked
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.lock, color: Colors.grey),
        onTap: () => _showAchievementDetails(achievement, isUnlocked),
      ),
    );
  }

  void _showAchievementDetails(Achievement achievement, bool isUnlocked) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isUnlocked 
                    ? _getBadgeColor(achievement.badgeType)
                    : Colors.grey[300],
              ),
              child: Icon(
                Icons.emoji_events,
                color: isUnlocked ? Colors.white : Colors.grey[600],
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                achievement.title,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(achievement.description),
            const SizedBox(height: 16),
            
            // Badge info
            Row(
              children: [
                const Text('Badge: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getBadgeColor(achievement.badgeType).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getBadgeTitle(achievement.badgeType),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getBadgeColor(achievement.badgeType),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // XP reward
            Row(
              children: [
                const Text('Reward: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  '+${achievement.xpReward} XP',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Category
            Row(
              children: [
                const Text('Category: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(_getCategoryTitle(achievement.category)),
              ],
            ),
            
            if (!isUnlocked) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Keep working out to unlock this achievement!',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.milestone:
        return Icons.fitness_center;
      case AchievementCategory.consistency:
        return Icons.local_fire_department;
      case AchievementCategory.performance:
        return Icons.star;
      case AchievementCategory.social:
        return Icons.people;
      case AchievementCategory.special:
        return Icons.emoji_events;
    }
  }

  String _getCategoryTitle(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.milestone:
        return 'Workout Milestones';
      case AchievementCategory.consistency:
        return 'Consistency Streaks';
      case AchievementCategory.performance:
        return 'Perfect Form';
      case AchievementCategory.social:
        return 'Social Engagement';
      case AchievementCategory.special:
        return 'Special Events';
    }
  }

  Color _getBadgeColor(BadgeType badgeType) {
    switch (badgeType) {
      case BadgeType.bronze:
        return Colors.orange[800]!;
      case BadgeType.silver:
        return Colors.grey[400]!;
      case BadgeType.gold:
        return Colors.amber;
      case BadgeType.platinum:
        return Colors.blueGrey;
      case BadgeType.diamond:
        return Colors.cyan;
    }
  }

  String _getBadgeTitle(BadgeType badgeType) {
    switch (badgeType) {
      case BadgeType.bronze:
        return 'BRONZE';
      case BadgeType.silver:
        return 'SILVER';
      case BadgeType.gold:
        return 'GOLD';
      case BadgeType.platinum:
        return 'PLATINUM';
      case BadgeType.diamond:
        return 'DIAMOND';
    }
  }
}