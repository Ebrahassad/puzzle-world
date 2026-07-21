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


    final path = createPiecePath(size);



    // ظل القطعة (إحساس 3D)

    canvas.save();


    canvas.translate(3, 5);


    canvas.drawPath(

      path,

      Paint()

        ..color = Colors.black26

        ..maskFilter = const MaskFilter.blur(

          BlurStyle.normal,

          6,

        ),

    );


    canvas.restore();




    // قص الصورة داخل القطعة

    canvas.save();


    canvas.clipPath(path);



    paintImage(

      canvas: canvas,

      rect: Offset.zero & size,

      image: image,

      fit: BoxFit.cover,

    );


    canvas.restore();





    // إطار القطعة

    canvas.drawPath(

      path,

      Paint()

        ..style = PaintingStyle.stroke

        ..strokeWidth = 2

        ..color = Colors.white70,

    );





    // لمعان بسيط

    canvas.drawPath(

      path,

      Paint()

        ..style = PaintingStyle.stroke

        ..strokeWidth = 1

        ..color = Colors.white,

    );



  }





  Path createPiecePath(Size size) {


    final path = Path();


    final w = size.width;

    final h = size.height;



    path.moveTo(0, 0);



    path.lineTo(w, 0);



    path.lineTo(w, h);



    path.lineTo(0, h);



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