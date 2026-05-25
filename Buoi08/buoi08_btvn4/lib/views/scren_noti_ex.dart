import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class ScreenNotiEx extends StatelessWidget {
  const ScreenNotiEx({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    NotificationService notificatiosnservice = NotificationService();
    notificatiosnservice.init();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Screen Noti Example"),
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //nut lenh len lich notification
            ElevatedButton(
              onPressed: () {
                notificatiosnservice.showSimpleNotification();
              },
              child: const Text("Gửi thông báo nhắc học Ngoại ngữ"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                notificatiosnservice.scheduleNotificationAfter(
                  const Duration(minutes: 2),
                  'drink_water_channel',
                  'Uống nước',
                  'Nhắc uống nước đúng giờ',
                );
              },
              child: const Text("Gửi thông báo nhắc uống nước sau 2 phút"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Sinh viên tự viết code để đặt lịch gửi thông báo nhắc học Ngoại ngữ sau 10 phút
                notificatiosnservice.scheduleNotificationAfter(
                  const Duration(minutes: 10),
                  'learn_english_channel',
                  'Học Anh Văn',
                  'Đã đến lúc học tiếng Anh rồi!',
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã hẹn giờ nhắc sau 10 phút!')),
                );
              },
              child: const Text("Hẹn giờ gửi thông báo học Ngoại ngữ sau 10 phút"),
            ),
          ],
        ),
      ),
    );
  }
}
