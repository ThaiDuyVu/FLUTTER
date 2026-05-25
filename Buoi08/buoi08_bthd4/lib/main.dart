import 'package:flutter/material.dart';
import 'services/notification_service.dart';
import 'services/notification_overlay.dart';
import 'baitap4/vocabulary_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final notificationService = NotificationService();
  await notificationService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bài Tập Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),

      // Giữ overlay notification nếu app bạn đang dùng
      builder: (context, child) {
        return NotificationOverlayWrapper(child: child!);
      },

      // ✅ CHỈ MỞ BÀI TẬP 4
      home: const VocabularyApp(),
    );
  }
}