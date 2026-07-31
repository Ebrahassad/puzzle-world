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

      ..color = Colors.white.withOpacity(0.65)

      ..strokeWidth = 8

      ..style = PaintingStyle.stroke

      ..strokeCap = StrokeCap.round;



    final path = Path();



    if (positions.isEmpty) return;



    path.moveTo(
      size.width * positions[0].dx + 65,
      size.height * (0.58 + positions[0].dy) + 65,
    );



    for(int i = 1; i < positions.length; i++) {


      path.quadraticBezierTo(

        size.width * positions[i].dx + 65,

        size.height * (0.58 + positions[i].dy) + 20,

        size.width * positions[i].dx + 65,

        size.height * (0.58 + positions[i].dy) + 65,

      );


    }



    canvas.drawPath(
      path,
      paint,
    );

  }



  @override
  bool shouldRepaint(
    CustomPainter oldDelegate,
  ) {

    return true;

  }

}