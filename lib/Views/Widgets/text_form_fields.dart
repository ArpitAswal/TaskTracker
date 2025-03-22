import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Utils/colors/app_colors.dart';
import '../../ViewModels/auth_provider.dart';

class EmailTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String labelText;
  final IconData prefixIcon;
  final String? Function(String?)? validator;

  const EmailTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.labelText,
    this.validator,
    required this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<AuthenticateProvider, bool>(
      builder: (BuildContext context, value, Widget? child) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          validator: validator,
          cursorColor: AppColors.blueColor,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            labelText: labelText,
            prefixIcon: Icon(prefixIcon),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.greyColor),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.blueColor),
            ),
            prefixIconColor: value ? AppColors.blueColor : AppColors.greyColor,
            labelStyle: TextStyle(
              color: value ? AppColors.blueColor : AppColors.greyColor,
            ),
          ),
        );
      },
      selector: (_, provider) => provider.emailFocus,
    );
  }
}

class PasswordTextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String labelText;
  final String? Function(String?)? validator;

  const PasswordTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.labelText,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<AuthenticateProvider, BoolPair>(
      selector: (_, provider) =>
          BoolPair(provider.isObscured, provider.passFocus),
      builder: (BuildContext context, BoolPair value, Widget? child) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          obscureText: value.first!,
          validator: validator,
          style: Theme.of(context).textTheme.bodyLarge,
          cursorColor: AppColors.blueColor,
          decoration: InputDecoration(
            labelText: labelText,
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon:
                  Icon(value.first! ? Icons.visibility_off : Icons.visibility),
              color: value.second! ? AppColors.blueColor : AppColors.greyColor,
              onPressed: () {
                context.read<AuthenticateProvider>().toggleObscure();
              },
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.greyColor),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.blueColor),
            ),
            prefixIconColor:
                value.second! ? AppColors.blueColor : AppColors.greyColor,
            labelStyle: TextStyle(
              color: value.second! ? AppColors.blueColor : AppColors.greyColor,
            ),
          ),
        );
      },
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
