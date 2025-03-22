import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_task/Models/todo_model.dart';

import '../../ViewModels/setting_provider.dart';
import '../../ViewModels/todo_provider.dart';
import 'task_card_widget.dart';

Widget todosList(List<TodoModel> todos, int ind, BuildContext context,
    TodoProvider provider) {
  final Set<int> animatedIndices = {}; // Keep track of animated indices

  return ListView.builder(
    physics: const BouncingScrollPhysics(),
    padding: const EdgeInsets.only(top: 16.0),
    itemCount: todos.length,
    itemBuilder: (context, index) {
      final todo = todos[index];
      //final start = DateFormat.yMMMd().format(todo.startDate);
      //final end = DateFormat.yMMMd().format(todo.endDate);
      // Check if the item has already been animated
      bool isAlreadyAnimated = animatedIndices.contains(index);
      Widget taskItem = _buildTaskWidget(
          context: context,
          index: index,
          todo: todo,
          provider: provider,
          tabIndex: ind);
      if (!isAlreadyAnimated) {
        animatedIndices.add(index); // Mark the item as animated

        if (index % 2 == 0) {
          taskItem = SlideInLeft(
            delay: const Duration(milliseconds: 100),
            duration: const Duration(milliseconds: 1000),
            child: taskItem,
          );
        } else {
          taskItem = SlideInRight(
            delay: const Duration(milliseconds: 100),
            duration: const Duration(milliseconds: 1000),
            child: taskItem,
          );
        }
      }
      return taskItem;
    },
  );
}

Widget _buildTaskWidget(
    {required TodoModel todo,
    required int index,
    required TodoProvider provider,
    required int tabIndex,
    required BuildContext context}) {
  final timming = compareDates(todo.startDate, todo.endDate, DateTime.now(),
      DateFormat('hh:mm a').format(todo.createdAtTime));
  return Padding(
    padding: const EdgeInsets.only(bottom: 16.0),
    child: Slidable(
      key: Key(index.toString()),
      startActionPane: (tabIndex == 0)
          ? ActionPane(
              extentRatio: 0.25,
              motion: const DrawerMotion(),
              children: [
                  SlidableAction(
                    onPressed: (context) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                              elevation: 8.0,
                              backgroundColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  side: context
                                          .read<SettingsProvider>()
                                          .isDarkMode
                                      ? BorderSide(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                          width: 2.0)
                                      : BorderSide.none),
                              contentPadding: EdgeInsets.zero,
                              insetPadding: const EdgeInsets.all(32.0),
                              alignment: Alignment.center,
                              content: IntrinsicHeight(
                                child: TaskCardWidget((TodoModel value) {
                                  provider.updateTodo(todo.id, value);
                                }, todo, popupTitle: "Update Exist Task"),
                              ));
                        },
                      );
                    },
                    icon: Icons.edit_note_rounded,
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.white,
                    label: "Edit",
                    autoClose: true,
                    padding: EdgeInsets.zero,
                  ),
                ])
          : null,
      endActionPane:
          ActionPane(extentRatio: 0.5, motion: const BehindMotion(), children: [
        SlidableAction(
          onPressed: (context) {
            provider.deleteTodo(todo.id);
          },
          icon: Icons.delete_forever_rounded,
          backgroundColor: Colors.redAccent,
          foregroundColor: Colors.white,
          label: "Delete",
          autoClose: true,
          padding: EdgeInsets.zero,
        ),
        (tabIndex == 0)
            ? SlidableAction(
                onPressed: (context) {
                  todo.isCompleted = true;
                  provider.updateTodo(todo.id, todo);
                },
                icon: Icons.done_rounded,
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                label: "Done",
                autoClose: true,
                padding: EdgeInsets.zero,
              )
            : const SizedBox()
      ]),
      child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                  color: Theme.of(context).colorScheme.primary, width: 2),
              boxShadow: [
                BoxShadow(
                    color: Theme.of(context).colorScheme.primary,
                    blurRadius: 4.0,
                    spreadRadius: 1.0)
              ]),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "TASK\n ${todo.id.toString()}",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                      decoration: null,
                      decorationColor: Colors.transparent),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(todo.title,
                          softWrap: true,
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.fade,
                          maxLines: 2,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor)),
                      Text(
                        todo.description,
                        softWrap: true,
                        textAlign: TextAlign.start,
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context)
                                .primaryColor
                                .withOpacity(0.65)),
                      ),
                      const SizedBox(height: 4.0),
                      Align(
                        alignment: AlignmentDirectional.bottomEnd,
                        child: Text(
                          (tabIndex == 1)
                              ? "${DateFormat('hh:mm a').format(todo.createdAtTime)}, ${DateFormat.yMMMd().format(todo.endDate)}"
                              : timming,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.65)),
                        ),
                      ),
                    ],
                  ),
                )
              ])),
    ),
  );
}

String compareDates(
    DateTime startDate, DateTime endDate, DateTime currentDate, String time) {
  // Format dates to yMMMd to ignore time.
  String formattedStartDate = DateFormat.yMMMd().format(startDate);
  String formattedEndDate = DateFormat.yMMMd().format(endDate);
  String formattedCurrentDate = DateFormat.yMMMd().format(currentDate);

  // Parse formatted dates back to DateTime for comparison.
  //DateTime parsedStartDate = DateFormat.yMMMd().parse(formattedStartDate);
  DateTime parsedEndDate = DateFormat.yMMMd().parse(formattedEndDate);
  DateTime parsedCurrentDate = DateFormat.yMMMd().parse(formattedCurrentDate);

  if (parsedCurrentDate.isAtSameMomentAs(parsedEndDate)) {
    return "Last Day";
  } else if (parsedCurrentDate.isBefore(parsedEndDate)) {
    return "$time, $formattedStartDate";
  } else {
    return "Task Day's Over";
  }
}
