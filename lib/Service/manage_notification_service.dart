import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:workmanager/workmanager.dart';

import '../Utils/constants/app_constants.dart';
import '../main.dart';

class ManageNotificationService {
  void destroyManagerTask() {
    Workmanager().cancelAll(); // cancel all the workmanager periodic task
    Fluttertoast.showToast(
        msg: WorkManagerConstants.workManagerCancel,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: Colors.redAccent.shade400,
        textColor: Colors.white,
        fontSize: 14.0);
  }

  void initBackground() async {
    Workmanager().initialize(
      // Initialize background tasks using Workmanager.
      callbackDispatcher, // Replace with your callback function
      isInDebugMode: false, // Disable debug mode for production.
    );

    // Register morning task
    Workmanager().registerPeriodicTask(
      WorkManagerConstants.morningUniqueName,
      WorkManagerConstants.morningTaskName,
      frequency: const Duration(hours: 24),
      constraints: Constraints(
          // Consider adding networkType and requiresCharging constraints if needed
          networkType: NetworkType.not_required,
          requiresCharging: false,
          requiresBatteryNotLow: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false),
      initialDelay: morningDelay(), // Calculate the delay for the first run
      existingWorkPolicy: ExistingWorkPolicy
          .replace, // Set existingWorkPolicy to replace to ensure tasks are always scheduled
      backoffPolicy: BackoffPolicy.linear, // to retry failed tasks
      backoffPolicyDelay: const Duration(minutes: 15),
    );

    // Register night task
    Workmanager().registerPeriodicTask(
      WorkManagerConstants.nightUniqueName,
      WorkManagerConstants.nightTaskName,
      frequency: const Duration(hours: 24),
      constraints: Constraints(
          networkType: NetworkType.not_required,
          requiresCharging: false,
          requiresBatteryNotLow: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false),
      initialDelay: nightDelay(),
      existingWorkPolicy: ExistingWorkPolicy.replace,
      backoffPolicy: BackoffPolicy.linear,
      backoffPolicyDelay: const Duration(minutes: 15),
    );

    Fluttertoast.showToast(
      msg: WorkManagerConstants.workManagerInitialize,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.green.shade400,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  Duration morningDelay() {
    final now = DateTime.now();
    var next9AM = DateTime(now.year, now.month, now.day, 9, 0, 0);

    // If current time is after or equal to 9 AM, schedule for next day
    if (now.isAfter(next9AM) || now.isAtSameMomentAs(next9AM)) {
      next9AM = DateTime(now.year, now.month, now.day + 1, 9, 0, 0);
    }

    final difference = next9AM.difference(now);
    return difference;
  }

  Duration nightDelay() {
    final now = DateTime.now();
    var next9PM = DateTime(now.year, now.month, now.day, 21, 0, 0);

    // If current time is after or equal to 9 PM, schedule for next day
    if (now.isAfter(next9PM) || now.isAtSameMomentAs(next9PM)) {
      next9PM = DateTime(now.year, now.month, now.day + 1, 21, 0, 0);
    }

    final difference = next9PM.difference(now);
    return difference;
  }
}
