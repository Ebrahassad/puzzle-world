import 'package:flutter/material.dart';


class LevelPathPainter extends CustomPainter {


  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {

    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;


    final path = Path();


    path.moveTo(
      size.width * 0.25,
      size.height * 0.05,
    );


    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.15,
      size.width * 0.25,
      size.height * 0.30,
    );


    canvas.drawPath(
      path,
      paint,
    );

  }


  @override
  bool shouldRepaint(
    CustomPainter oldDelegate,
  ) {
    return false;
  }
}