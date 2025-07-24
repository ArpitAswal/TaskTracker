import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_task/Utils/helpers/dynamic_context_widgets.dart';

import '../../Utils/colors/app_colors.dart';
import '../../Utils/clipper/curved_shapes.dart';
import '../../ViewModels/auth_provider.dart';
import '../../ViewModels/setting_provider.dart';
import '../Widgets/state_handler.dart';
import '../Widgets/text_form_fields.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _adminKeyController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passFocusNode = FocusNode();
  final FocusNode _adminFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(_onEmailFocusChange);
    _passFocusNode.addListener(_onPassFocusChange);
    _adminFocusNode.addListener(_onAdminFocusChange);
  }

  @override
  void dispose() {
    _emailFocusNode.removeListener(_onEmailFocusChange);
    _emailFocusNode.dispose();
    _passFocusNode.removeListener(_onPassFocusChange);
    _passFocusNode.dispose();
    _adminFocusNode.removeListener(_onAdminFocusChange);
    _adminFocusNode.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _adminKeyController.dispose();
    super.dispose();
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

  void _onAdminFocusChange() {
    context
        .read<AuthenticateProvider>()
        .adminFocusChange(_adminFocusNode.hasFocus);
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final AuthenticateProvider auth = context.read<AuthenticateProvider>();
    final success = await auth.register(_emailController.text,
        _passwordController.text, _adminKeyController.text);

    if (success && mounted) {
      auth.getUserPreference();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthStateHandler()),
      );
    } else {
      DynamicContextWidgets().showSnackbar(auth.error ?? "An error occurred");
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: CustomScrollView(slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 45.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(height: size.height * 0.025),
                        Image.asset(
                          "assets/images/signup_page.png",
                          fit: BoxFit.cover,
                          height: size.height * 0.2,
                        ),
                        SizedBox(height: size.height * 0.025),
                        Text("Welcome",
                            style: TextStyle(
                                fontSize: 26,
                                height: size.height * 0.0025,
                                fontWeight: FontWeight.bold,
                                color: AppColors.blackColor)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 45),
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
                        SizedBox(height: size.height * 0.02),
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
                        SizedBox(height: size.height * 0.02),
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
                        SizedBox(height: size.height * 0.02),
                        if (context
                                .watch<AuthenticateProvider>()
                                .selectedRole ==
                            'Admin')
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: EmailTextField(
                              controller: _adminKeyController,
                              labelText: "Admin Key",
                              prefixIcon: Icons.key,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Admin key is required';
                                }
                                return null;
                              },
                              focusNode: _adminFocusNode,
                            ),
                          ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FormField<String>(
                            validator: (value) {
                              if (context
                                      .read<AuthenticateProvider>()
                                      .selectedRole ==
                                  "Select") {
                                return 'Please select a role';
                              }
                              return null;
                            },
                            builder: (FormFieldState<String> state) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    margin: EdgeInsets.zero,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    decoration: BoxDecoration(
                                        color: AppColors.blueColor,
                                        borderRadius:
                                            BorderRadius.circular(8.0)),
                                    child:
                                        Selector<AuthenticateProvider, String>(
                                      builder: (BuildContext context,
                                          String value, Widget? child) {
                                        return Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize
                                              .min, // Take only necessary space
                                          children: [
                                            Text('Role:',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyLarge
                                                    ?.copyWith(
                                                        color: AppColors
                                                            .whiteColor)),
                                            const SizedBox(width: 8),
                                            DropdownButton<String>(
                                              value: value,
                                              dropdownColor:
                                                  AppColors.blueColor,
                                              autofocus: true,
                                              alignment:
                                                  AlignmentDirectional.center,
                                              iconEnabledColor:
                                                  AppColors.whiteColor,
                                              onChanged: (String? newValue) {
                                                context
                                                    .read<
                                                        AuthenticateProvider>()
                                                    .changeRole(newValue!);
                                              },
                                              items: <String>[
                                                'Select',
                                                'User',
                                                'Admin',
                                              ].map<DropdownMenuItem<String>>(
                                                  (String value) {
                                                return DropdownMenuItem<String>(
                                                  value: value,
                                                  alignment:
                                                      AlignmentDirectional
                                                          .center,
                                                  child: Text(value,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge
                                                          ?.copyWith(
                                                              color: AppColors
                                                                  .whiteColor)),
                                                );
                                              }).toList(),
                                            ),
                                          ],
                                        );
                                      },
                                      selector: (context, provider) =>
                                          provider.selectedRole,
                                    ),
                                  ),
                                  if (state.hasError)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 12, top: 8),
                                      child: Text(
                                        state.errorText!,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
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
                          onPressed: _handleRegister,
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
                                  : const Text("Register",
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: AppColors.whiteColor));
                            },
                            selector: (context, provider) =>
                                provider.loginLoading,
                          ),
                        ),
                      ],
                    ),
                  ),
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
        )
      ]),
    );
  }
}

class BoolPair {
  // Instance Variables
  bool? first;
  bool? second;
  // Parameterized Constructor
  BoolPair(this.first, this.second);
}
