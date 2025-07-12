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

  Future<void> initBackground({int? delayInHours}) async {
    if (delayInHours != null) {
      destroyManagerTask();
    }

    Future.delayed(const Duration(seconds: 1), () {
      Workmanager().initialize(
        // Initialize background tasks using Workmanager.
        callbackDispatcher, // Replace with your callback function
        isInDebugMode: false, // Disable debug mode for production.
      );

      final now = DateTime.now();
      final after15Min = now.add(const Duration(minutes: 15));
      DateTime? nextHour;
      if (now.hour == after15Min.hour) {
        nextHour = DateTime(now.year, now.month, now.day, now.hour,
            (now.minute + 15), (now.second + 15));
      } else {
        nextHour = DateTime(now.year, now.month, now.day, (now.hour + 1),
            now.minute, now.second);
      }

      final initialDelay = nextHour.difference(now);

      // Register morning task
      Workmanager().registerPeriodicTask(
        WorkManagerConstants.periodicUniqueName,
        WorkManagerConstants.periodicTaskName,
        frequency: Duration(hours: delayInHours ?? 4),
        constraints: Constraints(
            // Consider adding networkType and requiresCharging constraints if needed
            networkType: NetworkType.not_required,
            requiresCharging: false,
            requiresBatteryNotLow: false,
            requiresDeviceIdle: false,
            requiresStorageNotLow: false),
        initialDelay: initialDelay, // Calculate the delay for the first run
        existingWorkPolicy: ExistingWorkPolicy
            .replace, // Set existingWorkPolicy to replace to ensure tasks are always scheduled
        backoffPolicy: BackoffPolicy.linear, // to retry failed tasks
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
    });
  }

  void specificRemainderTask(int hour) async {
    final taskName = 'TaskTracker_SpecificTaskRemainder_Hour$hour';

    final now = DateTime.now();
    var nextTrigger = DateTime(now.year, now.month, now.day, hour);
    if (now.isAfter(nextTrigger)) {
      nextTrigger = nextTrigger.add(const Duration(days: 1));
    }
    final delay = nextTrigger.difference(now);

    Workmanager().registerPeriodicTask(
      WorkManagerConstants.specificTaskName,
      taskName,
      frequency: const Duration(hours: 24),
      initialDelay: delay,
      constraints: Constraints(
          // Consider adding networkType and requiresCharging constraints if needed
          networkType: NetworkType.not_required,
          requiresCharging: false,
          requiresBatteryNotLow: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false),
      existingWorkPolicy: ExistingWorkPolicy
          .replace, // Set existingWorkPolicy to replace to ensure tasks are always scheduled
      backoffPolicy: BackoffPolicy.linear, // to retry failed tasks
      backoffPolicyDelay: const Duration(minutes: 15),
    );
  }
}
