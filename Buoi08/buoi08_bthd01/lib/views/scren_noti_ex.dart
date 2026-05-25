import 'package:flutter/material.dart';
import 'package:buoi08_bthd01/services/NotificationService.dart';

class ScreenNotiEx extends StatelessWidget {
  const ScreenNotiEx({super.key});

  @override
  Widget build(BuildContext context) {
    NotificationService notificationService =
        NotificationService();

    notificationService.init();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Screen Noti Example"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Nút gửi thông báo ngay
            ElevatedButton(
              onPressed: () {
                notificationService.showSimpleNotification();
              },
              child: const Text(
                "Gửi thông báo nhắc học Ngoại ngữ",
              ),
            ),

            const SizedBox(height: 20),

            // Nút hẹn giờ uống nước
            ElevatedButton(
              onPressed: () {
                notificationService.scheduleNotificationAfter(
                  const Duration(minutes: 2),
                  'drink_water_channel',
                  'Uống nước',
                  'Nhắc uống nước đúng giờ',
                );
              },
              child: const Text(
                "Gửi thông báo nhắc uống nước sau 2 phút",
              ),
            ),

            const SizedBox(height: 20),

            // Nút hẹn giờ học ngoại ngữ
            ElevatedButton(
              onPressed: () {
                notificationService.scheduleNotificationAfter(
                  const Duration(minutes: 10),
                  'learn_english_channel',
                  'Học Ngoại ngữ',
                  'Đến giờ học từ vựng rồi!',
                );
              },
              child: const Text(
                "Hẹn giờ gửi thông báo học Ngoại ngữ sau 10 phút",
              ),
            ),
          ],
        ),
      ),
    );
  }
}