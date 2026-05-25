import 'package:flutter/material.dart';
import '../models/vocabulary.dart';
import '../services/vocabulary_storage.dart';
import '../../services/notification_service.dart';

class LearnScreen extends StatefulWidget {
  const LearnScreen({Key? key}) : super(key: key);

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  final TextEditingController _answerController = TextEditingController();
  final VocabularyStorage _storage = VocabularyStorage();

  List<Vocabulary> _vocabs = [];
  int _currentIndex = 0;
  int _correctCount = 0;
  int _wrongCount = 0;
  bool _isLoading = true;

  bool? _isLastAnswerCorrect;
  String? _feedbackMessage;

  @override
  void initState() {
    super.initState();
    _loadVocabularies();
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _loadVocabularies() async {
    final vocabs = await _storage.loadVocabularies();
    setState(() {
      _vocabs = vocabs;
      _isLoading = false;
    });
  }

  void _nextWord() {
    if (_vocabs.isEmpty) return;
    setState(() {
      _answerController.clear();
      _isLastAnswerCorrect = null;
      _feedbackMessage = null;
      if (_currentIndex < _vocabs.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0; // Quay vòng
      }
    });
  }

  void _prevWord() {
    if (_vocabs.isEmpty) return;
    setState(() {
      _answerController.clear();
      _isLastAnswerCorrect = null;
      _feedbackMessage = null;
      if (_currentIndex > 0) {
        _currentIndex--;
      } else {
        _currentIndex = _vocabs.length - 1; // Quay vòng
      }
    });
  }

  void _checkAnswer() async {
    if (_vocabs.isEmpty || _currentIndex >= _vocabs.length) return;

    final answer = _answerController.text.trim().toLowerCase();
    final correctMeaning = _vocabs[_currentIndex].meaning.trim().toLowerCase();

    setState(() {
      if (answer == correctMeaning) {
        _correctCount++;
        _isLastAnswerCorrect = true;
        _feedbackMessage = 'Chính xác!';
      } else {
        _wrongCount++;
        _isLastAnswerCorrect = false;
        _feedbackMessage = 'Sai rồi!';
      }
    });

    if (_isLastAnswerCorrect == false && _wrongCount > 0 && _wrongCount % 3 == 0) {
      try {
        await NotificationService().showCustomNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: 'Cảnh báo học từ',
          body: 'Bạn đã sai $_wrongCount từ! Hãy ôn tập kỹ hơn nhé!',
        );
      } catch (e) {
        debugPrint('Lỗi notification: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Ôn tập từ mới', style: TextStyle(color: Colors.black87, fontSize: 18)),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black54),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _vocabs.isEmpty
              ? const Center(
                  child: Text(
                    'Chưa có từ vựng nào.\nHãy thêm từ ở Trang chính!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            // Badges đúng / sai
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildBadge(
                                  icon: Icons.check,
                                  count: _correctCount,
                                  label: 'từ',
                                  color: Colors.green.shade500,
                                ),
                                const SizedBox(width: 16),
                                _buildBadge(
                                  icon: Icons.close,
                                  count: _wrongCount,
                                  label: 'từ',
                                  color: Colors.orange.shade500,
                                ),
                              ],
                            ),
                            const SizedBox(height: 40),

                            // Hiển thị từ
                            if (_currentIndex < _vocabs.length) ...[
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFB3CDE0), // Màu xanh nhạt giống ảnh
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.arrow_back_ios, color: Colors.black54),
                                          onPressed: _prevWord,
                                          tooltip: 'Từ trước đó',
                                        ),
                                        Expanded(
                                          child: Text(
                                            _vocabs[_currentIndex].word,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 26,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.arrow_forward_ios, color: Colors.black54),
                                          onPressed: _nextWord,
                                          tooltip: 'Từ tiếp theo',
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 24),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: TextField(
                                        controller: _answerController,
                                        decoration: const InputDecoration(
                                          hintText: 'Nhập nghĩa tiếng Việt',
                                          hintStyle: TextStyle(color: Colors.black38),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                        ),
                                        onSubmitted: (_) => _checkAnswer(),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: _checkAnswer,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue.shade700,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 40,
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: const Text(
                                        'Check',
                                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Từ ${_currentIndex + 1} / ${_vocabs.length}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    // Thanh kết quả ở dưới cùng
                    if (_isLastAnswerCorrect != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                        color: _isLastAnswerCorrect! ? Colors.green.shade500 : Colors.red.shade500,
                        child: Text(
                          _feedbackMessage ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required int count,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 6),
          Text(
            '$count $label',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
