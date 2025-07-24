import 'dart:core';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_task/Models/auth_model.dart';
import 'package:todo_task/Utils/clipper/curved_shapes.dart';
import 'package:todo_task/Views/Screens/forgot_password_screen.dart';

import '../../Utils/helpers/dynamic_context_widgets.dart';
import '../../Utils/colors/app_colors.dart';
import '../../ViewModels/auth_provider.dart';
import '../../ViewModels/setting_provider.dart';
import '../Widgets/state_handler.dart';
import '../Widgets/text_form_fields.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passFocusNode = FocusNode();
  final dynMsg = DynamicContextWidgets();

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(_onEmailFocusChange);
    _passFocusNode.addListener(_onPassFocusChange);
    _fillData();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.removeListener(_onEmailFocusChange);
    _emailFocusNode.dispose();
    _passFocusNode.removeListener(_onPassFocusChange);
    _passFocusNode.dispose();
    super.dispose();
  }

  void _fillData(){
    final AuthenticateProvider auth = context.read<AuthenticateProvider>();
     AuthenticateModel? user = auth.rememberMeUser();
    _emailController.text = user?.email ?? "";
    _passwordController.text = user?.password ?? "";
  }

  void _onEmailFocusChange() {
    context
        .read<AuthenticateProvider>()
        .emailFocusChange(_emailFocusNode.hasFocus);
  }

  void _onPassFocusChange() {
    context
        .read<AuthenticateProvider>()
        .passFocusChange(_passFocusNode.hasFocus);
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final AuthenticateProvider auth = context.read<AuthenticateProvider>();

    final success = await auth.login(
      _emailController.text,
      _passwordController.text,
    );

    if (success) {
      auth.getUserPreference();
      auth.changePassword(pass: _passwordController.text);
      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (context) => const AuthStateHandler()),
      // );
    } else {
      print("else part calling again");
      dynMsg.showSnackbar(auth.error ?? "An error occurred");
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.whiteColor,
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 45.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: size.height * 0.05),
                          Text("Login",
                              style: TextStyle(
                                  fontSize: 21,
                                  height: size.height * 0.0025,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.blackColor)),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 45.0),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: const TextSpan(
                                text: "By signing in, you agree to our",
                                style: TextStyle(
                                    fontSize: 16, color: AppColors.textColor),
                                children: [
                                  TextSpan(
                                      text: " Terms & Privacy Policy. ",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.blueColor)),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: size.height * 0.025),
                          EmailTextField(
                              controller: _emailController,
                              focusNode: _emailFocusNode,
                              labelText: "Email Address",
                              prefixIcon: Icons.email,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Email is required';
                                }
                                if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                                    .hasMatch(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              }),
                          SizedBox(height: size.height * 0.025),
                          PasswordTextField(
                              controller: _passwordController,
                              focusNode: _passFocusNode,
                              labelText: "Password",
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Password is required';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              }),
                          SizedBox(height: size.height * 0.025),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Selector<AuthenticateProvider, bool>(
                                      builder: (BuildContext context,
                                          bool value, Widget? child) {
                                        return Checkbox(
                                            value: value,
                                            checkColor: AppColors.whiteColor,
                                            activeColor: AppColors.blueColor,
                                            focusColor: Colors.lightBlue,
                                            side: const BorderSide(
                                                color: AppColors.greyColor),
                                            splashRadius: 6,
                                            onChanged: (bool? value) {
                                              context
                                                  .read<AuthenticateProvider>()
                                                  .toggleRememberMe();
                                            });
                                      },
                                      selector: (context, provider) =>
                                          provider.isChecked),
                                  const Text("Remember me"),
                                ],
                              ),
                              TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const ForgotPasswordScreen()));
                                  },
                                  child: const Text("Forgot password?",
                                      style: TextStyle(
                                          color: AppColors.blueColor))),
                            ],
                          ),
                          SizedBox(height: size.height * 0.025),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.blueColor,
                              minimumSize: const Size(double.infinity, 45),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _handleLogin,
                            child: Selector<AuthenticateProvider, bool>(
                              builder: (BuildContext context, bool value,
                                  Widget? child) {
                                return (value)
                                    ? const Center(
                                        child: CircularProgressIndicator(
                                          color: AppColors.whiteColor,
                                          backgroundColor: AppColors.blueColor,
                                        ),
                                      )
                                    : const Text("Login",
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: AppColors.whiteColor));
                              },
                              selector: (context, provider) =>
                                  provider.loginLoading,
                            ),
                          ),
                          SizedBox(height: size.height * 0.005),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don't have an account?",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.textColor)),
                              TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const SignupScreen()));
                                  },
                                  child: const Text("Register",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                          decorationColor: AppColors.blueColor,
                                          color: AppColors.blueColor))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
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
        ],
      ),
    );
  }
}
