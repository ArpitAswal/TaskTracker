
class TodoModel {
  String title;
  String description;
  bool isCompleted;
  int id;
  String startDate;
  String endDate;

  TodoModel({
    required this.title,
    required this.description,
    this.isCompleted = false,
    required this.id,
    required this.startDate,
    required this.endDate,
  });
}
