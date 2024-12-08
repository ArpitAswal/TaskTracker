import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import '../main.dart';

class ManageNotificationProvider extends ChangeNotifier {

  void initBackground() async {
    Workmanager().initialize(
      callbackDispatcher, // Replace with your callback function
      isInDebugMode: false,
    );

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
