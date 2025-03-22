import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:todo_task/Utils/helpers/dynamic_context_widgets.dart';
import 'package:todo_task/ViewModels/setting_provider.dart';

import '../Models/todo_model.dart';
import '../Service/initialization_service.dart';
import '../Service/push_notification_service.dart';
import '../Utils/constants/app_constants.dart';

class TodoProvider extends ChangeNotifier {
  final Box<TodoModel> _todoBox = Hive.box<TodoModel>('todoBox');
  final notificationService = PushNotificationsService();
  final initService = InitializationService();
  late SettingsProvider _setProv;
  late DateTime _taskTime;
  late DateTime _taskStartDate;
  late DateTime _taskEndDate;

  List<TodoModel> _completedTask = <TodoModel>[];
  String _titleError = "";
  String _descriptionError = "";
  int _tabIndex = 0;
  int _taskIndex = 0;

  int get taskIndex => _taskIndex;
  int get tabIndex => _tabIndex;
  String get titleError => _titleError;
  String get descriptionError => _descriptionError;
  List<TodoModel> get completedTask => _completedTask;
  DateTime get taskTime => _taskTime;
  DateTime get taskStartDate => _taskStartDate;
  DateTime get taskEndDate => _taskEndDate;

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

  void setCompletedTask() {
    _completedTask = _todoBox.values.where((todo) => todo.isCompleted).toList();
    notifyListeners();
  }

  //Let's do CRUD operation
  void addTodo(TodoModel todo) {
    _todoBox.add(todo);
    _taskIndex = todo.id;
    notificationService.showLocalTaskNotification(todo: todo);
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

  Future<void> checkAndRequestPermissions(SettingsProvider prov) async {
    _setProv = prov;
    Box<bool> permissionBox =
        Hive.box<bool>(HiveDatabaseConstants.permissionHive);
    bool? isAllow = permissionBox.get(HiveDatabaseConstants.permissionHiveAsk);
    if (isAllow == null || !isAllow) {
      await askPermissions();
      permissionBox.put(HiveDatabaseConstants.permissionHiveAsk, true);
    }
  }

  Future<void> askPermissions() async {
    try {
      await notificationPermission();
      await batteryRestriction();
    } catch (e) {
      DynamicContextWidgets().showSnackbar('Error in askPermissions: $e');
    }
  }

  Future<void> notificationPermission() async {
    bool notificationPermissionGranted =
        await notificationService.requestNotificationPermissions();

    if (notificationPermissionGranted) {
      _setProv.checkNotificationStatus();
    } else {
      await _performDeniedNotificationAction();
    }
  }

  Future<void> _performDeniedNotificationAction() async {
    // Add any awaitable operations here
    await DynamicContextWidgets().bottomSheet(
        title: "Permission Denied",
        msg:
            "Allow the notification permission to receive the notification from our side",
        icon: Icons.notification_add,
        btnText: "Enable",
        pressed: () async => await AppSettings.openAppSettings(
            type: AppSettingsType.notification).whenComplete((){
              notificationStatus();
        })); //Example awaitable operation
  }

  Future<void> batteryRestriction() async {
    var status = await Permission.ignoreBatteryOptimizations.status;
    if (status.isGranted) {
      initService.initializeWorkManagerTasks();
    } else if ((status.isDenied || status.isPermanentlyDenied)) {
      // Handle case where user denied permission
      DynamicContextWidgets().bottomSheet(
          title: "Battery Saver",
          msg:
              "Get daily local schedule notification by turn off the battery restriction.",
          icon: Icons.battery_saver,
          btnText: "Turn Off",
          pressed: () async => await Permission.ignoreBatteryOptimizations
                  .request()
                  .whenComplete(() {
                batteryStatus();
              }));
    }
  }

  Future<void> batteryStatus() async {
    Future.delayed(const Duration(seconds: 3), () async {
        _setProv.checkBatteryOptimizationStatus();
    });
  }

  Future<void> notificationStatus() async {
    Future.delayed(const Duration(seconds: 3), () async {
        _setProv.checkNotificationStatus();
    });
  }

  double indicatorValue() {
    int leftTask = getTodos().length;
    int doneTask = completedTask.length;
    if ((leftTask + doneTask) == 0) {
      return 0;
    }
    return doneTask / (leftTask + doneTask);
  }

  void setDateTime(TodoModel? todo) {
    _taskStartDate = todo?.startDate ?? DateTime.now();
    _taskTime = todo?.createdAtTime ?? DateTime.now();
    _taskEndDate = todo?.endDate ?? DateTime.now();
  }

  void changeTime(DateTime selectedTime) {
    _taskTime = selectedTime;
    notifyListeners();
  }

  void changeStartDate(DateTime selectedDate) {
    _taskStartDate = selectedDate;
    notifyListeners();
  }

  void changeEndDate(DateTime selectedDate) {
    _taskEndDate = selectedDate;
    notifyListeners();
  }

  void deleteTaskMsg() {
    (getTodos().length + completedTask.length == 0)
        ? DynamicContextWidgets().deleteAlertMsg()
        : DynamicContextWidgets().deleteAllTask((bool delete) {
            if (delete) {
              resetTasks();
            }
          });
  }
}
