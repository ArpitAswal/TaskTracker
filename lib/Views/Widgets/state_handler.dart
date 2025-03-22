import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../ViewModels/auth_provider.dart';
import '../Screens/login_screen.dart';
import '../Screens/onboarding_screen.dart';
import '../Screens/task_screen.dart';

class AuthStateHandler extends StatelessWidget {
  const AuthStateHandler({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        Widget screen;
        if (snapshot.connectionState == ConnectionState.waiting) {
          screen = const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else {
          if (snapshot.hasData && snapshot.data != null) {
            screen = (context.read<AuthenticateProvider>().notOnboarding)
                ? const TaskScreen()
                : const OnboardingScreen();
          } else {
            screen = const LoginScreen();
          }
        }

        // Wrap the screen with a fade transition
        return AnimatedSwitcher(
            duration: const Duration(milliseconds: 800),
            reverseDuration: const Duration(milliseconds: 800),
            switchInCurve: Curves.linear,
            switchOutCurve: Curves.linear,
            child: screen);
      },
    );
  }
}
