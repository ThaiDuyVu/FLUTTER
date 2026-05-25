import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'notification_overlay.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Kiểm tra có phải Android không
  bool get _isAndroid => !kIsWeb && Platform.isAndroid;

  Future<void> init() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();

    if (_isAndroid) {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const settings = InitializationSettings(android: androidSettings);
      await _plugin.initialize(settings);

      // Yêu cầu quyền notification (Android 13+)
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

    _initialized = true;
  }

  /// Tạo AndroidNotificationDetails dùng lại nhiều lần (theo Lab8)
  static AndroidNotificationDetails _createAndroidDetails({
    required String channelId,
    required String channelName,
    String? channelDescription,
  }) {
    return AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      visibility: NotificationVisibility.public,
      playSound: true,
      enableVibration: true,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );
  }

  /// Phương thức hẹn lịch hiển thị thông báo (theo Lab8)
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required AndroidNotificationDetails androidDetails,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // =====================================================
  // CÁC HÀM THEO LAB8
  // =====================================================

  /// Hàm gửi thông báo tức thì (theo Lab8)
  Future<void> showSimpleNotification({
    int id = 0,
    String title = 'Nhắc học từ vựng',
    String body = 'Bạn đã học 5 từ mới hôm nay chưa?',
  }) async {
    if (_isAndroid) {
      final details = NotificationService._createAndroidDetails(
        channelId: 'learn_english_channel',
        channelName: 'Học Anh Văn',
      );
      await _plugin.show(id, title, body, NotificationDetails(android: details));
    } else {
      // Windows/Web: dùng overlay
      NotificationOverlayService.show(title: title, body: body);
    }
  }

  /// Đặt lịch sau 1 khoảng thời gian delay (theo Lab8)
  Future<void> scheduleNotificationAfter(Duration delay, String channelId,
      String channelName, String channelDescription) async {
    if (_isAndroid) {
      final details = NotificationService._createAndroidDetails(
        channelId: channelId,
        channelName: channelName,
        channelDescription: channelDescription,
      );
      final scheduledTime = tz.TZDateTime.now(tz.local).add(delay);
      await _scheduleNotification(
        id: 1,
        title: channelName,
        body: channelDescription,
        scheduledTime: scheduledTime,
        androidDetails: details,
      );
    } else {
      // Windows/Web: dùng Timer để delay rồi show overlay
      Timer(delay, () {
        NotificationOverlayService.show(
          title: channelName,
          body: channelDescription,
        );
      });
    }
  }

  // =====================================================
  // CÁC HÀM MỞ RỘNG CHO BÀI TẬP 3 VÀ 4
  // =====================================================

  /// Hiển thị thông báo tùy chỉnh ngay lập tức
  Future<void> showCustomNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    if (_isAndroid) {
      final details = NotificationService._createAndroidDetails(
        channelId: 'custom_channel',
        channelName: 'Thông báo chung',
      );
      await _plugin.show(id, title, body, NotificationDetails(android: details));
    } else {
      NotificationOverlayService.show(title: title, body: body);
    }
  }

  /// Lên lịch thông báo tùy chỉnh theo thời gian cụ thể
  Future<void> scheduleCustomNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    if (_isAndroid) {
      final details = NotificationService._createAndroidDetails(
        channelId: 'custom_schedule_channel',
        channelName: 'Lịch nhắc chung',
      );
      await _scheduleNotification(
        id: id,
        title: title,
        body: body,
        scheduledTime: scheduledTime,
        androidDetails: details,
      );
    } else {
      // Windows/Web: dùng Timer
      final delay = scheduledTime.difference(DateTime.now());
      if (delay.isNegative) {
        // Thời gian đã qua → hiện ngay
        NotificationOverlayService.show(title: title, body: body);
      } else {
        Timer(delay, () {
          NotificationOverlayService.show(title: title, body: body);
        });
      }
    }
  }

  /// Hủy một notification theo id (chỉ áp dụng trên Android)
  Future<void> cancelNotification(int id) async {
    if (_isAndroid) {
      await _plugin.cancel(id);
    }
    // Windows/Web không cần cancel vì timer tự hết
  }

  /// Hủy tất cả notification
  Future<void> cancelAll() async {
    if (_isAndroid) {
      await _plugin.cancelAll();
    }
  }
}
