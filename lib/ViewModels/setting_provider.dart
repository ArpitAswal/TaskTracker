import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:todo_task/Service/initialization_service.dart';
import 'package:app_settings/app_settings.dart';

import '../Utils/constants/app_constants.dart';

class SettingsProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _isWorkManagerInitialize = false;
  bool _isNotificationAllow = false;

  bool get isDarkMode => _isDarkMode;
  bool get isWorkManagerInitialize => _isWorkManagerInitialize;
  bool get isNotificationAllow => _isNotificationAllow;
  ThemeMode get currentTheme => isDarkMode ? ThemeMode.dark : ThemeMode.light;

  final initService = InitializationService();
  final auth = FirebaseAuth.instance;
  Box<bool> themeBox = Hive.box<bool>(HiveDatabaseConstants.themeHive);

  SettingsProvider() {
    checkTheme();
    checkNotificationStatus();
    checkBatteryOptimizationStatus();
  }

  void changeTheme() {
    _isDarkMode = !_isDarkMode;
    if (auth.currentUser?.uid != null) {
      themeBox.put(auth.currentUser!.uid, _isDarkMode);
    }
    notifyListeners();
  }

  void checkTheme() {
    if (auth.currentUser == null) {
      _isDarkMode = false;
    } else {
      _isDarkMode = themeBox.get(auth.currentUser!.uid) ?? false;
    }
    notifyListeners();
  }

  Future<void> toggleWorkManager() async {
    var status = await Permission.ignoreBatteryOptimizations.status;

    if (status.isGranted) {
      // Open settings manually because it can't be revoked programmatically, we can't request here because once the battery restriction is allowed it never request again.
      await AppSettings.openAppSettings(
          type: AppSettingsType.batteryOptimization);
    } else {
      // Request permission for the first time
      await Permission.ignoreBatteryOptimizations.request();
    }
  }

  Future<void> toggleNotification() async {
    AppSettings.openAppSettings(type: AppSettingsType.notification);
  }

  Future<void> checkBatteryOptimizationStatus() async {
    bool status = await Permission.ignoreBatteryOptimizations.isGranted;
    _isWorkManagerInitialize = status;
    if (status) {
      initService.initializeWorkManagerTasks();
    } else {
      initService.cancelWorkManagerTasks();
    }
    notifyListeners();
  }

  Future<void> checkNotificationStatus() async {
    bool status = await Permission.notification.isGranted;
    _isNotificationAllow = status;
    await initService.initializeDeferred(status: status);
    notifyListeners();
  }
}
