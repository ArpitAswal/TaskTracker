import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';

class SettingsCard {
  static Widget infoCard(
    BuildContext context, {
    required dynamic tap,
    required IconData icon,
    required String label,
    Widget? child, required bool border,
  }) {
    return Card(
      color: Theme.of(context).scaffoldBackgroundColor,
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: (border) ? Colors.white : Colors.transparent)
      ),
      shadowColor: Theme.of(context).primaryColor,
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: EdgeInsets.all((child != null) ? 12 : 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
             Icon(icon, color: Theme.of(context).primaryColor),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.02,
            ),
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).primaryColor
              ),),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.02,
            ),
            child ??
                InkWell(
                    onTap: (){
                      tap();
                    },
                    splashColor: Colors.transparent,
                  child:
                Icon(Icons.arrow_forward_ios, color: Theme.of(context).primaryColor))
          ],
        ),
      ),
    );
  }

  static flutterSwitchCard({required bool value, required Color toggleColor, required BuildContext context, required Color borderColor, required IconData activeIcon, required IconData inactiveIcon, required Color activeIconColor, required Color inactiveIconColor, required void Function() toggle}) {
    Size size = MediaQuery.of(context).size;
    return  FlutterSwitch(
        width: size.width * 0.15,
        height: size.height * 0.04,
        toggleSize: size.height * 0.025,
        padding: 2.0,
        value: value,
        borderRadius: 32.0,
        activeToggleColor: borderColor,
        inactiveToggleColor: borderColor,
        activeSwitchBorder: Border.all(
          color: borderColor,
          width: 3.0,
        ),
        inactiveSwitchBorder: Border.all(
          color: borderColor,
          width: 3.0,
        ),
        activeColor: toggleColor,
        inactiveColor: toggleColor,
        activeIcon: Icon(
            activeIcon,
            color: activeIconColor
        ),
        inactiveIcon: Icon(
            inactiveIcon,
            color: inactiveIconColor
        ),
        onToggle: (val) {
          toggle();
        }
    );
    }
}
