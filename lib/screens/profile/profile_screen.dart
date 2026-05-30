import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/mood_entry.dart';
import '../../providers/auth_provider.dart';
import '../../providers/mood_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final moodProvider = Provider.of<MoodProvider>(context);
    final user = authProvider.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,  // ✅ Added
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFF1A237E),
              child: Text(
                user?.name[0].toUpperCase() ?? 'U',
                style: const TextStyle(fontSize: 48, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.name ?? 'User',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,  // ✅ Added
            ),
            Text(
              user?.email ?? '',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,  // ✅ Added
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: user?.role == 'admin' ? Colors.red.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                user?.role == 'admin' ? 'Administrator' : 'Member',
                style: TextStyle(
                  color: user?.role == 'admin' ? Colors.red : Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,  // ✅ Added
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Account Information',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    _buildInfoRow('Member Since', user?.createdAt.toString().substring(0, 10) ?? ''),
                    _buildInfoRow('Account Status', user?.isActive == true ? 'Active' : 'Disabled'),
                    _buildInfoRow('User ID', user?.id ?? ''),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,  // ✅ Added
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Activity Summary',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    _buildInfoRow('Moods Logged', moodProvider.moods.length.toString()),
                    _buildInfoRow('Average Mood', moodProvider.getAverageMood().toStringAsFixed(1)),
                    const SizedBox(height: 8),
                    const Text(
                      'Mood Distribution:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    ...MoodLevel.values.map((mood) {
                      final count = moodProvider.getMoodStatistics()[mood] ?? 0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mood.displayName,
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 2),
                            LinearProgressIndicator(
                              value: moodProvider.moods.isEmpty ? 0 : count / moodProvider.moods.length,
                              backgroundColor: Colors.grey[200],
                              color: mood.color,
                              minHeight: 8,  // ✅ Added
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SafeArea(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,  // ✅ Added
                    children: [
                      ListTile(
                        leading: const Icon(Icons.info, color: Color(0xFF1A237E)),
                        title: const Text('About DeafSmart'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          _showAboutDialog(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),  // ✅ Added bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),  // ✅ Reduced from 8
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,  // ✅ Changed to start alignment
        children: [
          SizedBox(
            width: 110,  // ✅ Fixed width for label
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 13),  // ✅ Reduced size
            ),
          ),
          const SizedBox(width: 8),
          Expanded(  // ✅ Use Expanded to handle overflow
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),  // ✅ Reduced size
              softWrap: true,  // ✅ Allow wrapping
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About DeafSmart'),
        content: const SingleChildScrollView(  // ✅ Make content scrollable
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Version 1.0.0'),
              SizedBox(height: 8),
              Text('DeafSmart is a mobile application empowering the deaf and hard-of-hearing community with accessible tools for communication, safety, and education.'),
              SizedBox(height: 16),
              Text('Features:'),
              Text('• Sign Language Video Feed'),
              Text('• Mental Health Support'),
              Text('• Financial Literacy Resources'),
              Text('• Digital Safety Education'),
              Text('• SOS Emergency Alerts'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}