import 'package:flutter/material.dart';

class PolicyScreen extends StatelessWidget {
  final String title;

  const PolicyScreen({super.key, required this.title});

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
              children: [
                SelectableText.rich(
                  TextSpan(
                      children: privacyPolicyContent(
                          normalStyle, boldStyle, linkStyle, differentStyle)),
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onPrimary,
                      height: 1.6),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Image.asset(
                    "assets/images/todo_image.png",
                    width: 60,
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<InlineSpan> privacyPolicyContent(TextStyle normalStyle,
          TextStyle boldStyle, TextStyle linkStyle, TextStyle differentStyle) =>
      [
        // const TextSpan(
        //   text: 'Privacy Policy\n\n',
        //   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        // ),
        const TextSpan(
          text:
              'TaskTracker respects your privacy. This policy explains what data we collect and how we use it.\n\n',
        ),
        TextSpan(
          text: '1. Information We Collect:\n',
          style: boldStyle,
        ),
        const TextSpan(
            text: '• Email address and password (via Firebase Authentication)\n'
                '• User role (Admin or User).\n'
                '• Reminder settings and theme preferences. \n'
                '• FCM token for push notifications. \n\n'),
        TextSpan(
          text: '2. How We Use Your Data:\n',
          style: boldStyle,
        ),
        const TextSpan(
            text: '• Authenticate and manage user sessions \n'
                '• Sync tasks between devices (via Firebase Firestore) \n'
                '• Provide timely task reminders. \n'
                '• Track progress metrics and performance. \n'
                '• Customize themes and permissions. \n'
                '• Allow Admins to send notifications. \n'),
        TextSpan(
            text: 'We never sell your personal data. \n\n',
            style: differentStyle),
        TextSpan(
          text: '3. Local & Cloud Storage:\n',
          style: boldStyle,
        ),
        const TextSpan(
            text: '• Offline data is stored securely in Hive. \n'
                '• Online data is managed using Firebase Firestore. \n'),
        TextSpan(
            text:
                'We do not collect or share data beyond task-tracking scope. \n\n',
            style: differentStyle),
        TextSpan(
          text: '4. Notifications:\n',
          style: boldStyle,
        ),
        const TextSpan(
            text: '• Flutter Local Notifications for device-based reminders \n'
                '• Firebase Cloud Messaging (FCM) for Admin-to-User announcements \n'),
        TextSpan(
            text:
                'Disabling notifications may limit task reminder functionality.\n\n',
            style: differentStyle),
        TextSpan(
          text: '5. Data Retention:\n',
          style: boldStyle,
        ),
        const TextSpan(
            text:
                'Data is retained as long as your account is active. If you delete your account, all associated data is permanently removed. \n\n'),
        TextSpan(
          text: '6. Your Rights:\n',
          style: boldStyle,
        ),
        const TextSpan(
            text: '• View or update your data via the Profile Screen \n'
                '• Delete all tasks or delete your account \n'
                '• Contact us with any questions or concerns \n\n'),
        TextSpan(
          text: '7. Policy Updates:\n',
          style: boldStyle,
        ),
        const TextSpan(
            text:
                'We may revise this policy periodically. You’ll be informed of significant changes through app notifications. \n\n'),
        TextSpan(
          text: '8. Contact\n',
          style: boldStyle,
        ),
        const TextSpan(
            text:
                'For questions or feedback regarding this Privacy Policy, email us at \n'),
        TextSpan(text: 'tasktrackerV3@gmail.com\n\n', style: linkStyle),
        TextSpan(
            text: 'We respect your privacy and aim to protect your trust. \n',
            style: differentStyle)
      ];
}
