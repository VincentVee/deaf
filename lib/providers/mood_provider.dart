import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/mood_entry.dart';

class MoodProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<MoodEntry> _moods = [];
  bool _isLoading = false;

  List<MoodEntry> get moods => _moods;
  bool get isLoading => _isLoading;

  Future<void> loadMoods(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('moods')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();

      _moods = snapshot.docs.map((doc) => MoodEntry.fromMap(doc.id, doc.data())).toList();
    } catch (e) {
      debugPrint('Error loading moods: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addMoodEntry({
    required String userId,
    required MoodLevel mood,
    String? note,
  }) async {
    try {
      final entry = MoodEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        date: DateTime.now(),
        mood: mood,
        note: note,
      );

      await _firestore.collection('moods').doc(entry.id).set(entry.toMap());
      _moods.insert(0, entry);
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding mood: $e');
    }
  }

  Map<MoodLevel, int> getMoodStatistics() {
    final stats = <MoodLevel, int>{};
    for (var mood in MoodLevel.values) {
      stats[mood] = _moods.where((m) => m.mood == mood).length;
    }
    return stats;
  }

  double getAverageMood() {
    if (_moods.isEmpty) return 2.5;
    final sum = _moods.fold(0, (sum, entry) => sum + entry.mood.index);
    return sum / _moods.length;
  }
}