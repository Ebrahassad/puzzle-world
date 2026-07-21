import 'package:flutter/material.dart';


class PathPainter extends CustomPainter {


  final List<Offset> points;


  PathPainter({

    required this.points,

  });



  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {


    if(points.length < 2) return;



    final paint = Paint()


      ..color = Colors.white.withOpacity(.8)


      ..strokeWidth = 8


      ..style = PaintingStyle.stroke;



    final path = Path();



    path.moveTo(

      points.first.dx,

      points.first.dy,

    );



    for(int i = 1; i < points.length; i++){



      path.lineTo(

        points[i].dx,

        points[i].dy,

      );



    }



    canvas.drawPath(

      path,

      paint,

    );



  }




  @override

  bool shouldRepaint(

      covariant CustomPainter oldDelegate,

      ){

    return true;

  }


}