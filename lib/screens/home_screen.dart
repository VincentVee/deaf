import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'dashboards/dashboard.dart';
import 'video/video_feed_screen.dart';
import 'mental_health/mental_health_screen.dart';
import 'education/financial_literacy_screen.dart';
import 'education/digital_safety_screen.dart';
import 'sos/sos_screen.dart';
import 'profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('DeafSmart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.dashboard),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),  // ✅ Reduced from 16
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,  // ✅ Added
          children: [
            _buildWelcomeSection(authProvider.currentUser?.name ?? 'User'),
            const SizedBox(height: 16),  // ✅ Reduced from 24
            _buildQuickStatsPreview(),
            const SizedBox(height: 16),  // ✅ Reduced from 24
            const Text(
              'Features',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),  // ✅ Reduced from 20
            ),
            const SizedBox(height: 12),  // ✅ Reduced from 16
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,  // ✅ Reduced from 16
              crossAxisSpacing: 12,  // ✅ Reduced from 16
              childAspectRatio: 1.0,  // ✅ Changed from 1.1
              children: [
                _buildFeatureCard(
                  context,
                  'Video Feed',
                  Icons.video_library,
                  Colors.blue,
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VideoFeedScreen())),
                ),
                _buildFeatureCard(
                  context,
                  'Mental Health',
                  Icons.favorite,
                  Colors.purple,
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MentalHealthScreen())),
                ),
                _buildFeatureCard(
                  context,
                  'Financial Literacy',
                  Icons.attach_money,
                  Colors.green,
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FinancialLiteracyScreen())),
                ),
                _buildFeatureCard(
                  context,
                  'Digital Safety',
                  Icons.security,
                  Colors.orange,
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DigitalSafetyScreen())),
                ),
                _buildFeatureCard(
                  context,
                  'SOS Emergency',
                  Icons.sos,
                  Colors.red,
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SOSScreen())),
                ),
                _buildFeatureCard(
                  context,
                  'Dashboard',
                  Icons.dashboard,
                  Colors.teal,
                      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DashboardScreen())),
                ),
              ],
            ),
            const SizedBox(height: 8),  // ✅ Added bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(String name) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),  // ✅ Reduced from 20
        child: Column(
          mainAxisSize: MainAxisSize.min,  // ✅ Added
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, $name!',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),  // ✅ Reduced from 24
            ),
            const SizedBox(height: 6),  // ✅ Reduced from 8
            const Text(
              'Welcome to DeafSmart. Empowering your communication and safety.',
              style: TextStyle(fontSize: 12, color: Colors.grey),  // ✅ Reduced from 14
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStatsPreview() {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          );
        },
        borderRadius: BorderRadius.circular(12),  // ✅ Reduced from 16
        child: Padding(
          padding: const EdgeInsets.all(12),  // ✅ Reduced from 20
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),  // ✅ Reduced from 12
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.analytics, size: 24, color: Colors.teal),  // ✅ Reduced from 32
              ),
              const SizedBox(width: 12),  // ✅ Reduced from 16
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,  // ✅ Added
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Activity Summary',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),  // ✅ Reduced from 16
                    ),
                    const SizedBox(height: 2),  // ✅ Reduced from 4
                    Text(
                      'Tap to view detailed dashboard with charts',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),  // ✅ Reduced from 12
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),  // ✅ Reduced from 16
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
      BuildContext context,
      String title,
      IconData icon,
      Color color,
      VoidCallback onTap,
      ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),  // ✅ Reduced from 16
        child: Padding(
          padding: const EdgeInsets.all(12),  // ✅ Reduced from 16
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),  // ✅ Reduced from 12
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 32, color: color),  // ✅ Reduced from 40
              ),
              const SizedBox(height: 8),  // ✅ Reduced from 12
              Text(
                title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),  // ✅ Reduced from 16
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}