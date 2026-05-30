import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MoodEntry {
  final String id;
  final String userId;
  final DateTime date;
  final MoodLevel mood;
  final String? note;

  MoodEntry({
    required this.id,
    required this.userId,
    required this.date,
    required this.mood,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'date': date,
      'mood': mood.index,
      'note': note,
    };
  }

  factory MoodEntry.fromMap(String id, Map<String, dynamic> map) {
    return MoodEntry(
      id: id,
      userId: map['userId'] ?? '',
      date: (map['date'] as dynamic).toDate(),
      mood: MoodLevel.values[map['mood'] ?? 2],
      note: map['note'],
    );
  }
}

enum MoodLevel {
  veryBad,
  bad,
  neutral,
  good,
  excellent,
}

extension MoodExtension on MoodLevel {
  String get displayName {
    switch (this) {
      case MoodLevel.veryBad:
        return 'Very Bad';
      case MoodLevel.bad:
        return 'Bad';
      case MoodLevel.neutral:
        return 'Neutral';
      case MoodLevel.good:
        return 'Good';
      case MoodLevel.excellent:
        return 'Excellent';
    }
  }

  IconData get icon {
    switch (this) {
      case MoodLevel.veryBad:
        return Icons.sentiment_very_dissatisfied;
      case MoodLevel.bad:
        return Icons.sentiment_dissatisfied;
      case MoodLevel.neutral:
        return Icons.sentiment_neutral;
      case MoodLevel.good:
        return Icons.sentiment_satisfied;
      case MoodLevel.excellent:
        return Icons.sentiment_very_satisfied;
    }
  }

  Color get color {
    switch (this) {
      case MoodLevel.veryBad:
        return Colors.red;
      case MoodLevel.bad:
        return Colors.orange;
      case MoodLevel.neutral:
        return Colors.grey;
      case MoodLevel.good:
        return Colors.lightGreen;
      case MoodLevel.excellent:
        return Colors.green;
    }
  }
}