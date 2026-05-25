import 'package:flutter/material.dart';
import '../models/vocabulary.dart';
import '../services/vocabulary_storage.dart';
import '../../services/notification_service.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({Key? key}) : super(key: key);

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  final VocabularyStorage _storage = VocabularyStorage();
  List<Reminder> _pendingReminders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  void _loadReminders() async {
    final reminders = await _storage.getPendingReminders();
    setState(() {
      _pendingReminders = reminders;
      _isLoading = false;
    });
  }

  void _deleteReminder(Reminder reminder) async {
    // Hủy notification
    await NotificationService().cancelNotification(reminder.id);
    await NotificationService().cancelNotification(reminder.id + 1);

    // Xóa khỏi storage
    await _storage.deleteReminder(reminder.id);

    // Reload
    _loadReminders();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xóa lịch nhắc "${reminder.word}"'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final day = time.day.toString().padLeft(2, '0');
    final month = time.month.toString().padLeft(2, '0');
    final year = time.year;
    return '$day/$month/$year $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch nhắc'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingReminders.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_off,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Không có lịch nhắc nào',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _pendingReminders.length,
                  itemBuilder: (context, index) {
                    final reminder = _pendingReminders[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(
                          Icons.access_time,
                          color: Colors.blue,
                        ),
                        title: Text(
                          'Ôn tập từ vựng mới',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          '${reminder.word} - ${reminder.meaning}\n${_formatTime(reminder.scheduledTime)}',
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.cancel,
                            color: Colors.red,
                          ),
                          onPressed: () => _deleteReminder(reminder),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
