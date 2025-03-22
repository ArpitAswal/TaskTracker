import 'package:flutter/material.dart';
import 'package:todo_task/Utils/extensions/elevated_btn_extension.dart';

class FillFields {
  BuildContext context;
  GlobalKey<FormState> key;
  TextEditingController firstCtrl;
  TextEditingController secondCtrl;

  FillFields({
    required this.context,
    required this.key,
    required this.firstCtrl,
    required this.secondCtrl,
  });

  void fillUserInfo({
    required Color lineColor,
    required String label1,
    required String label2,
    required String val1,
    required String val2,
    required Future<void> Function(String email, String value) action,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: BorderSide(color: lineColor, width: 2.0),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          insetPadding: EdgeInsets.zero,
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Form(
              key: key,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitle(color: lineColor),
                  const SizedBox(height: 8.0),
                  _buildTextField(
                    labelText: label1,
                    controller: firstCtrl,
                    color: lineColor,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return val1;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8.0),
                  _buildTextField(
                    labelText: label2,
                    controller: secondCtrl,
                    color: lineColor,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return val2;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  _buildButtons(action: action),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle({required Color color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Divider(
            thickness: 1,
            color: color,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text("User Info",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: Divider(
            thickness: 1,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String labelText,
    required TextEditingController controller,
    required Color color,
    required String? Function(dynamic value) validator,
  }) {
    return TextFormField(
      controller: controller,
      cursorColor: Theme.of(context).colorScheme.primary,
      textInputAction: TextInputAction.next,
      textCapitalization: TextCapitalization.sentences,
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.bold,
        decoration: TextDecoration.none,
        decorationColor: Colors.transparent,
      ),
      validator: validator,
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
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        errorStyle: const TextStyle(color: Colors.red),
        labelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildButtons(
      {required Future<void> Function(String email, String value) action}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                firstCtrl.text = "";
                secondCtrl.text = "";
                Navigator.pop(context);
              },
              style: Theme.of(context).secondaryElevatedButtonStyle(
                context,
                minWidth: MediaQuery.of(context).size.width * 0.2,
                borderRadius: 8.0,
              ),
              child: const Text("Cancel"),
            ),
          ),
          SizedBox(width: MediaQuery.of(context).size.width * 0.2),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                _updateAction(action: action);
              },
              style: Theme.of(context).primaryElevatedButtonStyle(
                context,
                minWidth: MediaQuery.of(context).size.width * 0.2,
                borderRadius: 8.0,
              ),
              child: const Text("Confirm"),
            ),
          ),
        ],
      ),
    );
  }

  void _updateAction(
      {required Future<void> Function(String email, String value)
          action}) async {
    if (key.currentState!.validate()) {
      final email = firstCtrl.text;
      final value = secondCtrl.text;
      action(email, value);
      firstCtrl.text = "";
      secondCtrl.text = "";
      Navigator.pop(context);
    }
  }
}
