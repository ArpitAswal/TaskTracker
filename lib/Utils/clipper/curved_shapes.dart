import 'package:flutter/material.dart';

class CurvedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    double width = size.width;
    double height = size.height;

    // This variable define for better understanding you can direct specify value in quadraticBezierTo method
    var controlPoint = Offset(width / 2, height);
    var endPoint = const Offset(0, 0);

    path.moveTo(0, 0); // Top-left corner
    path.lineTo(0, height); // Bottom-left corner
    path.lineTo(width, height); // Bottom-right corner
    path.lineTo(width, 0); // Top-right corner
    path.quadraticBezierTo(
        controlPoint.dx, controlPoint.dy, endPoint.dx, endPoint.dy);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
