import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_task/Utils/extensions/elevated_btn_extension.dart';

import '../../ViewModels/auth_provider.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  final _notKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    Color colorScheme = Theme.of(context).colorScheme.primary;
    Color primary = Theme.of(context).primaryColor;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const Text("Admin Panel"),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Form(
              key: _notKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextFormField(
                      controller: _titleController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Title is required';
                        }
                        return null;
                      },
                      cursorColor: colorScheme,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colorScheme,
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.bold,
                          decorationThickness: 0),
                      decoration: InputDecoration(
                          labelText: "Notification Title",
                          prefixIcon: const Icon(Icons.title),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: primary),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: colorScheme),
                          ),
                          prefixIconColor: colorScheme,
                          labelStyle: TextStyle(color: colorScheme))),
                  SizedBox(height: size.height * 0.025),
                  TextFormField(
                      controller: _bodyController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Body msg is required';
                        }
                        return null;
                      },
                      cursorColor: colorScheme,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colorScheme,
                          decoration: TextDecoration.none,
                          fontWeight: FontWeight.bold,
                          decorationThickness: 0),
                      decoration: InputDecoration(
                          labelText: "Notification Body",
                          prefixIcon: const Icon(Icons.message),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: primary),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: colorScheme),
                          ),
                          prefixIconColor: colorScheme,
                          labelStyle: TextStyle(color: colorScheme))),
                  SizedBox(height: size.height * 0.04),
                  ElevatedButton(
                      onPressed: () {
                        if (_notKey.currentState!.validate()) {
                          context.read<AuthenticateProvider>().sendNotification(
                              title: _titleController.text,
                              body: _bodyController.text);
                        }
                      },
                      style: Theme.of(context).primaryElevatedButtonStyle(
                        context,
                        minWidth: size.width * 0.4,
                        borderRadius: 12.0,
                      ),
                      child: Selector<AuthenticateProvider, NetworkStatus>(
                        builder: (BuildContext context, NetworkStatus value,
                            Widget? child) {
                          return (value == NetworkStatus.loading)
                              ? CircularProgressIndicator(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                )
                              : const Text("Send Notification");
                        },
                        selector: (_, provider) => provider.netStatus,
                      ))
                ],
              ),
            ),
          ),
        ));
  }
}
