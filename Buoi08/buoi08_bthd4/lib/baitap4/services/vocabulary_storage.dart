import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/vocabulary.dart';

class VocabularyStorage {
  // === VOCABULARY CRUD ===

  Future<String> get _path async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<File> get _vocabFile async {
    final path = await _path;
    return File('$path/vocabulary.txt');
  }

  Future<void> saveVocabularies(List<Vocabulary> vocabs) async {
    final file = await _vocabFile;
    String data = vocabs.map((e) => e.toFileString()).join("\n");
    await file.writeAsString(data);
  }

  Future<List<Vocabulary>> loadVocabularies() async {
    try {
      final file = await _vocabFile;
      final content = await file.readAsString();
      return content
          .split("\n")
          .where((e) => e.isNotEmpty)
          .map((e) => Vocabulary.fromString(e))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> addVocabulary(Vocabulary vocab) async {
    final vocabs = await loadVocabularies();
    vocabs.add(vocab);
    await saveVocabularies(vocabs);
  }

  // === REMINDER CRUD ===

  Future<File> get _reminderFile async {
    final path = await _path;
    return File('$path/reminders.txt');
  }

  Future<void> saveReminders(List<Reminder> reminders) async {
    final file = await _reminderFile;
    String data = reminders.map((e) => e.toFileString()).join("\n");
    await file.writeAsString(data);
  }

  Future<List<Reminder>> loadReminders() async {
    try {
      final file = await _reminderFile;
      final content = await file.readAsString();
      return content
          .split("\n")
          .where((e) => e.isNotEmpty)
          .map((e) => Reminder.fromString(e))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> addReminder(Reminder reminder) async {
    final reminders = await loadReminders();
    reminders.add(reminder);
    await saveReminders(reminders);
  }

  /// Lấy danh sách lịch nhắc chưa hiển thị
  Future<List<Reminder>> getPendingReminders() async {
    final reminders = await loadReminders();
    final now = DateTime.now();
    return reminders
        .where((r) => !r.isShown && r.scheduledTime.isAfter(now))
        .toList();
  }

  /// Đánh dấu lịch nhắc đã hiển thị
  Future<void> markReminderAsShown(int id) async {
    final reminders = await loadReminders();
    for (var r in reminders) {
      if (r.id == id) {
        r.isShown = true;
      }
    }
    await saveReminders(reminders);
  }

  /// Xóa lịch nhắc
  Future<void> deleteReminder(int id) async {
    final reminders = await loadReminders();
    reminders.removeWhere((r) => r.id == id);
    await saveReminders(reminders);
  }
}
