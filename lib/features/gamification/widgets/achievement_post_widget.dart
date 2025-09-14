// lib/features/gamification/widgets/achievement_post_widget.dart

import 'package:flutter/material.dart';
import '../services/achievement_service.dart';
import '../models/gamification_models.dart';

class AchievementPostWidget extends StatelessWidget {
  final List<String> achievementIds;

  const AchievementPostWidget({Key? key, required this.achievementIds})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.withOpacity(0.1),
            Colors.orange.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.5), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Achievement header
          Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.amber[700], size: 28),
              const SizedBox(width: 8),
              Text(
                achievementIds.length == 1
                    ? 'Achievement Unlocked!'
                    : 'Achievements Unlocked!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Achievement cards
          ...achievementIds.map((achievementId) {
            final achievement = _getAchievementById(achievementId);
            return _buildAchievementCard(context, achievement);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(BuildContext context, Achievement achievement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getBadgeColor(achievement.badgeType).withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Badge icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _getBadgeColor(achievement.badgeType),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              _getBadgeIcon(achievement.badgeType),
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // Achievement details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        achievement.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '+${achievement.xpReward} XP',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getBadgeColor(
                          achievement.badgeType,
                        ).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _getBadgeTypeName(achievement.badgeType),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _getBadgeColor(achievement.badgeType),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getCategoryName(achievement.category),
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Achievement _getAchievementById(String achievementId) {
    final achievements = AchievementService.getAllAchievements();
    return achievements.firstWhere(
      (achievement) => achievement.id == achievementId,
      orElse:
          () => Achievement(
            id: achievementId,
            title: 'Achievement',
            description: 'Achievement unlocked!',
            badgeType: BadgeType.bronze,
            category: AchievementCategory.milestone,
            xpReward: 50,
            iconPath: '',
            criteria: {},
            isUnlocked: true,
          ),
    );
  }

  Color _getBadgeColor(BadgeType badgeType) {
    switch (badgeType) {
      case BadgeType.bronze:
        return Colors.orange[800]!;
      case BadgeType.silver:
        return Colors.grey[600]!;
      case BadgeType.gold:
        return Colors.amber[700]!;
      case BadgeType.platinum:
        return Colors.blueGrey[700]!;
      case BadgeType.diamond:
        return Colors.cyan[700]!;
    }
  }

  IconData _getBadgeIcon(BadgeType badgeType) {
    switch (badgeType) {
      case BadgeType.bronze:
        return Icons.workspace_premium;
      case BadgeType.silver:
        return Icons.workspace_premium;
      case BadgeType.gold:
        return Icons.emoji_events;
      case BadgeType.platinum:
        return Icons.diamond;
      case BadgeType.diamond:
        return Icons.diamond;
    }
  }

  String _getBadgeTypeName(BadgeType badgeType) {
    switch (badgeType) {
      case BadgeType.bronze:
        return 'Bronze';
      case BadgeType.silver:
        return 'Silver';
      case BadgeType.gold:
        return 'Gold';
      case BadgeType.platinum:
        return 'Platinum';
      case BadgeType.diamond:
        return 'Diamond';
    }
  }

  String _getCategoryName(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.consistency:
        return 'Consistency';
      case AchievementCategory.performance:
        return 'Performance';
      case AchievementCategory.milestone:
        return 'Milestone';
      case AchievementCategory.social:
        return 'Social';
      case AchievementCategory.special:
        return 'Special';
    }
  }
}
