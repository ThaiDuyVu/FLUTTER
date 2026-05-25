import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/todo_task.dart';

class TaskStorage {
  Future<String> get _path async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<File> get _file async {
    final path = await _path;
    return File('$path/homework_tasks.txt');
  }

  Future<void> saveTasks(List<TodoTask> tasks) async {
    final file = await _file;
    String data = tasks.map((e) => e.toFileString()).join("\n");
    await file.writeAsString(data);
  }

  Future<List<TodoTask>> loadTasks() async {
    try {
      final file = await _file;
      final content = await file.readAsString();
      return content
          .split("\n")
          .where((e) => e.isNotEmpty)
          .map((e) => TodoTask.fromString(e))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> addTask(TodoTask task) async {
    final tasks = await loadTasks();
    tasks.add(task);
    await saveTasks(tasks);
  }

  Future<void> updateTask(TodoTask updatedTask) async {
    final tasks = await loadTasks();
    final index = tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      tasks[index] = updatedTask;
      await saveTasks(tasks);
    }
  }
}
