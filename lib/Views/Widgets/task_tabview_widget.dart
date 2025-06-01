import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:todo_task/Utils/extensions/elevated_btn_extension.dart';
import 'package:todo_task/Views/Widgets/todos_list.dart';

import '../../Utils/colors/app_colors.dart';
import '../../ViewModels/setting_provider.dart';
import '../../ViewModels/todo_provider.dart';

class TaskTabView extends StatelessWidget {
  final TabController tabController;

  const TaskTabView({super.key, required this.tabController});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Selector<TodoProvider, int>(
            builder: (BuildContext context, int value, Widget? child) {
              tabController.index = value;
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                      child: ElevatedButton(
                    onPressed: () => tabController.animateTo(0),
                    style: (value == 0)
                        ? Theme.of(context).primaryElevatedButtonStyle(context,
                            minWidth: MediaQuery.of(context).size.width * 0.4,
                            borderRadius: 24)
                        : Theme.of(context).secondaryElevatedButtonStyle(
                            context,
                            minWidth: MediaQuery.of(context).size.width * 0.4,
                            borderRadius: 24),
                    child: const Text("Pending"),
                  )),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.2),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => tabController.animateTo(1),
                      style: (value == 1)
                          ? Theme.of(context).primaryElevatedButtonStyle(
                              context,
                              minWidth: MediaQuery.of(context).size.width * 0.4,
                              borderRadius: 24)
                          : Theme.of(context).secondaryElevatedButtonStyle(
                              context,
                              minWidth: MediaQuery.of(context).size.width * 0.4,
                              borderRadius: 24),
                      child: const Text("Completed"),
                    ),
                  ),
                ],
              );
            },
            selector: (_, provider) => provider.tabIndex,
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              _buildTodoList(context, 0),
              _buildTodoList(context, 1),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTodoList(BuildContext context, int index) {
    return Consumer<TodoProvider>(
      builder: (context, provider, _) {
        final todos = index == 0 ? provider.getTodos() : provider.completedTask;
        final text = index == 0 ? "No Pending Tasks" : "No Completed Tasks";
        return todos.isEmpty
            ? Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FadeIn(
                    child: Lottie.asset(
                      height: 180,
                      width: 180,
                      "assets/lottie/doneTask.json",
                      animate: true,
                      alignment: Alignment.center,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                  Text(
                    text,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: context.read<SettingsProvider>().isDarkMode
                            ? AppColors.whiteColor
                            : AppColors.blueColor),
                  ),
                ],
              )
            : todosList(todos, index, context, provider);
      },
    );
  }
}
