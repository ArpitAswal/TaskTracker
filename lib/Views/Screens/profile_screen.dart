import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:todo_task/Utils/extensions/elevated_btn_extension.dart';
import 'package:todo_task/ViewModels/auth_provider.dart';
import 'package:todo_task/ViewModels/setting_provider.dart';

import '../../Models/auth_model.dart';
import '../../Service/manage_notification_service.dart';
import '../../Utils/colors/app_colors.dart';
import '../../ViewModels/todo_provider.dart';
import '../Widgets/fill_fields.dart';
import '../Widgets/setting_card.dart';
import 'admin_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  ValueNotifier<int> selectHour = ValueNotifier<int>(1);

  late AuthenticateProvider provider;

  @override
  void initState() {
    super.initState();
    provider = context.read<AuthenticateProvider>();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    _formKey.currentState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Column(
              children: [
                _buildUserInfoFromFirestore(),
                SizedBox(height: size.height * 0.025),
                _buildStaticWidget(),
                delayHourSelector(
                  context: context,
                  onHourSelected: (int hours) async {
                    await ManageNotificationService()
                        .initBackground(delayInHours: hours);
                  },
                )
              ],
            )));
  }

  Widget delayHourSelector(
      {required Function(int hours) onHourSelected,
      required BuildContext context}) {

    return SettingsCard.infoCard(
      context,
      tap: () {
        selectHour.value = provider.hiveBox.values.toList().first;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return Dialog(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: const BorderSide(color: Colors.white)
                ),
                shadowColor: Theme.of(context).primaryColor,
                elevation: 8.0,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 15.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Schedules a periodic task that will run every provided frequency",
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold),
                        ),
                        ValueListenableBuilder(
                          valueListenable: selectHour,
                          builder: (context, value, child){
                            return DropdownButton<int>(
                                dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                            focusColor: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(12.0),
                            value: value,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).primaryColor),
                            //icon: Icon(Icons.more_time_outlined, color: Theme.of(context).primaryColor),
                            iconEnabledColor: Theme.of(context).primaryColor,
                            underline: null,
                            padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 6.0),
                            isExpanded: true,
                            items: List.generate(12, (index) => index + 1)
                                .map((hr) => DropdownMenuItem<int>(
                                      value: hr,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Text('$hr hour${hr > 1 ? 's' : ''}',
                                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).primaryColor),
                                            ),
                                          ),
                                          Icon(Icons.more_time_outlined, color: Theme.of(context).primaryColor),
                                        ],
                                      ),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                selectHour.value = value;
                              }
                            },
                          );
                          }),

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text("Note: The Workmanager will reschedule again!",
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).primaryColor),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                style:  Theme.of(context).secondaryElevatedButtonStyle(
                                    context,
                                    minWidth: MediaQuery.of(context).size.width / 4,
                                    borderRadius: 14),
                                child: const Text("Cancel"),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  provider.setSelectedHour(selectHour.value);
                                  onHourSelected(selectHour.value);
                                  Navigator.of(context).pop();
                                },
                                style:  Theme.of(context).primaryElevatedButtonStyle(
                                    context,
                                    minWidth: MediaQuery.of(context).size.width / 4,
                                    borderRadius: 14),
                                child: const Text("Set"),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 8.0)
                      ],
                    ),
                  ),
                ));
          },
        );
      },
      icon: Icons.timer,
      label: "Periodic Notification Timer",
      border: context.read<SettingsProvider>().isDarkMode,
    );
  }

  Widget _buildUserInfoFromFirestore() {
    return StreamBuilder<DocumentSnapshot>(
      stream: context.read<AuthenticateProvider>().streamSnapshot(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        print("Snapshot Data: ${snapshot.data!.data().toString()}");
        var userData = AuthenticateModel.fromMap(
            snapshot.data!.data() as Map<String, dynamic>);
        return Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Lottie.asset(
              height: 60,
              width: 60,
              "assets/lottie/doneTask.json",
              animate: true,
              reverse: true,
              alignment: Alignment.center,
              filterQuality: FilterQuality.high,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Hello!",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor)),
                  Text(userData.name ?? userData.email,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor)),
                ],
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  FillFields(
                          context: context,
                          key: _formKey,
                          firstCtrl: emailController,
                          secondCtrl: nameController)
                      .fillUserInfo(
                          lineColor: context.read<SettingsProvider>().isDarkMode
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).colorScheme.tertiary,
                          label1: "Email your private Email 💌",
                          label2: "What should we call you 👨🏻‍💼",
                          val1: 'Email is required',
                          val2: 'User name is required',
                          action: (email, value) async {
                            await provider.verifyAccount(
                                email: email, value: value, update: true);
                          });
                },
                style: Theme.of(context).primaryElevatedButtonStyle(
                  context,
                  minWidth: MediaQuery.of(context).size.width * 0.2,
                  borderRadius: 8.0,
                ),
                child: Selector<AuthenticateProvider, UpdateSuccess>(
                  builder: (BuildContext context, UpdateSuccess value,
                      Widget? child) {
                    return (value == UpdateSuccess.loading)
                        ? Center(
                            child: CircularProgressIndicator(
                              color: Theme.of(context).colorScheme.secondary,
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                            ),
                          )
                        : const Text("Update");
                  },
                  selector: (_, provider) => provider.userInfo,
                )),
          ],
        );
      },
    );
  }

  Widget _buildStaticWidget() {
    Size size = MediaQuery.of(context).size;
    return Column(
      children: [
        Card(
            color: Theme.of(context).colorScheme.primary,
            elevation: 8.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
                side: BorderSide(
                    color: Theme.of(context).colorScheme.secondary,
                    width: 2.0)),
            shadowColor: Theme.of(context).colorScheme.primary,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: double.maxFinite,
                minHeight: size.height * 0.2,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Your all task report!",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      fontWeight: FontWeight.bold)),
                          SizedBox(height: size.height * 0.01),
                          ElevatedButton(
                              onPressed: () {
                                context.read<TodoProvider>().drawerIndex.value = 0;
                                //context.read<TodoProvider>().setIndex(1);
                              },
                              style: Theme.of(context)
                                  .primaryElevatedButtonStyle(context,
                                      minWidth: 0.3, borderRadius: 8.0),
                              child: const Text("View Task"))
                        ],
                      ),
                      const Spacer(),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: size.width * 0.25,
                            height: size.height * 0.12,
                            child: CircularProgressIndicator(
                              valueColor: const AlwaysStoppedAnimation(
                                  AppColors.whiteColor),
                              backgroundColor: Colors.white,
                              value:
                                  context.read<TodoProvider>().indicatorValue(),
                              strokeWidth: 8.0,
                            ),
                          ),
                          Text(
                              "${(context.read<TodoProvider>().indicatorValue() * 100).round()} %",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary))
                        ],
                      )
                    ],
                  ),
                ),
              ),
            )),
        SizedBox(height: size.height * 0.025),
        (provider.authUser.role == "Admin")
            ? SettingsCard.infoCard(context,
                border: context.read<SettingsProvider>().isDarkMode, tap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AdminScreen()));
              }, icon: Icons.admin_panel_settings, label: "Admin Panel")
            : const SizedBox.shrink()
      ],
    );
  }
}
