import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../Models/todo_model.dart';
import 'package:timezone/timezone.dart' as tz;

import '../Utils/constants/app_constants.dart';

class PushNotificationsService {
  factory PushNotificationsService() => _instance;

  PushNotificationsService._internal();

  static final PushNotificationsService _instance =
      PushNotificationsService._internal();

  final _messaging = FirebaseMessaging.instance;
  final _notificationPlugin = FlutterLocalNotificationsPlugin();

  void initLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings(
            '@mipmap/ic_launcher'); // Your notification icon
    const DarwinInitializationSettings iOSInitializationSettings =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: iOSInitializationSettings);
    await _notificationPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        debugPrint("🔥 Notification Clicked: ${response.payload}");
      },
    );
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint(
          "🔥 Foreground Message Received: ${message.notification?.title}");
      showFirebaseNotification(message);
    }); // Initialize notification plugin.
  }

  AndroidNotificationChannel makeChannel(RemoteMessage? message) {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      message?.notification?.android?.channelId ??
          NotificationConstants.channelId,
      message?.notification?.title ?? NotificationConstants.channelName,
      description: NotificationConstants.channelDescription,
      importance: Importance.high,
      showBadge: true,
      playSound: true,
    );
    return channel;
  }

  NotificationDetails notificationDetails(
      {AndroidNotificationChannel? channel}) {
    return NotificationDetails(
        android: AndroidNotificationDetails(
          channel?.id ??
              NotificationConstants
                  .channelId, // Channel ID for grouping notifications.
          channel?.name ?? NotificationConstants.channelName, // Channel name.
          channelDescription:
              NotificationConstants.channelDescription, // Channel description.
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
          showProgress: true,
          playSound: true,
          silent: false
        ),
        iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            presentBanner: true));
  }

  Future<void> showLocalTaskNotification({required TodoModel todo}) async {
    AndroidNotificationChannel channel = makeChannel(null);
    await _notificationPlugin.show(
      todo.id, // Unique ID for notification.
      todo.title, // Title of the notification.
      todo.description, // Content of the notification.
      notificationDetails(channel: channel),
    );
  }

  // function to show visible notification when app is active
  Future<void> showFirebaseNotification(RemoteMessage message) async {
    AndroidNotificationChannel channel = makeChannel(message);

    await _notificationPlugin.show(
      message.hashCode, // Unique ID for the notification
      message.notification!.title.toString(),
      message.notification!.body.toString(),
      notificationDetails(channel: channel),
    );
  }

  Future<bool> requestNotificationPermissions() async {
    NotificationSettings settings = await _messaging.requestPermission(
      // On Android, a [NotificationSettings] class will be returned with the value of [NotificationSettings.authorizationStatus] indicating whether the app has notifications enabled or blocked in the system settings.
      alert: true, // Enable alert notifications.
      announcement: true, // Enable announcement notifications.
      badge: true, // Enable badge notifications.
      carPlay: true, // Enable CarPlay notifications.
      criticalAlert: true, // Enable critical alert notifications.
      provisional: true, // Enable provisional notifications.
      sound: true, // Enable sound notifications.
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> scheduleNotification() async {
    final location = tz.getLocation('Asia/Kolkata');
    final now = tz.TZDateTime.now(location);
    tz.TZDateTime scheduledDate = tz.TZDateTime(location, now.year, now.month,
        now.day, now.hour, now.minute, (now.second + 10));
    AndroidNotificationChannel channel = makeChannel(null);

    await _notificationPlugin.zonedSchedule(
        scheduledDate.microsecond, // Unique ID for scheduling.
        NotificationConstants.newFreshTitle,
        NotificationConstants.newFreshBody,
        scheduledDate,
        notificationDetails(channel: channel),
        matchDateTimeComponents:
            DateTimeComponents.time, // Repeat daily at this time
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle);
  }

  showCustomNotification(
      {required int id, required String title, required String body}) async {
    AndroidNotificationChannel channel = makeChannel(null);

    await _notificationPlugin.show(
      id, // Unique ID for the notification
      title.toString(),
      body.toString(),
      notificationDetails(channel: channel),
    );
  }
}
