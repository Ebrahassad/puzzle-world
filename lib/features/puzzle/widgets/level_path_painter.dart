import 'package:flutter/material.dart';


class LevelPathPainter extends CustomPainter {

  final List<Offset> positions;


  LevelPathPainter({
    required this.positions,
  });


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


    if (positions.isEmpty) return;


    path.moveTo(
      size.width * positions.first.dx,
      size.height * positions.first.dy,
    );


    for (int i = 1; i < positions.length; i++) {

      final point = positions[i];

      path.quadraticBezierTo(
        size.width * ((positions[i - 1].dx + point.dx) / 2),
        size.height * ((positions[i - 1].dy + point.dy) / 2),

        size.width * point.dx,
        size.height * point.dy,
      );

    }


    canvas.drawPath(
      path,
      paint,
    );

  }


  @override
  bool shouldRepaint(
    LevelPathPainter oldDelegate,
  ) {

    return oldDelegate.positions != positions;

  }

}