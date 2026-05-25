import 'package:flutter/material.dart';
import '../models/vocabulary.dart';
import '../services/vocabulary_storage.dart';
import '../../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _wordController = TextEditingController();
  final TextEditingController _meaningController = TextEditingController();
  final VocabularyStorage _storage = VocabularyStorage();

  @override
  void dispose() {
    _wordController.dispose();
    _meaningController.dispose();
    super.dispose();
  }

  void _saveAndRemind() async {
    final word = _wordController.text.trim();
    final meaning = _meaningController.text.trim();

    if (word.isEmpty || meaning.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đầy đủ từ và nghĩa'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Lưu từ vựng
    final vocab = Vocabulary(
      word: word,
      meaning: meaning,
      createdAt: DateTime.now(),
    );
    await _storage.addVocabulary(vocab);

    // Tạo lịch nhắc sau 10 phút
    final remindTime = DateTime.now().add(const Duration(minutes: 10));
    final reminderId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final reminder = Reminder(
      id: reminderId,
      word: word,
      meaning: meaning,
      scheduledTime: remindTime,
    );
    await _storage.addReminder(reminder);

    try {
      // Hiển thị notification ngay
      await NotificationService().showCustomNotification(
        id: reminderId,
        title: 'Đã lưu từ vựng',
        body: 'Từ "$word" đã được lưu. Hãy ôn tập sau 10 phút!',
      );

      // Lên lịch notification sau 10 phút
      await NotificationService().scheduleCustomNotification(
        id: reminderId + 1,
        title: 'Nhắc ôn tập từ vựng',
        body: 'Hãy ôn tập từ "$word" - "$meaning"',
        scheduledTime: remindTime,
      );
    } catch (e) {
      debugPrint('Lỗi notification (có thể do chạy trên Web): $e');
    }

    // Xóa input
    _wordController.clear();
    _meaningController.clear();

    // Hiển thị SnackBar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Đã lưu và lên lịch nhắc học từ sau 10 phút'),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TextField "Từ"
          const Text(
            'Từ',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          TextField(
            controller: _wordController,
            decoration: const InputDecoration(
              hintText: 'Nhập từ tiếng Anh',
              border: UnderlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),

          // TextField "Nghĩa"
          const Text(
            'Nghĩa',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          TextField(
            controller: _meaningController,
            decoration: const InputDecoration(
              hintText: 'Nhập nghĩa tiếng Việt',
              border: UnderlineInputBorder(),
            ),
          ),
          const SizedBox(height: 40),

          // Nút "Lưu & Nhắc học sau 10 phút"
          Center(
            child: OutlinedButton(
              onPressed: _saveAndRemind,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.grey),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Lưu & Nhắc học sau 10 phút',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
