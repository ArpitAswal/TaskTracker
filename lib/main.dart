import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:todo_task/Models/todo_model.dart';
import 'package:todo_task/Service/notification.dart';
import 'package:todo_task/ViewModels/manage_notification_provider.dart';
import 'package:todo_task/ViewModels/todo_provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:workmanager/workmanager.dart';

import 'Adapters/todo_adapter.dart';
import 'Views/todo_screen.dart';

const morningNotification = "MorningNotification";
const nightNotification = "NightNotification";

void callbackDispatcher() {
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
    PushNotifications().scheduleNotification(show: hasPendingTasks, hour: 15);
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
      PushNotifications().scheduleNotification(show: null, hour: 17);
    }
  }
  await box.close();
}

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // It is used so that void main function can be initiated after successfully initialization of data
  PushNotifications.init();
  tz.initializeTimeZones();
  // Initialize Hive
  await Hive.initFlutter();
  // Register the adapter
  Hive.registerAdapter(TodoAdapter());
  // Open a box (database)
  await Hive.openBox<TodoModel>('todoBox');
  await Hive.openBox<String>('notification_permission');
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (BuildContext context) => TodoProvider(),
      ),
      ChangeNotifierProvider(
          create: (BuildContext context) => ManageNotificationProvider())
    ],
    child: const MyApp(),
  ));
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
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width * .5,
              fit: BoxFit.cover,
              repeat: true,
              reverse: true),
          nextScreen: const TaskScreen(title: 'Task Screen'),
          splashTransition: SplashTransition.fadeTransition,
          curve: Curves.easeInOut,
          backgroundColor: Colors.white),
    );
  }
}
