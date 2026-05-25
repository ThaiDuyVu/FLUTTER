import 'dart:async';
import 'package:flutter/material.dart';

/// Model chứa thông tin 1 thông báo
class NotificationEvent {
  final String title;
  final String body;
  final DateTime time;

  NotificationEvent({
    required this.title,
    required this.body,
  }) : time = DateTime.now();
}

/// Service phát sóng các sự kiện thông báo đến overlay widget
class NotificationOverlayService {
  static final StreamController<NotificationEvent> _controller =
      StreamController<NotificationEvent>.broadcast();

  static Stream<NotificationEvent> get stream => _controller.stream;

  /// Gửi một thông báo để hiển thị overlay
  static void show({required String title, required String body}) {
    _controller.add(NotificationEvent(title: title, body: body));
  }

  static void dispose() {
    _controller.close();
  }
}

/// Widget bọc toàn bộ app - lắng nghe stream và hiển thị thông báo overlay
class NotificationOverlayWrapper extends StatefulWidget {
  final Widget child;
  const NotificationOverlayWrapper({Key? key, required this.child})
      : super(key: key);

  @override
  State<NotificationOverlayWrapper> createState() =>
      _NotificationOverlayWrapperState();
}

class _NotificationOverlayWrapperState
    extends State<NotificationOverlayWrapper> {
  final List<NotificationEvent> _activeNotifications = [];
  StreamSubscription<NotificationEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = NotificationOverlayService.stream.listen((event) {
      if (mounted) {
        setState(() {
          _activeNotifications.add(event);
        });
        // Tự xóa sau 4 giây
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) {
            setState(() {
              _activeNotifications.remove(event);
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // Lớp overlay thông báo - hiện ở trên cùng
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            child: Column(
              children: _activeNotifications
                  .map((n) => _NotificationBanner(
                        key: ValueKey(n.time),
                        event: n,
                        onDismiss: () {
                          if (mounted) {
                            setState(() {
                              _activeNotifications.remove(n);
                            });
                          }
                        },
                      ))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

/// Widget thông báo riêng lẻ - có animation trượt xuống từ trên
class _NotificationBanner extends StatefulWidget {
  final NotificationEvent event;
  final VoidCallback onDismiss;

  const _NotificationBanner({
    Key? key,
    required this.event,
    required this.onDismiss,
  }) : super(key: key);

  @override
  State<_NotificationBanner> createState() => _NotificationBannerState();
}

class _NotificationBannerState extends State<_NotificationBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: GestureDetector(
          onTap: widget.onDismiss,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              // Giả lập màu nền notification Android
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(51),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon app
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade600,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.notifications,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Nội dung
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header: tên app + thời gian + dấu chấm
                        Row(
                          children: [
                            const Text(
                              'flutter_app',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Text(
                              ' · ',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey),
                            ),
                            Text(
                              _formatTime(widget.event.time),
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey),
                            ),
                            const Spacer(),
                            const Icon(Icons.expand_more,
                                size: 18, color: Colors.grey),
                          ],
                        ),
                        const SizedBox(height: 2),
                        // Tiêu đề
                        Text(
                          widget.event.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        // Nội dung
                        Text(
                          widget.event.body,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
