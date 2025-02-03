import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:todo_task/Models/todo_model.dart';
import 'package:timezone/timezone.dart' as tz;

class PushNotifications {
  static final _notificationPlugin = FlutterLocalNotificationsPlugin();

  void init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
            '@mipmap/ic_launcher'); // Your notification icon
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _notificationPlugin
        .initialize(initializationSettings); // Initialize notification plugin.
  }

  NotificationDetails androidDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'task_channel', // Channel ID for grouping notifications.
        'Task Notification', // Channel name.
        channelDescription: 'Task Alert', // Channel description.
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
        showProgress: false,
        playSound: true,
      ),
    );
  }

  void showNotification({required TodoModel todo}) async {
    await _notificationPlugin.show(
      todo.id, // Unique ID for notification.
      todo.title, // Title of the notification.
      todo.description, // Content of the notification.
      androidDetails(),
    );
  }

  Future<void> scheduleNotification(
      {required bool show, required int id}) async {
    final location = tz.getLocation('Asia/Kolkata');
    final now = tz.TZDateTime.now(location);
    tz.TZDateTime scheduledDate = tz.TZDateTime(location, now.year, now.month,
        now.day, now.hour, (now.minute + 1), now.second);
    if (id == 1 && show == false) {
      _notificationPlugin.cancel(1);
    } else {
      await _notificationPlugin.zonedSchedule(
          id, // Unique ID for scheduling.
          (id == 0)
              ? (show)
              ? 'Daily Reminder'
              : 'Organize Today'
              : "Task Pending",
          (id == 0)
              ? (show)
              ? 'Check your tasks for today!'
              : 'Start today fresh. Set new tasks to stay organized!'
              : 'Last day of today pending tasks',
          scheduledDate,
          androidDetails(),
          matchDateTimeComponents:
              DateTimeComponents.time, // Repeat daily at this time
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle);
    }
  }
}
