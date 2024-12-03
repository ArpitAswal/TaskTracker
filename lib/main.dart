import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:todo_task/Models/todo_model.dart';
import 'package:todo_task/Service/notification.dart';
import 'package:todo_task/ViewModels/todo_provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:workmanager/workmanager.dart';

import 'Adapters/todo_adapter.dart';
import 'Views/todo_screen.dart';

const morningNotification = "MorningNotification";
const nightNotification = "NightNotification";

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // It is used so that void main function can be initiated after successfully initialization of data
  PushNotifications.init();
  await initializeHiveForIsolate<TodoModel>();
  initBackground();
  runApp(ChangeNotifierProvider(
      create: (BuildContext context) => TodoProvider(), child: const MyApp()));
}

void callbackDispatcher() {
  debugPrint("callbackDispatcher");
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case morningNotification:
        await morningHive();
        break;
      case nightNotification:
        await nightHive();
        break;
    }
    return Future.value(true);
  });
}

Future<Box<TodoModel>> initializeHiveForIsolate<T>() async {
  tz.initializeTimeZones();

  // Initialize Hive
  await Hive.initFlutter();
  // Register the adapter
  Hive.registerAdapter(TodoAdapter());
  // Open a box (database)
  return await Hive.openBox<TodoModel>('todoBox');
}

Future<void> morningHive() async {
  final box = await initializeHiveForIsolate<TodoModel>();
  if (box.values.isEmpty) {
    PushNotifications().scheduleNotification(show: false, hour: 9);
  } else {
    // Check if any task is incomplete
    bool hasPendingTasks = box.values.any((task) {
      return !task.isCompleted;
    });
    PushNotifications().scheduleNotification(show: hasPendingTasks, hour: 9);
  }
  await box.close();
}

Future<void> nightHive() async {
  final box = await initializeHiveForIsolate<TodoModel>();
  if (box.values.isNotEmpty) {
    // Check if any task is incomplete
    String date = DateFormat("dd.MM.yy").format(DateTime.now());
    bool hasPendingTasks = box.values.any((task) {
      return !task.isCompleted && date == task.endDate;
    });
    if (hasPendingTasks) {
      PushNotifications().scheduleNotification(show: null, hour: 21);
    }
  }
  await box.close();
}

void initBackground() {
  Workmanager().initialize(
    callbackDispatcher, // Replace with your callback function
    isInDebugMode: false,
  );

  Workmanager().registerPeriodicTask(
    "MorningTaskCheck",
    morningNotification,
    frequency: const Duration(days: 1), // Runs daily
    constraints: Constraints(
        // Consider adding networkType and requiresCharging constraints if needed
        networkType: NetworkType.not_required,
        requiresCharging: false,
        requiresBatteryNotLow: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false),
    initialDelay: morningDelay(), // Calculate the delay for the first run
  );

  Workmanager().registerPeriodicTask(
    "NightTaskCheck",
    nightNotification,
    frequency: const Duration(days: 1), // Runs daily
    constraints: Constraints(
        // Consider adding networkType and requiresCharging constraints if needed
        networkType: NetworkType.not_required,
        requiresCharging: false,
        requiresBatteryNotLow: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false),
    initialDelay: nightDelay(), // Calculate the delay for the first run
  );
}

Duration morningDelay() {
  // Calculate the time difference to the next 9:00 AM
  final now = DateTime.now();
  var next9AM = DateTime(now.year, now.month, now.day, 8, 59, 0);

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
  var next9PM = DateTime(now.year, now.month, now.day, 20, 59, 0);

  // If it's already past 9:00 AM, schedule for the next day
  if (now.isAfter(next9PM)) {
    next9PM =
        next9PM.add(const Duration(days: 1)); // Reassign to increment the day
  }
  return next9PM.difference(now);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TodoProvider>(context);
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Task Tracker',
        theme: ThemeData(
          primaryColor: provider.isDarkMode ? Colors.white : Colors.indigo,
          appBarTheme: AppBarTheme(
              color: provider.isDarkMode ? Colors.black : Colors.white),
          scaffoldBackgroundColor:
              provider.isDarkMode ? Colors.black : Colors.white,
        ),
        darkTheme: ThemeData.dark(),
        themeMode: provider.currentTheme,
        home: AnimatedSplashScreen(
            centered: true,
            duration: 6000,
            splash: Lottie.asset('assets/Animation - 1723742573953.json',
                height: MediaQuery.of(context).size.height * .8,
                width: MediaQuery.of(context).size.width * .5,
                fit: BoxFit.cover,
                repeat: true,
                reverse: true),
            nextScreen: const TaskScreen(title: 'Task Screen'),
            splashTransition: SplashTransition.fadeTransition,
            curve: Curves.easeInOut,
            backgroundColor: Colors.white));
  }
}
