import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  final String title;

  const TermsScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    // Define reusable TextStyle objects to avoid repeating them
    TextStyle normalStyle = TextStyle(
      fontSize: 14.0,
      color: Theme.of(context).colorScheme.onPrimary,
    );

    TextStyle boldStyle = TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.primary,
    );

    TextStyle linkStyle = TextStyle(
      fontSize: 14.0,
      color: Theme.of(context).colorScheme.onSecondary,
      decoration: TextDecoration.underline,
      decorationColor: Theme.of(context).colorScheme.onSecondary,
    );

    TextStyle differentStyle = TextStyle(
        fontSize: 14.0,
        color: Theme.of(context).colorScheme.onSecondary,
        fontWeight: FontWeight.bold);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText.rich(
                    TextSpan(
                        children: termsOfServiceContent(
                            normalStyle, boldStyle, linkStyle, differentStyle)),
                    textAlign: TextAlign.start,
                    style: normalStyle),
                Align(
                  alignment: Alignment.centerRight,
                  child: Image.asset(
                    "assets/images/todo_image.png",
                    width: 60,
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<InlineSpan> termsOfServiceContent(TextStyle normalStyle,
          TextStyle boldStyle, TextStyle linkStyle, TextStyle differentStyle) =>
      [
        // const TextSpan(
        //   text: 'Terms of Service\n\n',
        //   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        // ),
        const TextSpan(
            text:
                'Welcome to TaskTracker, your personal productivity partner designed to help you organize, track, and complete your daily tasks.\n\nThese Terms of Service '),
        TextSpan(text: '("Terms") ', style: differentStyle),
        const TextSpan(
            text: 'govern your use of the TaskTracker mobile application '),
        TextSpan(text: '("App").', style: differentStyle),
        const TextSpan(text: ' Please read them carefully. \n\n'),
        TextSpan(
          text: '1. Agreement to Terms\n',
          style: boldStyle,
        ),
        const TextSpan(
            text:
                'By downloading, accessing, or using the App, you agree to be bound by these Terms and any additional terms and policies we provide.\nIf you do not agree, please do not use the App. \n\n'),
        TextSpan(
          text: '2. User Accounts & Registration\n',
          style: boldStyle,
        ),
        const TextSpan(
            text:
                'To access most features of the App, you must register using a valid email and password. You may register as either a'),
        TextSpan(text: ' User ', style: differentStyle),
        const TextSpan(text: 'or'),
        TextSpan(text: ' Admin. \n', style: differentStyle),
        const TextSpan(
            text:
                'Admins must enter a secret Admin Key. \nYou are responsible for maintaining the confidentiality of your login credentials and for all activity under your account. \n\n'),
        TextSpan(
          text: '3. Roles & Permissions\n',
          style: boldStyle,
        ),
        const TextSpan(
            text: 'User accounts can create, edit, and track personal tasks. \n'
                'Admin accounts have additional privileges such as sending broadcast notifications to users using '),
        TextSpan(
            text: 'Firebase Cloud Messaging (FCM).\n\n', style: differentStyle),
        const TextSpan(
          text:
              'TaskTracker reserves the right to revoke Admin access in case of abuse. \n\n',
        ),
        TextSpan(
          text: '4. Notification Services\n',
          style: boldStyle,
        ),
        TextSpan(
            text: 'We send reminders and updates via notifications.\n',
            style: differentStyle),
        const TextSpan(
          text: '• Hour-specific task alerts (if configured).\n'
              '• Admin announcements (via FCM).\n\n',
        ),
        TextSpan(
          text: '5. Theme & UI Preferences\n',
          style: boldStyle,
        ),
        const TextSpan(
          text:
              'The App supports both Dark and Light themes. Users may toggle between them in the Settings menu. UI responsiveness and theme persistence are handled locally. \n\n',
        ),
        TextSpan(
          text: '6. Background Task Handling\n',
          style: boldStyle,
        ),
        const TextSpan(
            text:
                'TaskTracker uses WorkManager to handle background processing like scheduled notifications. Some delays may occur due to OS-level restrictions, battery optimization, or permission denials.\n\n'),
        TextSpan(
          text: '7. Data Storage\n',
          style: boldStyle,
        ),
        TextSpan(text: 'Your data is stored:\n', style: differentStyle),
        const TextSpan(
          text: '• Locally via Hive (supports offline usage)\n'
              '• In the cloud via Firebase Firestore\n'
              '• We recommend keeping your Firebase credentials secured and not modifying app internals without guidance.\n\n',
        ),
        TextSpan(
          text: '8. Contact\n',
          style: boldStyle,
        ),
        TextSpan(text: 'tasktrackerV3@gmail.com \n', style: linkStyle),
      ];
}
