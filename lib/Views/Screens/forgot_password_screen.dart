import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Utils/clipper/curved_shapes.dart';
import '../../Utils/colors/app_colors.dart';
import '../../ViewModels/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Invalid email address';
    }
    return null;
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      final success = await context
          .read<AuthenticateProvider>()
          .sendPasswordResetEmail(_emailController.text);
      if (success && mounted) {
        _emailController.text = "";
        _popBack();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 24.0),
                child: Column(children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _popBack,
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),
                  Text(
                    'Forget Password',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your email and we will send you a password reset link',
                    style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.blueColor),
                  ),
                  SizedBox(height: size.height * 0.03),
                  TextFormField(
                    controller: _emailController,
                    validator: _validateEmail,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: AppColors.textColor,
                          ),
                          borderRadius: BorderRadius.circular(8.0)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: const BorderSide(
                          color: AppColors.blueColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),
                  Selector<AuthenticateProvider, bool>(
                    builder:
                        (BuildContext context, bool loading, Widget? child) {
                      return Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width / 3,
                          height: 45,
                          child: ElevatedButton(
                            onPressed: _handleSubmit,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.blueColor,
                                foregroundColor: AppColors.whiteColor,
                                elevation: 8.0,
                                shadowColor: AppColors.blueColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24.0),
                                    side: const BorderSide(
                                        color: AppColors.whiteColor,
                                        width: 2.0))),
                            child: loading
                                ? const SizedBox(
                                    height: 40,
                                    width: 40,
                                    child: CircularProgressIndicator(
                                      color: AppColors.whiteColor,
                                    ),
                                  )
                                : const Text('Submit'),
                          ),
                        ),
                      );
                    },
                    selector: (_, provider) => provider.loginLoading,
                  ),
                ]),
              ),
            ),
            const Spacer(),
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25)
                      .copyWith(bottom: 30),
                  child: Image.asset(
                    "assets/images/login_page.png",
                    fit: BoxFit.contain,
                    height: size.height * 0.3,
                  ),
                ),
                ClipPath(
                  clipper: CurvedClipper(),
                  child: Container(
                    width: size.width,
                    height: size.height * 0.2,
                    color: AppColors.blueColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _popBack() {
    Navigator.pop(context);
  }
}
