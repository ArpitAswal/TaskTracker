import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_task/NetworkRequests/node_server_repository.dart';
import 'package:todo_task/Utils/helpers/dynamic_context_widgets.dart';
import 'package:todo_task/Service/manage_notification_service.dart';

import '../Adapters/authenticate_adapter.dart';
import '../Adapters/todo_adapter.dart';
import '../Models/auth_model.dart';
import '../Models/todo_model.dart';
import '../Utils/constants/app_constants.dart';
import 'push_notification_service.dart';

class InitializationService {
  static final InitializationService _instance =
      InitializationService._internal();
  factory InitializationService() => _instance;
  InitializationService._internal();

  final PushNotificationsService _pushNotifications =
      PushNotificationsService();
  final ManageNotificationService _notProv = ManageNotificationService();
  final NodeServerRepository _requests = NodeServerRepository();
  final _messaging = FirebaseMessaging.instance;
  final firestoreInst = FirebaseFirestore.instance;

  // Essential initialization that must happen immediately
  Future<void> initializeEssentials() async {
    // Initialize Hive (required for app to function)
    await Hive.initFlutter();
    Hive.registerAdapter(TodoAdapter());
    Hive.registerAdapter(AuthenticateAdapter());
    await Hive.openBox<TodoModel>(HiveDatabaseConstants.todoHive);
    // await Hive.openBox<TodoModel>(HiveDatabaseConstants.specificTodoHive);
    await Hive.openBox<bool>(HiveDatabaseConstants.managerHive);
    await Hive.openBox<bool>(HiveDatabaseConstants.permissionHive);
    await Hive.openBox<AuthenticateModel>(HiveDatabaseConstants.authHive);
    await Hive.openBox<bool>(HiveDatabaseConstants.themeHive);
    await Hive.openBox<int>(HiveDatabaseConstants.managerFrequency);

    // Initialize local notifications (basic setup only)
    _pushNotifications.initLocalNotifications();
    // Initialize Firebase Messaging
    _initializeFirebaseMessaging();
  }

  // Deferred initialization that can happen after app is visible
  Future<void> initializeDeferred({required bool status}) async {
    // Wrap in microtask to avoid blocking the UI
    Future.microtask(() async {
      // save the device token
      _saveDeviceToken(token: await _messaging.getToken(), status: status);
    });
  }

  Future<void> _initializeFirebaseMessaging() async {
    // Foreground Notifications, when the app is running on device
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (Platform.isIOS) {
        await _messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      } else if (Platform.isAndroid) {
        _pushNotifications.showFirebaseNotification(message);
      }
    });

    // when we comes to an app from clicking on notification
    FirebaseMessaging.onMessageOpenedApp
        .listen((RemoteMessage message) async {});
  }

  void initializeWorkManagerTasks() {
    Box<bool> hiveBox = Hive.box<bool>(HiveDatabaseConstants.managerHive);
    bool? isInitialize = hiveBox.get(HiveDatabaseConstants.managerInitialize);
    if (isInitialize == null || !isInitialize) {
      _notProv.initBackground();
      Box<TodoModel> taskList =
          Hive.box<TodoModel>(HiveDatabaseConstants.todoHive);
      for (var task in taskList.values.toList()) {
        if (task.isSpecificTimeRemainder) {
          _notProv.specificRemainderTask(task.reminderHour!);
        }
      }
      hiveBox.put(HiveDatabaseConstants.managerInitialize, true);
    }
  }

  void cancelWorkManagerTasks() {
    Box<bool> hiveBox = Hive.box<bool>(HiveDatabaseConstants.managerHive);
    bool? isInitialize = hiveBox.get(HiveDatabaseConstants.managerInitialize);
    if (isInitialize != null && isInitialize) {
      _notProv.destroyManagerTask();
      hiveBox.put(HiveDatabaseConstants.managerInitialize, false);
    }
  }

  Future<void> _saveDeviceToken(
      {required String? token, required bool status}) async {
    final snackbar = DynamicContextWidgets();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    final isTokenSave = await firestoreToken(userId);
    if (token != null && !isTokenSave && status && userId != null) {
      await firestoreInst
          .collection(FirestoreConstants.tokenCollection)
          .doc(userId)
          .set({"token": token});
      String response = await _requests.storeTokenToBackend(token);
      if (response != "Success") {
        snackbar.showSnackbar("Device token is not saved on server!");
      }
    } else if (token == null) {
      snackbar.showSnackbar("Device token is null");
    } else if (isTokenSave && !status) {
      await firestoreInst
          .collection(FirestoreConstants.tokenCollection)
          .doc(userId)
          .delete();
      String response = await _requests.deleteTokenFromBackend();
      if (response != "Success") {
        snackbar.showSnackbar("Device token is not delete from server!");
      }
    }
  }

  Future<bool> firestoreToken(String? userId) async {
    DocumentSnapshot snapshot = await firestoreInst
        .collection(FirestoreConstants.tokenCollection)
        .doc(userId)
        .get();
    if (userId != null) {
      return snapshot.exists && snapshot['token'] != null;
    }
    return false;
  }
}
