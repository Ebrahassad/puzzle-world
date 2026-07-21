import 'package:flutter/material.dart';

import 'puzzle_piece.dart';



class PuzzlePainter extends CustomPainter {


  final PuzzlePiece piece;

  final ImageProvider image;



  PuzzlePainter({

    required this.piece,

    required this.image,

  });



  @override

  void paint(

      Canvas canvas,

      Size size,

      ) {



    final paint = Paint();


    final path = _createPiecePath(size);



    canvas.save();



    canvas.clipPath(path);



    paintImage(

      canvas: canvas,

      rect: Rect.fromLTWH(

        0,

        0,

        size.width,

        size.height,

      ),

      image: image,

      fit: BoxFit.cover,

    );



    canvas.restore();



    canvas.drawPath(

      path,

      Paint()

        ..style = PaintingStyle.stroke

        ..strokeWidth = 2

        ..color = Colors.black26,

    );


  }





  Path _createPiecePath(Size size) {


    final path = Path();



    final w = size.width;

    final h = size.height;



    path.moveTo(0, 0);



    // top

    path.lineTo(w, 0);



    // right

    path.lineTo(

      w,

      h,

    );



    // bottom

    path.lineTo(

      0,

      h,

    );



    path.close();



    return path;


  }





  @override

  bool shouldRepaint(

      covariant PuzzlePainter oldDelegate,

      ) {


    return true;


  }


}