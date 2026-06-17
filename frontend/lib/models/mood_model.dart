class MoodEntry {
  final int? id;
  final int moodScore;
  final int energyLevel;
  final int sleepQuality;
  final int anxietyLevel;
  final String? notes;
  final String? createdAt;

  MoodEntry({
    this.id,
    required this.moodScore,
    required this.energyLevel,
    required this.sleepQuality,
    required this.anxietyLevel,
    this.notes,
    this.createdAt,
  });

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      id: json['id'] as int?,
      moodScore: json['moodScore'] as int,
      energyLevel: json['energyLevel'] as int,
      sleepQuality: json['sleepQuality'] as int,
      anxietyLevel: json['anxietyLevel'] as int,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'moodScore': moodScore,
      'energyLevel': energyLevel,
      'sleepQuality': sleepQuality,
      'anxietyLevel': anxietyLevel,
      'notes': notes,
    };
  }

  String get moodEmoji {
    if (moodScore >= 8) return '😊';
    if (moodScore >= 6) return '🙂';
    if (moodScore >= 4) return '😐';
    if (moodScore >= 2) return '😢';
    return '😭';
  }

  String get moodLabel {
    if (moodScore >= 8) return 'Great';
    if (moodScore >= 6) return 'Good';
    if (moodScore >= 4) return 'Okay';
    if (moodScore >= 2) return 'Low';
    return 'Struggling';
  }
}
