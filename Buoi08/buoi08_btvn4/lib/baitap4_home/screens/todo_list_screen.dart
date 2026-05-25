import 'package:flutter/material.dart';
import '../models/todo_task.dart';
import '../services/task_storage.dart';
import '../../services/notification_service.dart';
import 'add_task_screen.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({Key? key}) : super(key: key);

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final TaskStorage _storage = TaskStorage();
  List<TodoTask> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() async {
    final tasks = await _storage.loadTasks();
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  void _confirmCompletion(TodoTask task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc chắn nhiệm vụ này đã hoàn thành?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              // Cập nhật trạng thái
              task.isCompleted = true;
              await _storage.updateTask(task);

              // Cập nhật giao diện
              setState(() {});

              // Đếm số nhiệm vụ hoàn thành
              final completedCount = _tasks.where((t) => t.isCompleted).length;

              try {
                // Hiện thông báo hệ thống
                await NotificationService().showCustomNotification(
                  id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                  title: 'Nhiệm vụ hoàn thành',
                  body: 'Bạn đã hoàn thành $completedCount nhiệm vụ!',
                );
              } catch (e) {
                debugPrint('Lỗi notification: $e');
              }
            },
            child: const Text('Có'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Nhiệm vụ mỗi ngày',
            style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            tooltip: 'Trở về danh sách bài tập',
            onPressed: () {
              Navigator.of(context, rootNavigator: true).pop();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
              ? const Center(
                  child: Text('Chưa có nhiệm vụ nào',
                      style: TextStyle(color: Colors.grey)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) {
                    final task = _tasks[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        leading: Checkbox(
                          value: task.isCompleted,
                          onChanged: task.isCompleted
                              ? null // Vô hiệu hóa nếu đã hoàn thành
                              : (value) {
                                  if (value == true) {
                                    _confirmCompletion(task);
                                  }
                                },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color:
                                task.isCompleted ? Colors.grey : Colors.black87,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Nhắc lúc ${task.time}',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.notifications_none,
                            color:
                                task.isCompleted ? Colors.grey : Colors.black54,
                          ),
                          onPressed: () {
                            // Click biểu tượng notification để thiết lập thời gian (nếu cần)
                          },
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskScreen()),
          );
          if (result == true) {
            _loadTasks(); // Tải lại danh sách nếu có thêm mới
          }
        },
        backgroundColor: Colors.blue.shade100,
        foregroundColor: Colors.blue.shade900,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
