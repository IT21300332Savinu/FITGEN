// lib/features/gamification/screens/leaderboard_screen.dart

import 'package:flutter/material.dart';
import '../models/gamification_models.dart';
import '../services/leaderboard_service.dart';
import '../services/user_session_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<LeaderboardEntry> _globalLeaderboard = [];
  List<LeaderboardEntry> _weeklyLeaderboard = [];
  List<LeaderboardEntry> _monthlyLeaderboard = [];
  List<LeaderboardEntry> _friendsLeaderboard = [];
  bool _isLoading = true;
  String _currentUserId = ""; // Will be loaded from session

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    final userId = await UserSessionService.getCurrentUserId();
    setState(() {
      _currentUserId = userId ?? "guest_user";
    });
    _loadLeaderboards();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLeaderboards() async {
    setState(() => _isLoading = true);
    
    try {
      // In a real app, these would be API calls
      _globalLeaderboard = await LeaderboardService.getGlobalLeaderboard();
      _weeklyLeaderboard = await LeaderboardService.getWeeklyLeaderboard();
      _monthlyLeaderboard = await LeaderboardService.getMonthlyLeaderboard();
      _friendsLeaderboard = await LeaderboardService.getFriendsLeaderboard(_currentUserId);
    } catch (e) {
      print('Error loading leaderboards: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Global'),
            Tab(text: 'Weekly'),
            Tab(text: 'Monthly'),
            Tab(text: 'Friends'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildLeaderboardTab(_globalLeaderboard, 'Global Rankings'),
                _buildLeaderboardTab(_weeklyLeaderboard, 'This Week'),
                _buildLeaderboardTab(_monthlyLeaderboard, 'This Month'),
                _buildLeaderboardTab(_friendsLeaderboard, 'Friends'),
              ],
            ),
    );
  }

  Widget _buildLeaderboardTab(List<LeaderboardEntry> entries, String title) {
    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No rankings yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete workouts to appear on the leaderboard!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[500],
                  ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadLeaderboards,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: entries.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildTopThree(entries.take(3).toList());
          }
          
          final entry = entries[index - 1];
          return _buildLeaderboardCard(entry, index - 1);
        },
      ),
    );
  }

  Widget _buildTopThree(List<LeaderboardEntry> topThree) {
    if (topThree.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          Text(
            'Top Performers',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Second place
              if (topThree.length > 1) _buildPodiumPosition(topThree[1], 2),
              // First place
              if (topThree.isNotEmpty) _buildPodiumPosition(topThree[0], 1),
              // Third place
              if (topThree.length > 2) _buildPodiumPosition(topThree[2], 3),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumPosition(LeaderboardEntry entry, int position) {
    Color backgroundColor;
    Color textColor = Colors.white;
    double height;
    IconData icon;

    switch (position) {
      case 1:
        backgroundColor = Colors.amber;
        height = 120;
        icon = Icons.emoji_events;
        break;
      case 2:
        backgroundColor = Colors.grey[400]!;
        height = 100;
        icon = Icons.emoji_events;
        break;
      case 3:
        backgroundColor = Colors.orange[800]!;
        height = 80;
        icon = Icons.emoji_events;
        break;
      default:
        backgroundColor = Colors.grey;
        height = 60;
        icon = Icons.emoji_events;
    }

    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: backgroundColor,
          backgroundImage: entry.avatarUrl != null 
              ? NetworkImage(entry.avatarUrl!)
              : null,
          child: entry.avatarUrl == null
              ? Text(
                  entry.username.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
              : null,
        ),
        const SizedBox(height: 8),
        Text(
          entry.username,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          'Level ${entry.level}',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: textColor, size: 24),
              const SizedBox(height: 4),
              Text(
                '#$position',
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                '${entry.totalXP} XP',
                style: TextStyle(
                  color: textColor,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardCard(LeaderboardEntry entry, int index) {
    bool isCurrentUser = entry.userId == _currentUserId;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isCurrentUser 
            ? Theme.of(context).primaryColor.withOpacity(0.1)
            : null,
        border: isCurrentUser 
            ? Border.all(color: Theme.of(context).primaryColor, width: 2)
            : null,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _getRankColor(entry.rank),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  '#${entry.rank}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 20,
              backgroundImage: entry.avatarUrl != null 
                  ? NetworkImage(entry.avatarUrl!)
                  : null,
              child: entry.avatarUrl == null
                  ? Text(
                      entry.username.substring(0, 1).toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                entry.username,
                style: TextStyle(
                  fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
            if (isCurrentUser)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'You',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Text('Level ${entry.level}'),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${entry.totalXP} XP',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (_tabController.index == 1) // Weekly tab
              Text(
                '+${entry.weeklyXP} this week',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green[600],
                ),
              )
            else if (_tabController.index == 2) // Monthly tab
              Text(
                '+${entry.monthlyXP} this month',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue[600],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return Colors.amber;
    if (rank == 2) return Colors.grey[400]!;
    if (rank == 3) return Colors.orange[800]!;
    if (rank <= 10) return Colors.purple[400]!;
    if (rank <= 50) return Colors.blue[400]!;
    return Colors.grey[600]!;
  }
}