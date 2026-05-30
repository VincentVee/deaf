import 'package:flutter/material.dart';

class FinancialLiteracyScreen extends StatelessWidget {
  const FinancialLiteracyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topics = [
      {'title': 'Budgeting Basics', 'description': 'Learn how to manage your money effectively', 'icon': Icons.account_balance_wallet},
      {'title': 'Saving Strategies', 'description': 'Tips for building your savings', 'icon': Icons.savings},
      {'title': 'Understanding Credit', 'description': 'How credit scores work', 'icon': Icons.credit_card},
      {'title': 'Deaf-Friendly Banking', 'description': 'Banking services for the deaf community', 'icon': Icons.account_balance},
      {'title': 'Avoiding Scams', 'description': 'Protect yourself from financial fraud', 'icon': Icons.security},
      {'title': 'Investing 101', 'description': 'Introduction to investing', 'icon': Icons.trending_up},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Financial Literacy')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: topics.length,
        itemBuilder: (context, index) {
          final topic = topics[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF1A237E).withOpacity(0.1),
                child: Icon(topic['icon'] as IconData, color: const Color(0xFF1A237E)),
              ),
              title: Text(topic['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(topic['description'] as String),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                _showLessonDialog(context, topic['title'] as String);
              },
            ),
          );
        },
      ),
    );
  }

  void _showLessonDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Key Takeaways:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('• Set a monthly budget and track expenses'),
              const Text('• Save at least 10% of your income'),
              const Text('• Build an emergency fund for unexpected costs'),
              const Text('• Use visual banking apps designed for accessibility'),
              const SizedBox(height: 16),
              const Text(
                'Resources:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('• Video tutorials in sign language'),
              const Text('• Downloadable budget templates'),
              const Text('• Financial advisor directory for deaf community'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Save to Profile'),
          ),
        ],
      ),
    );
  }
}