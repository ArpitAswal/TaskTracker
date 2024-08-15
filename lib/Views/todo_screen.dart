import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import '../Models/todo_model.dart';
import '../ViewModels/todo_view_model.dart';
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
    with SingleTickerProviderStateMixin {
  late TabController _tabCnt;
  late TodoViewModel outerProvider;

  @override
  void initState() {
    super.initState();
    outerProvider = Provider.of<TodoViewModel>(context, listen: false);
    _tabCnt = TabController(length: 2, vsync: this);
    _tabCnt.addListener((){
      if(_tabCnt.index == 0){
        outerProvider.setIndex(0);
      } else{
        outerProvider.setIndex(1);
      } });
  }

  @override
  void dispose() {
    _tabCnt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(120.0),
          child: Consumer(
            builder: (BuildContext context, TodoViewModel provider, Widget? child) {
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
                    return Consumer(
                        builder: (BuildContext context, TodoViewModel value, Widget? child) {
                          return  todosList(todos, 0, context, value);
                        });
                  }
                },
              ),
            ),
            Consumer<TodoViewModel>(
              builder:
                  (BuildContext context, TodoViewModel value, Widget? child) {
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

  void showMessage(BuildContext context, TodoViewModel provider) {
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
