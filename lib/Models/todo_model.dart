class TodoModel {
  String title;
  String description;
  bool isCompleted;
  int id;
  DateTime startDate;
  DateTime endDate;
  DateTime createdAtTime;
  bool isSpecificTimeRemainder;
  int? reminderHour;
  int? reminderMinute;

  TodoModel({
    required this.title,
    required this.description,
    this.isCompleted = false,
    required this.id,
    required this.startDate,
    required this.endDate,
    required this.createdAtTime,
    this.isSpecificTimeRemainder = false,
    this.reminderHour,
    this.reminderMinute
  });
}
