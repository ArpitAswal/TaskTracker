import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:workmanager/workmanager.dart';

import '../main.dart';

class ManageNotificationProvider extends ChangeNotifier {
  void destroyManagerTask() {
    Workmanager().cancelAll();
    Fluttertoast.showToast(
        msg: "All Periodic Notifications Cancel",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.redAccent.shade400,
        textColor: Colors.white,
        fontSize: 14.0);
  }

  void initBackground() async {
    // Initialize background tasks using Workmanager.
    Workmanager().initialize(
      callbackDispatcher, // Replace with your callback function
      isInDebugMode: false, // Disable debug mode for production.
    );

    // Register a daily morning task.
    Workmanager().registerPeriodicTask(
      "MorningTaskCheck",
      morningNotification,
      frequency: const Duration(hours: 24), // Runs daily
      constraints: Constraints(
          // Consider adding networkType and requiresCharging constraints if needed
          networkType: NetworkType.not_required,
          requiresCharging: null,
          requiresBatteryNotLow: null,
          requiresDeviceIdle: null,
          requiresStorageNotLow: null),
      initialDelay: morningDelay(), // Calculate the delay for the first run
    );

    // Register a daily night task.
    Workmanager().registerPeriodicTask(
      "NightTaskCheck",
      nightNotification,
      frequency: const Duration(hours: 24), // Runs daily
      constraints: Constraints(
          // Consider adding networkType and requiresCharging constraints if needed
          networkType: NetworkType.not_required,
          requiresCharging: null,
          requiresBatteryNotLow: null,
          requiresDeviceIdle: null,
          requiresStorageNotLow: null),
      initialDelay: nightDelay(), // Calculate the delay for the first run
    );

    Fluttertoast.showToast(
      msg: "All Periodic Notifications Set",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.green.shade400,
      textColor: Colors.black,
      fontSize: 14.0,
    );
  }

  Duration morningDelay() {
    // Calculate the time difference to the next 9:00 AM
    final now = DateTime.now();
    var next9AM = DateTime(now.year, now.month, now.day, 9, 0, 0);

    // If it's already past 9:00 AM, schedule for the next day
    if (now.isAfter(next9AM)) {
      next9AM =
          next9AM.add(const Duration(days: 1)); // Reassign to increment the day
    }
    return next9AM.difference(now);
  }

  Duration nightDelay() {
    // Calculate the time difference to the next 9:00 AM
    final now = DateTime.now();
    var next9PM = DateTime(now.year, now.month, now.day, 21, 0, 0);

    // If it's already past 9:00 AM, schedule for the next day
    if (now.isAfter(next9PM)) {
      next9PM =
          next9PM.add(const Duration(days: 1)); // Reassign to increment the day
    }
    return next9PM.difference(now);
  }
}
