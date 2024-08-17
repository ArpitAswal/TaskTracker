import 'package:flutter/material.dart';
import 'package:flutter_popup_card/flutter_popup_card.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_task/ViewModels/todo_view_model.dart';

import '../../Models/todo_model.dart';

Future addUpdateCardWidget(
    BuildContext context, Function(TodoModel newTodo) onSuccess,
    {TodoModel? task}) async {
  final TextEditingController titleController =
      TextEditingController(text: task?.title);
  final TextEditingController descriptionController =
      TextEditingController(text: task?.description);
  final TextEditingController startController =
      TextEditingController(text: task?.startDate);
  final TextEditingController endController =
      TextEditingController(text: task?.endDate);

  return showPopupCard(
      context: context,
      alignment: Alignment.center,
      useSafeArea: true,
      dimBackground: true,
      builder: (context) {
        return Consumer<TodoViewModel>(builder:
            (BuildContext context, TodoViewModel value, Widget? child) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: PopupCard(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(24.0))),
              child: Container(
                  width: MediaQuery.of(context).size.width,
                  constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height * 0.3,
                      maxHeight: MediaQuery.of(context).size.height * 0.4),
                  margin: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      textFieldWidget(
                          controller: titleController,
                          labelText: 'Title',
                          errorText: value.titleError,
                          maxLength: 40,
                          darkMode: value.isDarkMode),
                      textFieldWidget(
                          controller: descriptionController,
                          labelText: 'Description',
                          errorText: value.descriptionError,
                          maxLength: 120,
                          darkMode: value.isDarkMode),
                      Row(
                        children: [
                          Expanded(
                              child: dateFieldWidget(
                                  controller: startController,
                                  errorText: value.startError,
                                  labelText: "Start Date",
                                  context: context,
                                  isStart: true,
                                  darkMode: value.isDarkMode)),
                          const SizedBox(
                            width: 36.0,
                          ),
                          Expanded(
                              child: dateFieldWidget(
                                  controller: endController,
                                  errorText: "",
                                  labelText: "End Date",
                                  context: context,
                                  isStart: false,
                                  darkMode: value.isDarkMode)),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ElevatedButton(
                                onPressed: () {
                                  value.setTitleError("");
                                  value.setDescriptionError("");
                                  value.setStartError("");
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: value.isDarkMode
                                        ? Colors.white
                                        : Colors.indigo,
                                    foregroundColor: value.isDarkMode
                                        ? Colors.indigo
                                        : Colors.white,
                                    side: BorderSide(
                                        color: value.isDarkMode
                                            ? Colors.indigo
                                            : Colors.white,
                                        width: 2.0),
                                    shadowColor: value.isDarkMode
                                        ? Colors.indigo
                                        : Colors.white,
                                    elevation: 8),
                                child: const Text(
                                  "Cancel",
                                )),
                            const SizedBox(width: 15.0),
                            (task == null)
                                ? ElevatedButton(
                                    onPressed: () {
                                      final newTodo = TodoModel(
                                          id: value.taskIndex,
                                          title: titleController.text,
                                          description:
                                              descriptionController.text,
                                          isCompleted: false,
                                          startDate: startController.text,
                                          endDate: endController.text.isEmpty
                                              ? null
                                              : endController.text);
                                      if (checkValidation(
                                          titleController,
                                          descriptionController,
                                          startController,
                                          value)) {
                                        onSuccess(newTodo);
                                        titleController.clear();
                                        descriptionController.clear();
                                        startController.clear();
                                        endController.clear();
                                        value.setTitleError("");
                                        value.setDescriptionError("");
                                        value.setStartError("");
                                        Navigator.pop(context);
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: value.isDarkMode
                                            ? Colors.white
                                            : Colors.indigo,
                                        foregroundColor: value.isDarkMode
                                            ? Colors.indigo
                                            : Colors.white,
                                        side: BorderSide(
                                            color: value.isDarkMode
                                                ? Colors.indigo
                                                : Colors.white,
                                            width: 2.0),
                                        shadowColor: value.isDarkMode
                                            ? Colors.indigo
                                            : Colors.white,
                                        elevation: 8),
                                    child: const Text(
                                      'Add To-Do',
                                    ),
                                  )
                                : ElevatedButton(
                                    onPressed: () {
                                      task.title =
                                          titleController.text.toString();
                                      task.description =
                                          descriptionController.text.toString();
                                      task.startDate = startController.text.toString();
                                      task.endDate = endController.text.toString();
                                      onSuccess(task);
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: value.isDarkMode
                                            ? Colors.white
                                            : Colors.indigo,
                                        foregroundColor: value.isDarkMode
                                            ? Colors.indigo
                                            : Colors.white,
                                        side: BorderSide(
                                            color: value.isDarkMode
                                                ? Colors.indigo
                                                : Colors.white,
                                            width: 2.0),
                                        shadowColor: value.isDarkMode
                                            ? Colors.indigo
                                            : Colors.white,
                                        elevation: 8),
                                    child: const Text(
                                      'Update',
                                    ))
                          ],
                        ),
                      ),
                    ],
                  )),
            ),
          );
        });
      });
}

