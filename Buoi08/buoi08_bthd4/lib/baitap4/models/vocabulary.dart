/// Model lưu trữ từ vựng
class Vocabulary {
  String word;
  String meaning;
  DateTime createdAt;

  Vocabulary({
    required this.word,
    required this.meaning,
    required this.createdAt,
  });

  String toFileString() {
    return "$word|$meaning|${createdAt.toIso8601String()}";
  }

  static Vocabulary fromString(String line) {
    final parts = line.split("|");
    return Vocabulary(
      word: parts[0],
      meaning: parts[1],
      createdAt: DateTime.parse(parts[2]),
    );
  }
}

/// Model lưu trữ lịch nhắc
class Reminder {
  int id;
  String word;
  String meaning;
  DateTime scheduledTime;
  bool isShown;

  Reminder({
    required this.id,
    required this.word,
    required this.meaning,
    required this.scheduledTime,
    this.isShown = false,
  });

  String toFileString() {
    return "$id|$word|$meaning|${scheduledTime.toIso8601String()}|$isShown";
  }

  static Reminder fromString(String line) {
    final parts = line.split("|");
    return Reminder(
      id: int.parse(parts[0]),
      word: parts[1],
      meaning: parts[2],
      scheduledTime: DateTime.parse(parts[3]),
      isShown: parts[4] == 'true',
    );
  }
}
