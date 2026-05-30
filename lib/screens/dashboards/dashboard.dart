import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/mood_entry.dart';
import '../../providers/auth_provider.dart';
import '../../providers/mood_provider.dart';
import '../../providers/video_provider.dart';
import '../mental_health/mental_health_screen.dart';
import '../video/video_feed_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _moodsLogged = 0;
  int _videosWatched = 0;
  int _daysActive = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final moodProvider = Provider.of<MoodProvider>(context, listen: false);
    final videoProvider = Provider.of<VideoProvider>(context, listen: false);

    await moodProvider.loadMoods(authProvider.currentUser!.id);
    await videoProvider.loadVideos();

    setState(() {
      _moodsLogged = moodProvider.moods.length;
      _videosWatched = videoProvider.videos.length;

      final uniqueDays = moodProvider.moods.map((entry) =>
      '${entry.date.year}-${entry.date.month}-${entry.date.day}'
      ).toSet();
      _daysActive = uniqueDays.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      _buildStatsCard(),
                      const SizedBox(height: 12),
                      _buildMoodChart(),
                      const SizedBox(height: 12),
                      _buildQuickActions(context),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Your Activity',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('Videos Watched', _videosWatched.toString()),
                _buildStatItem('Moods Logged', _moodsLogged.toString()),
                _buildStatItem('Days Active', _daysActive.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMoodChart() {
    final moodProvider = Provider.of<MoodProvider>(context);

    if (moodProvider.moods.isEmpty) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.mood_bad, size: 40, color: Colors.grey),
              const SizedBox(height: 8),
              const Text(
                'No mood data yet',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(120, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MentalHealthScreen()),
                  );
                },
                child: const Text('Log Your First Mood', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
        ),
      );
    }

    final last7Days = moodProvider.moods.take(7).toList();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Mood Trends',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 90,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: last7Days.reversed.map((entry) {
                  return Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: (entry.mood.index + 1) * 14.0,
                          width: 22,
                          decoration: BoxDecoration(
                            color: entry.mood.color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${entry.date.day}/${entry.date.month}',
                          style: const TextStyle(fontSize: 8),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Card(
      elevation: 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 10, bottom: 4),
            child: Text(
              'Quick Actions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            dense: true,
            visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
            leading: const Icon(Icons.mood, color: Color(0xFF1A237E), size: 20),
            title: const Text('Log Mood', style: TextStyle(fontSize: 14)),
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MentalHealthScreen()),
              );
            },
          ),
          const Divider(height: 0, indent: 50),
          ListTile(
            dense: true,
            visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
            leading: const Icon(Icons.air, color: Color(0xFF1A237E), size: 20),
            title: const Text('Breathing Exercise', style: TextStyle(fontSize: 14)),
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MentalHealthScreen()),
              );
            },
          ),
          const Divider(height: 0, indent: 50),
          ListTile(
            dense: true,
            visualDensity: const VisualDensity(horizontal: 0, vertical: -2),
            leading: const Icon(Icons.video_call, color: Color(0xFF1A237E), size: 20),
            title: const Text('Upload Video', style: TextStyle(fontSize: 14)),
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VideoFeedScreen()),
              );
            },
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}