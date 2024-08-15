
 import 'package:flutter/material.dart';

Widget taskStatusWidget({required String text, required Color bgColor, required Color shdColor, required Color bodColor, required Color textColor, required void Function() onPressed, }){

  return ElevatedButton(onPressed: onPressed,
      style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(21.0)
          ),
          elevation: 5,
          shadowColor: shdColor,
          side: BorderSide(
              color: bodColor,
              width: 2
          )
      ),
      child: Text(text,
          style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold
          )));
 }