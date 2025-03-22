import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_task/ViewModels/setting_provider.dart';
import 'package:todo_task/ViewModels/todo_provider.dart';
import 'package:todo_task/Views/Widgets/fill_fields.dart';

import '../../Utils/helpers/dynamic_context_widgets.dart';
import '../../Utils/colors/app_colors.dart';
import '../../ViewModels/auth_provider.dart';
import '../Widgets/setting_card.dart';
import '../Widgets/state_handler.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen>
    with WidgetsBindingObserver {
  late TodoProvider taskProv;
  late SettingsProvider settingsProvider;
  late TextEditingController emailCtrl;
  late TextEditingController passCtrl;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    emailCtrl = TextEditingController();
    passCtrl = TextEditingController();
    taskProv = Provider.of<TodoProvider>(context, listen: false);
    settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    emailCtrl.dispose();
    passCtrl.dispose();
    formKey.currentState?.dispose();
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
       await settingsProvider.checkNotificationStatus();
       await settingsProvider.checkBatteryOptimizationStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<SettingsProvider>(
            builder: (BuildContext context, provider, Widget? child) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SettingsCard.infoCard(context,
                  tap: null,
                  label: provider.isDarkMode ? "Dark Theme" : "Light Theme",
                  icon: provider.isDarkMode
                      ? Icons.toggle_on_outlined
                      : Icons.toggle_off_outlined,
                  border: provider.isDarkMode,
                  child: SettingsCard.flutterSwitchCard(
                      context: context,
                      value: provider.isDarkMode,
                      toggle: provider.changeTheme,
                      borderColor: Theme.of(context).colorScheme.primary,
                      toggleColor: Theme.of(context).scaffoldBackgroundColor,
                      activeIcon: Icons.nightlight_round,
                      inactiveIcon: Icons.wb_sunny,
                      activeIconColor: AppColors.whiteColor,
                      inactiveIconColor: AppColors.yellowColor)),
              SettingsCard.infoCard(
                context,
                tap: null,
                label: provider.isWorkManagerInitialize
                    ? "Turn On Battery Saver"
                    : "Turn Off Battery Restrictions",
                icon: provider.isWorkManagerInitialize
                    ? Icons.battery_alert_outlined
                    : Icons.battery_saver_outlined,
                border: provider.isDarkMode,
                child: SettingsCard.flutterSwitchCard(
                  context: context,
                  value: !provider.isWorkManagerInitialize,
                  toggle: provider.toggleWorkManager,
                  borderColor: Theme.of(context).colorScheme.primary,
                  toggleColor: Theme.of(context).scaffoldBackgroundColor,
                  activeIcon: Icons.battery_saver_outlined,
                  inactiveIcon: Icons.battery_alert_outlined,
                  activeIconColor: AppColors.greenColor,
                  inactiveIconColor: AppColors.redColor,
                ),
              ),
              SettingsCard.infoCard(
                context,
                tap: null,
                label: provider.isNotificationAllow
                    ? "Turn Off App Notification"
                    : "Turn On App Notification",
                icon: provider.isNotificationAllow
                    ? Icons.notifications_active_outlined
                    : Icons.notifications_off_outlined,
                border: provider.isDarkMode,
                child: SettingsCard.flutterSwitchCard(
                  context: context,
                  value: provider.isNotificationAllow,
                  toggle: provider.toggleNotification,
                  borderColor: Theme.of(context).colorScheme.primary,
                  toggleColor: Theme.of(context).scaffoldBackgroundColor,
                  activeIcon: Icons.notifications_active_outlined,
                  inactiveIcon: Icons.notifications_off_outlined,
                  activeIconColor: AppColors.greenColor,
                  inactiveIconColor: AppColors.redColor,
                ),
              ),
              SettingsCard.infoCard(context, border: provider.isDarkMode,
                  tap: () {
                taskProv.deleteTaskMsg();
              },
                  icon: Icons.delete_outline_outlined,
                  label: "Delete All Tasks"),
              SettingsCard.infoCard(context, border: provider.isDarkMode,
                  tap: () {
                DynamicContextWidgets().deleteAccount((bool delete) {
                  if (delete) {
                    FillFields(
                            context: context,
                            key: formKey,
                            firstCtrl: emailCtrl,
                            secondCtrl: passCtrl)
                        .fillUserInfo(
                            lineColor: settingsProvider.isDarkMode
                                ? Theme.of(context).colorScheme.secondary
                                : Theme.of(context).colorScheme.tertiary,
                            label1: "Email Address 💌",
                            label2: "Password 👁️",
                            val1: 'Email is required',
                            val2: 'Password is required',
                            action: (email, value) async {
                              await context
                                  .read<AuthenticateProvider>()
                                  .verifyAccount(
                                      email: email,
                                      value: value,
                                      update: false);
                              taskProv.resetTasks();
                            });
                  }
                });
              }, icon: Icons.no_accounts_outlined, label: "Delete Account"),
              SettingsCard.infoCard(context,
                  border: provider.isDarkMode,
                  tap: () {},
                  icon: Icons.menu_book_outlined,
                  label: "Terms of Service"),
              SettingsCard.infoCard(context,
                  border: provider.isDarkMode,
                  tap: () {},
                  icon: Icons.privacy_tip_outlined,
                  label: "Privacy Policy"),
              SettingsCard.infoCard(context, border: provider.isDarkMode,
                  tap: () async {
                await context.read<AuthenticateProvider>().signOut();
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => const AuthStateHandler()),
                    (route) => false,
                  );
                }
              }, icon: Icons.logout_outlined, label: "LogOut"),
            ],
          );
        }),
      ),
    );
  }
}
