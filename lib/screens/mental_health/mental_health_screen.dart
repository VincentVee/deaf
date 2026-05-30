import 'package:deaf/screens/mental_health/resource_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/mood_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/mood_entry.dart';
import 'resource_detail_screen.dart';  // Add this import


class MentalHealthScreen extends StatefulWidget {
  const MentalHealthScreen({super.key});

  @override
  State<MentalHealthScreen> createState() => _MentalHealthScreenState();
}

class _MentalHealthScreenState extends State<MentalHealthScreen> {
  MoodLevel? _selectedMood;
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      Provider.of<MoodProvider>(context, listen: false).loadMoods(authProvider.currentUser!.id);
    });
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final moodProvider = Provider.of<MoodProvider>(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mental Health'),
          bottom:  TabBar(
            tabs: [
              Tab(child: Text("Mood Tracker", style: TextStyle(color: Colors.white),),),
              Tab(child: Text("Resources", style: TextStyle(color: Colors.white),),),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildMoodTracker(moodProvider),
            _buildResources(),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodTracker(MoodProvider moodProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'How are you feeling today?',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  // ✅ Fixed: Wrap Row in SingleChildScrollView for horizontal scrolling
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: MoodLevel.values.map((mood) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedMood = mood;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: _selectedMood == mood
                                        ? mood.color.withOpacity(0.2)
                                        : Colors.grey.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                    border: _selectedMood == mood
                                        ? Border.all(color: mood.color, width: 2)
                                        : null,
                                  ),
                                  child: Icon(mood.icon, size: 32, color: mood.color),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  mood.displayName,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: _selectedMood == mood ? mood.color : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      labelText: 'Add a note (optional)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _selectedMood == null ? null : () async {
                      final authProvider = Provider.of<AuthProvider>(context, listen: false);
                      await moodProvider.addMoodEntry(
                        userId: authProvider.currentUser!.id,
                        mood: _selectedMood!,
                        note: _noteController.text.isNotEmpty ? _noteController.text : null,
                      );
                      setState(() {
                        _selectedMood = null;
                        _noteController.clear();
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Mood logged successfully!')),
                      );
                    },
                    child: const Text('Log Mood'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text(
                    'Mood History',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (moodProvider.moods.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('No mood entries yet', style: TextStyle(color: Colors.grey)),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: moodProvider.moods.length > 7 ? 7 : moodProvider.moods.length,
                      itemBuilder: (context, index) {
                        final entry = moodProvider.moods[index];
                        return ListTile(
                          leading: Icon(entry.mood.icon, color: entry.mood.color),
                          title: Text(entry.mood.displayName),
                          subtitle: entry.note != null && entry.note!.isNotEmpty
                              ? Text(entry.note!, maxLines: 1, overflow: TextOverflow.ellipsis)
                              : null,
                          trailing: Text(
                            '${entry.date.day}/${entry.date.month}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildBreathingExercise(),
        ],
      ),
    );
  }

  Widget _buildBreathingExercise() {
    return SafeArea(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text(
                'Breathing Exercise',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Take a moment to relax with guided breathing',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  _showBreathingExerciseDialog();
                },
                icon: const Icon(Icons.air),
                label: const Text('Start Exercise'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BCD4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBreathingExerciseDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: const BreathingExerciseWidget(),
      ),
    );
  }

  Widget _buildResources() {
    final resources = [
      {
        'title': 'Understanding Anxiety',
        'category': 'Mental Health Education',
        'duration': '5 min read',
        'icon': Icons.psychology,
        'color': Colors.blue
      },
      {
        'title': 'Deaf Mental Health Resources',
        'category': 'Deaf-Specific Support',
        'duration': '10 min read',
        'icon': Icons.accessibility_new,
        'color': Colors.purple
      },
      {
        'title': 'Stress Management Tips',
        'category': 'Daily Wellness',
        'duration': '3 min read',
        'icon': Icons.self_improvement,
        'color': Colors.green
      },
      {
        'title': 'Building Resilience',
        'category': 'Personal Growth',
        'duration': '7 min read',
        'icon': Icons.shield,
        'color': Colors.orange
      },
      {
        'title': 'Sign Language Therapy',
        'category': 'Professional Help',
        'duration': '15 min watch',
        'icon': Icons.video_library,
        'color': Colors.teal
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: resources.length,
      itemBuilder: (context, index) {
        final resource = resources[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              // ✅ Navigate to resource detail screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ResourceDetailScreen(
                    title: resource['title'] as String,
                    category: resource['category'] as String,
                    icon: resource['icon'] as IconData,
                    color: resource['color'] as Color,
                  ),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: (resource['color'] as Color).withOpacity(0.1),
                    child: Icon(resource['icon'] as IconData, color: resource['color'] as Color, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          resource['title'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          resource['category'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.access_time, size: 12, color: Colors.grey[500]),
                            const SizedBox(width: 4),
                            Text(
                              resource['duration'] as String,
                              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class BreathingExerciseWidget extends StatefulWidget {
  const BreathingExerciseWidget({super.key});

  @override
  State<BreathingExerciseWidget> createState() => _BreathingExerciseWidgetState();
}

class _BreathingExerciseWidgetState extends State<BreathingExerciseWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _instruction = 'Get Ready';
  int _phase = 0;
  final List<String> _instructions = ['Breathe In', 'Hold', 'Breathe Out', 'Hold'];
  bool _isExercising = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _startExercise();
  }

  void _startExercise() async {
    for (int i = 0; i < _instructions.length * 4 && _isExercising; i++) {
      final phaseIndex = i % _instructions.length;
      if (mounted) {
        setState(() {
          _instruction = _instructions[phaseIndex];
          _phase = phaseIndex;
        });
      }

      int duration = phaseIndex == 0 || phaseIndex == 2 ? 4 : 2;
      _controller.duration = Duration(seconds: duration);
      await _controller.forward(from: 0);
    }

    if (mounted && _isExercising) {
      setState(() {
        _instruction = 'Complete!';
      });
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _isExercising = false;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              double scale = 0.5 + (_controller.value * 0.8);
              return Container(
                width: 150 * scale,
                height: 150 * scale,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getColorForPhase().withOpacity(0.2),
                  border: Border.all(color: _getColorForPhase(), width: 3),
                ),
                child: Center(
                  child: Text(
                    _controller.value.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: _getColorForPhase(),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            _instruction,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              _isExercising = false;
              Navigator.pop(context);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Color _getColorForPhase() {
    switch (_phase) {
      case 0:
        return Colors.blue;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.green;
      case 3:
        return Colors.purple;
      default:
        return Colors.blue;
    }
  }
}