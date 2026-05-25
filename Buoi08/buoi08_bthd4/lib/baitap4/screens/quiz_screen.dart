import 'dart:math';
import 'package:flutter/material.dart';
import '../models/vocabulary.dart';
import '../services/vocabulary_storage.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final VocabularyStorage _storage = VocabularyStorage();
  final Random _random = Random();

  List<Vocabulary> _vocabs = [];
  int _currentIndex = 0;
  int _correctCount = 0;
  int _wrongCount = 0;
  bool _isLoading = true;

  // Đáp án hiển thị hiện tại (có thể đúng hoặc sai ngẫu nhiên)
  String _displayedMeaning = '';
  bool _isDisplayedCorrect = true;

  @override
  void initState() {
    super.initState();
    _loadVocabularies();
  }

  void _loadVocabularies() async {
    final vocabs = await _storage.loadVocabularies();
    setState(() {
      _vocabs = vocabs;
      _isLoading = false;
      if (_vocabs.isNotEmpty) {
        _generateQuestion();
      }
    });
  }

  void _generateQuestion() {
    if (_currentIndex >= _vocabs.length) return;

    // Ngẫu nhiên hiển thị đáp án đúng hoặc sai
    _isDisplayedCorrect = _random.nextBool();

    if (_isDisplayedCorrect || _vocabs.length <= 1) {
      // Hiển thị đáp án đúng
      _displayedMeaning = _vocabs[_currentIndex].meaning;
    } else {
      // Hiển thị đáp án sai (lấy nghĩa của từ khác)
      int randomIndex;
      do {
        randomIndex = _random.nextInt(_vocabs.length);
      } while (randomIndex == _currentIndex);
      _displayedMeaning = _vocabs[randomIndex].meaning;
    }
  }

  void _answer(bool userSaidCorrect) {
    if (_currentIndex >= _vocabs.length) return;

    bool isUserCorrect = (userSaidCorrect == _isDisplayedCorrect);

    setState(() {
      if (isUserCorrect) {
        _correctCount++;
      } else {
        _wrongCount++;
      }

      _currentIndex++;

      if (_currentIndex >= _vocabs.length) {
        // Hoàn thành
        _showResultDialog();
      } else {
        _generateQuestion();
      }
    });
  }

  void _showResultDialog() {
    final total = _correctCount + _wrongCount;
    final percentage =
        total > 0 ? (_correctCount / total * 100).toStringAsFixed(1) : '0';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: Colors.grey.shade800,
        title: const Text(
          'Kết thúc bài kiểm tra',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tổng số câu: $total',
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              '✅ Đúng: $_correctCount',
              style: const TextStyle(color: Colors.green, fontSize: 15),
            ),
            Text(
              '❌ Sai: $_wrongCount',
              style: const TextStyle(color: Colors.red, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              'Tỉ lệ đúng: $percentage%',
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentIndex = 0;
                _correctCount = 0;
                _wrongCount = 0;
                _generateQuestion();
              });
            },
            child: const Text(
              'Làm lại',
              style: TextStyle(color: Colors.blue),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              'Thoát',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trắc nghiệm Đúng / Sai'),
        centerTitle: true,
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
              : _currentIndex >= _vocabs.length
                  ? const Center(
                      child: Text('Đã hoàn thành!'),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          // Badges đúng / sai
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildBadge(
                                icon: Icons.check,
                                label: 'Đúng: $_correctCount',
                                color: Colors.green.shade500,
                              ),
                              const SizedBox(width: 16),
                              _buildBadge(
                                icon: Icons.close,
                                label: 'Sai: $_wrongCount',
                                color: Colors.orange.shade500,
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),

                          // Card hiển thị từ + đáp án
                          Column(
                            children: [
                              Text(
                                _vocabs[_currentIndex].word,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _displayedMeaning,
                                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),

                          // 2 nút Đúng / Sai
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () => _answer(true),
                                icon: const Icon(Icons.check),
                                label: const Text('Đúng'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green.shade500,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 30,
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              ElevatedButton.icon(
                                onPressed: () => _answer(false),
                                icon: const Icon(Icons.close),
                                label: const Text('Sai'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade500,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 30,
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Câu ${_currentIndex + 1} / ${_vocabs.length}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildBadge({required IconData icon, required String label, required Color color}) {
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
            label,
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
