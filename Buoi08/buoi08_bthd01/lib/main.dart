import 'package:flutter/material.dart';

import 'package:buoi08_bthd01/services/NotificationService.dart';
import 'package:buoi08_bthd01/views/scren_noti_ex.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final notificationService = NotificationService();

  await notificationService.init();

  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),

      home: const ScreenNotiEx(),
    );
  }
}