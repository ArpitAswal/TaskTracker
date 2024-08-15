import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:todo_task/Models/todo_model.dart';
import 'package:todo_task/ViewModels/todo_view_model.dart';

import 'Adapters/todo_adapter.dart';
import 'Views/todo_screen.dart';

void main() async {
  // It is used so that void main function can
  // be initiated after successfully initialization of data
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Hive
  await Hive.initFlutter();
  // Register the adapter
  Hive.registerAdapter(TodoAdapter());
  // Open a box (database)
  await Hive.openBox<TodoModel>('todoBox');
  //to clear the hive box database to clear the update issues
  //await Hive.box<TodoModel>('todoBox').clear();
  runApp(ChangeNotifierProvider(
      create: (BuildContext context) => TodoViewModel(), child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TodoViewModel>(context);
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ToDo Task',
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
