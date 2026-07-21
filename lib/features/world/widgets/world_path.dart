import 'package:flutter/material.dart';

import 'path_painter.dart';



class WorldPath extends StatelessWidget {


  final List<Offset> points;



  const WorldPath({

    super.key,

    required this.points,

  });



  @override
  Widget build(BuildContext context) {


    return CustomPaint(


      size:

      MediaQuery.of(context).size,



      painter:

      PathPainter(

        points:points,

      ),


    );


  }

}