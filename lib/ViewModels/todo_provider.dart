import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../Models/todo_model.dart';
import 'manage_notification_provider.dart';

class TodoProvider extends ChangeNotifier {
  final Box<TodoModel> _todoBox = Hive.box<TodoModel>('todoBox');
  final Box<bool> _hiveWorkMng = Hive.box<bool>('workManagerTasks');
  final notificationProv = ManageNotificationProvider();
  List<TodoModel> _completedTask = <TodoModel>[];
  String _titleError = "";
  String _startError = "";
  String _descriptionError = "";
  int _tabIndex = 0;
  int _taskIndex = 0;
  bool isDarkMode = false;
  bool _navigatingToSettings = true;

  int get taskIndex => (_taskIndex += 1);
  int get tabIndex => _tabIndex;
  String get titleError => _titleError;
  String get startError => _startError;
  String get descriptionError => _descriptionError;
  List<TodoModel> get completedTask => _completedTask;
  ThemeMode get currentTheme => isDarkMode ? ThemeMode.dark : ThemeMode.light;
  bool get navigatingToSettings => _navigatingToSettings;

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners(); // Notify listeners to rebuild the UI with the new theme
  }

  // Initialize the last ID by checking the existing tasks
  TodoProvider() {
    setCompletedTask();
    _initializeLastId();
  }

  void _initializeLastId() {
    if (_todoBox.isNotEmpty) {
      // Assuming ids are stored in the task model
      _taskIndex = _todoBox.values
          .map((todo) => todo.id)
          .reduce((value, element) => value > element ? value : element);
    } else {
      _taskIndex = 0; // No tasks, start from 0
    }
  }

  void resetTasks() {
    _completedTask.clear();
    _todoBox.clear(); // Clears all tasks from the box
    _taskIndex = 0; // Resets the ID counter
    notifyListeners(); // Notify listeners to update the UI
  }

  void setIndex(int index) {
    _tabIndex = index;
    notifyListeners();
  }

  void setTitleError(String msg) {
    _titleError = msg;
    notifyListeners();
  }

  void setDescriptionError(String msg) {
    _descriptionError = msg;
    notifyListeners();
  }

  void setStartError(String msg) {
    _startError = msg;
    notifyListeners();
  }

  void setCompletedTask() {
    _completedTask = _todoBox.values.where((todo) => todo.isCompleted).toList();
    notifyListeners();
  }

  void openSetting(bool flag) {
    _navigatingToSettings = flag;
  }

  //Let's do CRUD operation
  void addTodo(TodoModel todo) {
    _todoBox.add(todo);
  }

  List<TodoModel> getTodos() {
    return _todoBox.values
        .where((todo) => (todo.isCompleted == false))
        .toList();
  }

  void updateTodo(int id, TodoModel updatedTodo) {
    int index = 0;
    _todoBox.values.firstWhere((todo) {
      if (todo.id == id) {
        return true;
      } else {
        index++;
      }
      return false;
    });
    _todoBox.putAt(index, updatedTodo);
    setCompletedTask();
  }

  void deleteTodo(int id) {
    int index = 0;
    _todoBox.values.firstWhere((todo) {
      if (todo.id == id) {
        return true;
      } else {
        index++;
      }
      return false;
    });
    _todoBox.deleteAt(index);
    setCompletedTask();
  }

  void flagBgTaskInitialize() {
    bool? isInitialize = _hiveWorkMng.get('workManagerInitialize');
    if (isInitialize == null || !isInitialize) {
      notificationProv.initBackground();
      _hiveWorkMng.put('workManagerInitialize', true);
    }
  }

  void cancelWorkManagerTasks() {
    bool? isInitialize = _hiveWorkMng.get('workManagerInitialize');
    if (isInitialize != null && isInitialize) {
      notificationProv.destroyManagerTask();
      _hiveWorkMng.put('workManagerInitialize', false);
    }
  }
}
