import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_popup_card/flutter_popup_card.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:todo_task/ViewModels/manage_notification_provider.dart';
import '../Models/todo_model.dart';
import '../Service/notification.dart';
import '../ViewModels/todo_provider.dart';
import 'Widgets/add_update_cardWidget.dart';
import 'Widgets/task_status_widget.dart';
import 'Widgets/todos_list.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key, required this.title});

  final String title;

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabCnt;
  late TodoProvider outerProvider;
  late ManageNotificationProvider notificationProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    outerProvider = Provider.of<TodoProvider>(context, listen: false);
    notificationProvider =
        Provider.of<ManageNotificationProvider>(context, listen: false);
    _tabCnt = TabController(length: 2, vsync: this);
    _tabCnt.addListener(() {
      if (_tabCnt.index == 0) {
        outerProvider.setIndex(0);
      } else {
        outerProvider.setIndex(1);
      }
    });
    getPermission();
  }

  @override
  void dispose() {
    _tabCnt.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && outerProvider.navigatingToSettings) {
      // The app has returned from the settings screen.
      getPermission(); // Recheck the permission status here.
      outerProvider.openSetting(false);
    }
  }

  Future<void> getPermission() async {
    var status = await Permission.ignoreBatteryOptimizations.status;

    if (status.isGranted) {
      // User has granted permission, proceed with app logic
      notificationProvider.initBackground();
    } else if ((status.isDenied || status.isPermanentlyDenied)) {
      // Handle case where user denied permission
      showPopupCard(
          context: context,
          alignment: Alignment.center,
          useSafeArea: true,
          dimBackground: true,
          builder: (context) {
            return PopupCard(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(24.0))),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.18,
                  width: MediaQuery.of(context).size.width * 0.82,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                    ).copyWith(top: 12.0),
                    child: Column(
                      children: [
                        const Text(
                            "If you wish to get schedule notification daily you have to turn off the battery optimisation."),
                        const SizedBox(height: 4.0),
                        RichText(
                          text: const TextSpan(
                              text: "",
                              children: <InlineSpan>[
                                TextSpan(
                          text: "Note: ",
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                                )),
                                TextSpan(
                                  text:
                                  " After denying the permission, you have to turn off the battery optimisation manually from settings to get the schedule notification.",
                                    style: TextStyle(
                                      color: Colors.black45,))
                              ]),
                        ),
                        const SizedBox(height: 4.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Deny", style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),)),
                            const SizedBox(
                              width: 6.0,
                            ),
                            TextButton(
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  await Permission.ignoreBatteryOptimizations
                                      .request();
                                  outerProvider.openSetting(true);
                                },
                                child: const Text("Allow", style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold))),
                          ],
                        ),
                      ],
                    )));
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(120.0),
          child: Consumer(builder:
              (BuildContext context, TodoProvider provider, Widget? child) {
            return AppBar(
              title: Text(widget.title),
              actions: [
                IconButton(
                  icon: Icon(
                    provider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                  ),
                  onPressed: () {
                    provider.toggleTheme(); // Toggle the theme
                  },
                ),
                IconButton(
                    onPressed: () {
                      showMessage(context, provider);
                    },
                    icon: const Icon(Icons.delete_forever_rounded)),
                IconButton(
                    onPressed: () {
                      SystemNavigator.pop();
                    },
                    icon: const Icon(Icons.exit_to_app))
              ],
              bottom: TabBar(
                controller: _tabCnt,
                indicatorColor: Colors.indigo,
                dividerColor: Colors.transparent,
                tabs: [
                  taskStatusWidget(
                    text: "Pending",
                    bgColor:
                        (provider.tabIndex == 0) ? Colors.indigo : Colors.white,
                    shdColor:
                        (provider.tabIndex == 0) ? Colors.white : Colors.indigo,
                    bodColor:
                        (provider.tabIndex == 0) ? Colors.white : Colors.indigo,
                    textColor:
                        (provider.tabIndex == 0) ? Colors.white : Colors.indigo,
                    onPressed: () {
                      _tabCnt.animateTo(0);
                    },
                  ),
                  taskStatusWidget(
                    text: "Completed",
                    bgColor:
                        (provider.tabIndex == 0) ? Colors.white : Colors.indigo,
                    shdColor:
                        (provider.tabIndex == 0) ? Colors.indigo : Colors.white,
                    bodColor:
                        (provider.tabIndex == 0) ? Colors.indigo : Colors.white,
                    textColor:
                        (provider.tabIndex == 0) ? Colors.indigo : Colors.white,
                    onPressed: () {
                      _tabCnt.animateTo(1);
                    },
                  ),
                ],
              ),
            );
          }),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await addUpdateCardWidget(context, (TodoModel newTodo) {
              outerProvider.addTodo(newTodo);
              PushNotifications().showNotification(todo: newTodo);
            });
          },
          isExtended: true,
          tooltip: "New Task",
          foregroundColor: Colors.indigo,
          backgroundColor: Colors.white,
          splashColor: Colors.deepPurple,
          clipBehavior: Clip.antiAlias,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
          elevation: 5.0,
          child: const Icon(Icons.note_alt_rounded),
        ),
        body: TabBarView(
          controller: _tabCnt,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: ValueListenableBuilder(
                valueListenable: Hive.box<TodoModel>('todoBox').listenable(),
                builder: (context, Box<TodoModel> box, _) {
                  final todos = outerProvider.getTodos();
                  if (todos.isEmpty) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.35),
                        const Icon(Icons.note_alt_rounded),
                        const Text("No pending task"),
                      ],
                    );
                  } else {
                    return Consumer(builder: (BuildContext context,
                        TodoProvider value, Widget? child) {
                      return todosList(todos, 0, context, value);
                    });
                  }
                },
              ),
            ),
            Consumer<TodoProvider>(
              builder:
                  (BuildContext context, TodoProvider value, Widget? child) {
                return SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: (value.completedTask.isEmpty)
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.35),
                            const Icon(Icons.note_alt_rounded),
                            const Text("No completed task"),
                          ],
                        )
                      : todosList(value.completedTask, 1, context, value),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void showMessage(BuildContext context, TodoProvider provider) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            shadowColor: provider.isDarkMode ? Colors.white : Colors.indigo,
            elevation: 8,
            actionsPadding:
                const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 26.0),
            title: const Text("Database Tasks"),
            titleTextStyle: TextStyle(
                color: provider.isDarkMode ? Colors.indigo : Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
                borderRadius: const BorderRadius.all(Radius.circular(24.0)),
                side: BorderSide(
                    color: provider.isDarkMode ? Colors.white : Colors.indigo,
                    width: 2.0)),
            content: const Text(
                "Are you sure you want to delete all your Pending and Completed tasks"),
            contentTextStyle: TextStyle(
                color: provider.isDarkMode ? Colors.white54 : Colors.black54),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                        color:
                            provider.isDarkMode ? Colors.white : Colors.indigo),
                  )),
              TextButton(
                  onPressed: () {
                    provider.resetTasks();
                    Navigator.pop(context);
                  },
                  child: Text(
                    "Delete",
                    style: TextStyle(
                        color:
                            provider.isDarkMode ? Colors.white : Colors.indigo),
                  ))
            ],
          );
        });
  }
}
