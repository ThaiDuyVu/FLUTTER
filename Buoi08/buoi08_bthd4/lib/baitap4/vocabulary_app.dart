import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/learn_screen.dart';
import 'screens/quiz_screen.dart';
import 'screens/reminder_screen.dart';

class VocabularyApp extends StatefulWidget {
  const VocabularyApp({Key? key}) : super(key: key);

  @override
  State<VocabularyApp> createState() => _VocabularyAppState();
}

class _VocabularyAppState extends State<VocabularyApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ứng dụng học từ vựng'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'Trở về danh sách bài tập',
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
          )
        ],
      ),
      drawer: Drawer(
        child: Column(
          children: [
            // Drawer Header
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.school,
                  size: 40,
                  color: Colors.blue,
                ),
              ),
              accountName: const Text(
                'Trợ lý học từ vựng',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: null,
            ),

            // Menu items
            ListTile(
              leading: const Icon(Icons.home, color: Colors.blue),
              title: const Text('Trang chính'),
              onTap: () {
                Navigator.pop(context); // Đóng drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.menu_book, color: Colors.blue),
              title: const Text('Học từ'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LearnScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.quiz, color: Colors.blue),
              title: const Text('Kiểm tra từ'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const QuizScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.notifications,
                color: Colors.blue,
              ),
              title: const Text('Lịch nhắc'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReminderScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: const HomeScreen(),
    );
  }
}
