import 'package:flutter/material.dart';
import 'package:todo_task/Utils/extensions/elevated_btn_extension.dart';
import 'package:todo_task/Views/Screens/task_screen.dart';

import '../../Utils/colors/app_colors.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: LayoutBuilder(
        // LayoutBuilder provides constraints from the parent widget
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            // Enables scrolling if content exceeds screen height
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewportConstraints
                    .maxHeight, // Ensures the Column takes at least the full viewport height
              ),
              child: IntrinsicHeight(
                // Makes the Column's height match its children's heights. This is useful when you want the Column to grow or shrink based on the content within it.
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex:
                          3, // Distributes space with other Expanded widgets, flex 3 means take 3/5 of available space.
                      child: Image.asset(
                        width: double.maxFinite,
                        'assets/images/onboarding_page.png', // Replace with your image path
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                    Expanded(
                      flex:
                          2, // Distributes space with other Expanded widgets, flex 2 means take 2/5 of available space.
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Task Management & To-Do List',
                              style: Theme.of(context).textTheme.titleLarge,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: size.height * 0.02),
                            Text(
                              'This productive tool is designed to help you better manage your task project-wise conveniently!',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                      color: AppColors.textColor,
                                      fontWeight: FontWeight.w400),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: size.height * 0.03),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (context) => const TaskScreen()),
                                  (route) => false,
                                );
                              },
                              style: Theme.of(context)
                                  .primaryElevatedButtonStyle(context,
                                      minWidth: 0.3, borderRadius: 24.0),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize
                                      .min, // Make the Row take only the required space
                                  children: [
                                    Text('Let\'s Start',
                                        style: TextStyle(fontSize: 18)),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
