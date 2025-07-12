import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_task/Utils/extensions/elevated_btn_extension.dart';
import 'package:todo_task/ViewModels/todo_provider.dart';

import '../../Models/todo_model.dart';
import '../../ViewModels/setting_provider.dart';

class TaskCardWidget extends StatefulWidget {
  const TaskCardWidget(this.onSuccess, this.task,
      {super.key, required this.popupTitle});

  final TodoModel? task;
  final Function(TodoModel newTodo) onSuccess;
  final String popupTitle;

  @override
  State<TaskCardWidget> createState() => _TaskCardWidgetState();
}

class _TaskCardWidgetState extends State<TaskCardWidget> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  late bool isSpecific;
  late int selectedHour;
  late int selectedMinute;
  final now = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      titleController.text = widget.task!.title;
      descriptionController.text = widget.task!.description;
      isSpecific = widget.task!.isSpecificTimeRemainder;
      selectedHour = widget.task!.reminderHour ?? selectedHour;
      selectedMinute = widget.task!.reminderMinute ?? selectedMinute;
    } else{
      isSpecific = false;
      selectedMinute = now.minute;
      selectedHour = now.hour;
    }
    context.read<TodoProvider>().setDateTime(widget.task);
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<TodoProvider>();
    final lineColor = context.read<SettingsProvider>().isDarkMode
        ? Theme.of(context).colorScheme.secondary
        : Theme.of(context).colorScheme.tertiary;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(color: lineColor),
            const SizedBox(height: 8.0),
            _buildTextField(
                labelText: "What are you planning? 😇",
                controller: titleController,
                errorText: provider.titleError,
                maxLength: 40,
                color: lineColor),
            _buildTextField(
                labelText: "Write a task description 📝",
                controller: descriptionController,
                errorText: provider.descriptionError,
                maxLength: 120,
                color: lineColor),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                Checkbox(
                  side: BorderSide(color: Theme.of(context).primaryColor),
                  value: isSpecific,
                  onChanged: (value) {
                    setState(() {
                      isSpecific = value!;
                    });
                  },
                ),
                Expanded(child: Text("Only Specific Hour",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).primaryColor),)),
                if (isSpecific)
                  GestureDetector(
                    onTap: () {
                      DatePicker.showTimePicker(
                        context,
                        showSecondsColumn: false,
                        showTitleActions: true,
                        currentTime: DateTime(now.year,now.month,now.day,now.hour,now.minute,0,0,0),
                        onConfirm: (time) {
                            selectedHour = time.hour;
                            selectedMinute = time.minute;
                            setState(() {

                            });
                        },
                      );
                    },
                    child: Container(
                      height: 30,
                        constraints: BoxConstraints(
                          minWidth: MediaQuery.of(context).size.width * 0.15
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(4.0),
                          border: Border.all(color: Theme.of(context).colorScheme.secondary)
                        ),
                        alignment: Alignment.center,
                        child: Text("${selectedHour.toString()}:${(selectedMinute < 10)? '0' : ''}${selectedMinute.toString()}",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.secondary),)),
                  ),
              ],
            ),
            _buildDatePickerField("Task Created Time", lineColor),
            _buildDatePickerField("Task Start Date", lineColor),
            _buildDatePickerField("Task End Date", lineColor),
            const SizedBox(height: 8.0),
            _buildButtons(provider),
          ],
        ),
      ),
    );
  }

  bool checkValidation(
    String title,
    String desc,
    TodoProvider value,
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
    return b;
  }

  Widget _buildTitle({required Color color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
            child: Divider(
          thickness: 1,
          color: color,
        )),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(widget.popupTitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold)),
        ),
        Expanded(
            child: Divider(
          thickness: 1,
          color: color,
        )),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String errorText,
    required String labelText,
    required int maxLength,
    required Color color,
  }) {
    return TextField(
      controller: controller,
      cursorColor: Theme.of(context).colorScheme.primary,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.sentences,
      maxLength: maxLength,
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold,
        decoration: TextDecoration.none,
        decorationColor: Colors.transparent,
      ),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.zero,
        labelText: labelText,
        counterStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: color),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
        errorBorder: errorText.isEmpty
            ? InputBorder.none
            : const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
              ),
        errorText: errorText.isEmpty ? null : errorText,
        errorStyle: const TextStyle(color: Colors.red),
        labelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDatePickerField(String label, Color lineColor) {
    final provider = context.watch<TodoProvider>();
    DateTime displayDate = label == "Task Created Time"
        ? provider.taskTime
        : (label == "Task Start Date"
            ? provider.taskStartDate
            : provider.taskEndDate);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: _dateTimeField(
        text: label,
        textColor: lineColor,
        childWidget: Text(
            label == "Task Created Time"
                ? DateFormat('hh:mm a').format(displayDate)
                : DateFormat.yMMMEd().format(displayDate),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.tertiary,
                fontWeight: FontWeight.w500)),
        selectedDate: displayDate,
        onConfirm: (label == "Task Created Time"
            ? (time) => provider.changeTime(time)
            : (date) => label == "Task Start Date"
                ? provider.changeStartDate(date)
                : provider.changeEndDate(date)),
      ),
    );
  }

  Widget _dateTimeField(
      {required String text,
      required Widget childWidget,
      required DateTime selectedDate,
      required Function(DateTime) onConfirm,
      required Color textColor}) {
    return Container(
      height: 50,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: textColor, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(text,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: textColor)),
          )),
          GestureDetector(
            onTap: () async {
              if (text == "Task Created Time") {
                // Show time picker for the time field
                DatePicker.showTimePicker(
                  context,
                  showTitleActions: true,
                  onConfirm: onConfirm,
                  currentTime: selectedDate,
                  showSecondsColumn: false,
                );
              } else {
                // Show date picker for date fields
                DatePicker.showDatePicker(
                  context,
                  showTitleActions: true,
                  minTime: DateTime.now(),
                  maxTime: DateTime(2030, 3, 5),
                  onConfirm: onConfirm,
                  currentTime: selectedDate,
                );
              }
            },
            child: Container(
                margin: const EdgeInsets.only(right: 5.0),
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey.shade100),
                child: childWidget),
          )
        ],
      ),
    );
  }

  Widget _buildButtons(TodoProvider provider) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ElevatedButton(
                onPressed: () {
                  provider.setTitleError("");
                  provider.setDescriptionError("");
                  Navigator.pop(context);
                },
                style: Theme.of(context).secondaryElevatedButtonStyle(context,
                    minWidth: MediaQuery.of(context).size.width * 0.2,
                    borderRadius: 8.0),
                child: const Text("Cancel Task")),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.1),
          Expanded(
            child: ElevatedButton(
                onPressed: () {
                  _taskPressedAction(
                      title: titleController.text,
                      desc: descriptionController.text,
                      prov: provider);
                },
                style: Theme.of(context).primaryElevatedButtonStyle(context,
                    minWidth: MediaQuery.of(context).size.width * 0.2,
                    borderRadius: 8.0),
                child:
                    Text((widget.task != null) ? "Update Task" : "Add Task")),
          )
        ],
      ),
    );
  }

  /// Show Selected Time As DateTime Format
  DateTime showTime(DateTime time) {
    if (widget.task?.startDate == null) {
      return time;
    } else {
      return widget.task!.startDate;
    }
  }

  // Show Selected Date As DateTime Format
  DateTime showDate(DateTime date) {
    if (widget.task?.startDate == null) {
      return date;
    } else {
      return widget.task!.startDate;
    }
  }

  void _taskPressedAction(
      {required String title,
      required String desc,
      required TodoProvider prov}) {
    if (widget.task != null) {
      widget.task!.title = title;
      widget.task!.description = desc;
      widget.task!.startDate = prov.taskStartDate;
      widget.task!.endDate = prov.taskEndDate;
      widget.task!.createdAtTime = prov.taskTime;
      widget.task!.isSpecificTimeRemainder = isSpecific;
      widget.task!.reminderHour = selectedHour;
      widget.task!.reminderMinute = selectedMinute;
      widget.onSuccess(widget.task!);
      Navigator.pop(context);
    } else {
      final todo = TodoModel(
          title: title,
          description: desc,
          id: prov.taskIndex + 1,
          startDate: prov.taskStartDate,
          endDate: prov.taskEndDate,
          createdAtTime: prov.taskTime,
          isSpecificTimeRemainder: isSpecific,
          reminderHour: selectedHour,
          reminderMinute: selectedMinute
      );
      if (checkValidation(title, desc, prov)) {
        widget.onSuccess(todo);
        prov.setTitleError("");
        prov.setDescriptionError("");
        Navigator.pop(context);
      }
    }
  }
}
