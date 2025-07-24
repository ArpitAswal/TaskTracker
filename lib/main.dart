import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:todo_task/Models/todo_model.dart';
import 'package:todo_task/Service/push_notification_service.dart';
import 'package:todo_task/ViewModels/todo_provider.dart';
import 'package:todo_task/ViewModels/auth_provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:workmanager/workmanager.dart';

import 'Adapters/todo_adapter.dart';
import 'Service/initialization_service.dart';
import 'Utils/colors/app_colors.dart';
import 'Utils/constants/app_constants.dart';
import 'ViewModels/setting_provider.dart';
import 'Views/Widgets/state_handler.dart';
import 'firebase_options.dart';

// Callback function that runs in the background.
// Workmanager uses this to execute tasks based on their unique task name.
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      // Initialize Firebase in the background isolate
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      if (task == WorkManagerConstants.periodicTaskName) {
        await handlePeriodicTask();
      } else if (task == WorkManagerConstants.specificTaskName) {
        await runReminderTaskForHour();
      }
      return Future.value(true); // Indicates successful task execution.
    } catch (e) {
      return Future.value(false); // Indicates failed task execution.
    }
  });
}

Future<void> runReminderTaskForHour() async {
  PushNotificationsService pushNot = PushNotificationsService();
  pushNot.initLocalNotifications();

  final box = await initializeHiveForIsolate<
      TodoModel>(); // Access the Hive box for todos.
  final now = DateTime.now();

  final pendingTasks = box.values.where((task) {
    return (task.isSpecificTimeRemainder && (task.reminderHour! == now.hour)) &&
        !task.isCompleted;
  }).toList(); // it will save all the tasks that have end date is same day as now day or before day as of now day.

  if (pendingTasks.isEmpty) {
    pushNot.scheduleNotification();
  } else {
    for (var task in pendingTasks) {
      await pushNot.showCustomNotification(
        id: task.id,
        title: task.title,
        body: task.description,
      );
    }
  }
  await box.close();
}

// Initializes Hive for use in isolates. Required when accessing Hive in a background thread.
Future<Box<TodoModel>> initializeHiveForIsolate<T>() async {
  tz.initializeTimeZones();

  // Initialize Hive
  await Hive.initFlutter();
  // Register the adapter
  Hive.registerAdapter(TodoAdapter());
  // Open a box (database)
  return await Hive.openBox<TodoModel>(HiveDatabaseConstants.todoHive);
}

Future<void> handlePeriodicTask() async {
  PushNotificationsService pushNot = PushNotificationsService();
  pushNot.initLocalNotifications();

  final box = await initializeHiveForIsolate<
      TodoModel>(); // Access the Hive box for todos.
  final now = DateTime.now();

  final pendingTasks = box.values.where((task) {
    return (task.endDate.isAtSameMomentAs(now) || task.endDate.isBefore(now)) &&
        !task.isCompleted;
  }).toList(); // it will save all the tasks that have end date is same day as now day or before day as of now day.

  if (pendingTasks.isEmpty) {
    pushNot.scheduleNotification();
  } else {
    for (var task in pendingTasks) {
      await pushNot.showCustomNotification(
        id: task.id,
        title: task.title,
        body: task.description,
      );
    }
  }
  await box.close();
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  /*
  If you're going to use other Firebase services in the background, such as Firestore, make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
   */
  debugPrint("🔥 Background message received: ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase first
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Initialize essential services
  await InitializationService().initializeEssentials();

  tz.initializeTimeZones();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (BuildContext context) => AuthenticateProvider(),
      ),
      ChangeNotifierProvider(
        create: (BuildContext context) => TodoProvider(),
      ),
      ChangeNotifierProvider(
        create: (BuildContext context) => SettingsProvider(),
      ),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appTitle,
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        primaryColor: AppColors.blackColor,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.textColor,
          primary: AppColors.blueColor,
          secondary: AppColors.whiteColor,
          tertiary: AppColors.textColor,
          onPrimary: AppColors.blackColor,
          onSecondary: AppColors.redColor
        ),
        appBarTheme: AppBarTheme(
            centerTitle: true,
            backgroundColor: AppColors.blueColor,
            foregroundColor: AppColors.whiteColor,
            titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.whiteColor, fontWeight: FontWeight.bold)),
        scaffoldBackgroundColor: AppColors.whiteColor,
      ),
      darkTheme: ThemeData(
        scaffoldBackgroundColor: AppColors.blackColor,
        primaryColor: AppColors.whiteColor,
        appBarTheme: AppBarTheme(
            centerTitle: true,
            backgroundColor: AppColors.indigoColor,
            foregroundColor: AppColors.whiteColor,
            titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.whiteColor, fontWeight: FontWeight.bold)),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.textColor,
          primary: AppColors.indigoColor,
          secondary: AppColors.whiteColor,
          tertiary: AppColors.textColor,
          onPrimary: AppColors.whiteColor,
          onSecondary: AppColors.orangeColor
        ),
      ),
      themeMode: context.watch<SettingsProvider>().currentTheme,
      home: AnimatedSplashScreen(
          centered: true,
          //duration: 3500, // Reduced to better match Lottie animation
          splash: Lottie.asset(
            'assets/lottie/splash.json',
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width * .5,
            fit: BoxFit.cover,
            repeat: true,
            reverse: true,
            options: LottieOptions(enableMergePaths: true),
          ),
          nextScreen: const AuthStateHandler(),
          animationDuration: const Duration(seconds: 2),
          splashTransition: SplashTransition.scaleTransition,
          curve: Curves.linear,
          backgroundColor: Colors.white),
    );
  }
}
