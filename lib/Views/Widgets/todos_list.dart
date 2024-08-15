import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:todo_task/Models/todo_model.dart';

import '../../ViewModels/todo_view_model.dart';
import 'add_update_cardWidget.dart';

Widget todosList(List<TodoModel> todos, int ind, BuildContext context, TodoViewModel provider) {
  debugPrint("index $ind debugCalled and darkMode is ${provider.isDarkMode}");

  return ListView.builder(
    padding: const EdgeInsets.only(top: 16.0),
    itemCount: todos.length,
    itemBuilder: (context, index) {
      final todo = todos[index];
      return Container(
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.only(bottom: 12.0),
        decoration: BoxDecoration(
          color: provider.isDarkMode ? Colors.transparent : Colors.white,
          shape: BoxShape.rectangle,
          border: Border.all(
            color: provider.isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        child: Slidable(
          key: Key(index.toString()),
          startActionPane: (ind == 0)
              ? ActionPane(
                  extentRatio: 0.25,
                  motion: const BehindMotion(),
                  children: [
                      SlidableAction(
                        onPressed: (context) async {
                          await addUpdateCardWidget(context, (TodoModel value) {
                            provider.updateTodo(todo.id, value);
                          }, task: todo);
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
          endActionPane: ActionPane(
              extentRatio: (ind == 0) ? 0.5 : 0.3,
              motion: const BehindMotion(),
              children: [
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
                (ind == 0)
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Task",
                          style: TextStyle(
                              color: Colors.indigo,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                        Flexible(
                          fit: FlexFit.loose,
                          child: Text(
                            todo.id.toString(),
                            style: const TextStyle(
                                color: Colors.indigo,
                                fontWeight: FontWeight.bold,
                                fontSize: 22),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 12.0,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          todo.title,
                          softWrap: true,
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.fade,
                          maxLines: 2,
                          style: TextStyle(
                            color: provider.isDarkMode
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          todo.description,
                          softWrap: true,
                          textAlign: TextAlign.start,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: provider.isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                              fontWeight: FontWeight.w400,
                              fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Task Start",
                        style: TextStyle(
                            color: provider.isDarkMode
                                ? Colors.white
                                : Colors.black,
                            fontWeight: FontWeight.w400,
                            fontSize: 12),
                      ),
                      Text(
                        todo.startDate,
                        style: const TextStyle(
                            color: Colors.indigo,
                            fontWeight: FontWeight.w400,
                            fontSize: 12),
                      ),
                      const SizedBox(
                        height: 12.0,
                      ),
                      (todo.endDate != null && todo.endDate!.isNotEmpty)
                          ? Text(
                              "Task End",
                              style: TextStyle(
                                  color: provider.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12),
                            )
                          : const SizedBox(),
                      (todo.endDate != null && todo.endDate!.isNotEmpty)
                          ? Text(
                              todo.endDate.toString(),
                              style: const TextStyle(
                                  color: Colors.indigo,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12),
                            )
                          : const SizedBox()
                    ],
                  ),
                ]),
          ),
        ),
      );
    },
  );
}
