import 'package:flutter/material.dart';

class DigitalSafetyScreen extends StatelessWidget {
  const DigitalSafetyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final safetyTips = [
      {
        'title': 'Strong Passwords',
        'tips': ['Use 12+ characters', 'Mix letters, numbers, symbols', 'Don\'t reuse passwords', 'Use a password manager'],
        'icon': Icons.lock,
        'color': Colors.blue,
      },
      {
        'title': 'Privacy Settings',
        'tips': ['Review social media privacy', 'Limit personal info shared', 'Use two-factor authentication', 'Regular privacy checkups'],
        'icon': Icons.privacy_tip,
        'color': Colors.green,
      },
      {
        'title': 'Recognize Scams',
        'tips': ['Don\'t click suspicious links', 'Verify sender identity', 'Never share verification codes', 'Report suspicious messages'],
        'icon': Icons.warning,
        'color': Colors.orange,
      },
      {
        'title': 'Safe Communication',
        'tips': ['Use encrypted messaging apps', 'Video verify when possible', 'Be cautious with strangers', 'Block and report harassment'],
        'icon': Icons.chat,
        'color': Colors.purple,
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Digital Safety')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: safetyTips.length,
        itemBuilder: (context, index) {
          final tip = safetyTips[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ExpansionTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (tip['color'] as Color).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(tip['icon'] as IconData, color: tip['color'] as Color),
              ),
              title: Text(
                tip['title'] as String,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: (tip['tips'] as List<String>).map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(fontSize: 16)),
                            Expanded(child: Text(item)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Saved ${tip['title']} to your profile')),
                      );
                    },
                    icon: const Icon(Icons.bookmark),
                    label: const Text('Save for Later'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BCD4),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}