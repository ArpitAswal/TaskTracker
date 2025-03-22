import 'package:flutter/material.dart';

extension CustomElevatedButtonStyles on ThemeData {
  ButtonStyle primaryElevatedButtonStyle(BuildContext context,
      {required double minWidth, required double borderRadius}) {
    return ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.secondary,
        minimumSize: Size(minWidth, 45),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: BorderSide(
                color: Theme.of(context).colorScheme.secondary, width: 2.0)),
        elevation: 8.0,
        shadowColor: Theme.of(context).colorScheme.tertiary,
        textStyle: Theme.of(context)
            .textTheme
            .bodyLarge
            ?.copyWith(fontWeight: FontWeight.bold),
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.center);
  }

  ButtonStyle secondaryElevatedButtonStyle(BuildContext context,
      {required double minWidth, required double borderRadius}) {
    return ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        foregroundColor: Theme.of(context).colorScheme.primary,
        minimumSize: Size(minWidth, 45),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: BorderSide(
                color: Theme.of(context).colorScheme.primary, width: 2.0)),
        elevation: 8.0,
        shadowColor: Theme.of(context).colorScheme.primary,
        textStyle: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.center);
  }
}
