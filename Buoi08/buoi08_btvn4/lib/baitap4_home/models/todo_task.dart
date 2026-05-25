class TodoTask {
  String id;
  String title;
  String time;
  bool isCompleted;

  TodoTask({
    required this.id,
    required this.title,
    required this.time,
    this.isCompleted = false,
  });

  String toFileString() {
    return "$id|$title|$time|$isCompleted";
  }

  static TodoTask fromString(String line) {
    final parts = line.split("|");
    return TodoTask(
      id: parts[0],
      title: parts[1],
      time: parts[2],
      isCompleted: parts[3] == 'true',
    );
  }
}