bool checkValidation(
  TextEditingController titleController,
  TextEditingController descriptionController,
  TextEditingController startController,
  TodoViewModel value,
) {
  bool b = true;
  if (titleController.text.isEmpty) {
    b = false;
    value.setTitleError("Title is required");
  }
  if (descriptionController.text.isEmpty) {
    b = false;
    value.setDescriptionError("Description is required");
  }
  if (startController.text.isEmpty) {
    b = false;
    value.setStartError("Start Date is required");
  }
  return b;
}

Widget textFieldWidget(
    {required TextEditingController controller,
    required String errorText,
    required String labelText,
    required int maxLength,
    required bool darkMode}) {
  return TextField(
    controller: controller,
    cursorColor: darkMode ? Colors.white : Colors.indigo,
    textInputAction: (labelText.contains("Title"))
        ? TextInputAction.next
        : TextInputAction.done,
    maxLength: maxLength,
    decoration: InputDecoration(
      labelText: labelText,
      enabledBorder: UnderlineInputBorder(
          borderSide:
              BorderSide(color: darkMode ? Colors.white : Colors.black)),
      errorText: (errorText.isEmpty) ? null : errorText,
      errorStyle: const TextStyle(color: Colors.red),
      labelStyle: TextStyle(color: darkMode ? Colors.white : Colors.indigo),
      focusedBorder: UnderlineInputBorder(
          borderSide:
              BorderSide(color: darkMode ? Colors.white : Colors.black)),
    ),
  );
}

Widget dateFieldWidget(
    {required TextEditingController controller,
    required String errorText,
    required String labelText,
    required BuildContext context,
    required bool isStart,
    required bool darkMode}) {
  return TextField(
    controller: controller,
    cursorColor: darkMode ? Colors.white : Colors.indigo,
    readOnly: true,
    onTap: () async {
      final date = await _selectDate(context, isStart);
      if (date != null) {
        controller.text = date.toString();
      }
    },
    decoration: InputDecoration(
      labelText: labelText,
      enabledBorder: UnderlineInputBorder(
          borderSide:
              BorderSide(color: darkMode ? Colors.white : Colors.black)),
      errorText: (errorText.isEmpty) ? null : errorText,
      errorStyle: const TextStyle(color: Colors.red),
      labelStyle: TextStyle(color: darkMode ? Colors.white : Colors.indigo),
      focusedBorder: UnderlineInputBorder(
          borderSide:
              BorderSide(color: darkMode ? Colors.white : Colors.black)),
    ),
  );
}

Future<String?> _selectDate(BuildContext context, bool isStart) async {
  final dateFormat = DateFormat("dd.MM.yy");
  DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime(2101),
  );

  if (pickedDate != null) {
    if (isStart) {
      return dateFormat.format(pickedDate);
    } else {
      return dateFormat.format(pickedDate);
    }
  }
  return null;
}
