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



    // ظل 3D

    canvas.save();

    canvas.translate(3, 5);


    canvas.drawPath(

      path,

      Paint()

        ..color = Colors.black26

        ..maskFilter =
        const MaskFilter.blur(

          BlurStyle.normal,

          7,

        ),

    );


    canvas.restore();





    // الصورة داخل القطعة

    canvas.save();


    canvas.clipPath(path);



    paintImage(

      canvas: canvas,

      rect: Offset.zero & size,

      image: image,

      fit: BoxFit.cover,

    );



    canvas.restore();





    // حدود القطعة

    canvas.drawPath(

      path,

      Paint()

        ..style = PaintingStyle.stroke

        ..strokeWidth = 2

        ..color = Colors.white,

    );


  }





  Path createPiecePath(Size size) {


    final path = Path();


    final w = size.width;

    final h = size.height;



    final tab = w * 0.22;



    // بداية

    path.moveTo(0, 0);



    // الأعلى

    path.lineTo(w / 2 - tab, 0);



    if (piece.top == EdgeType.tab) {


      path.quadraticBezierTo(

        w / 2,

        -tab,

        w / 2 + tab,

        0,

      );


    }


    else if(piece.top == EdgeType.blank){


      path.quadraticBezierTo(

        w / 2,

        tab,

        w / 2 + tab,

        0,

      );


    }



    path.lineTo(w,0);




    // اليمين

    path.lineTo(w,h/2-tab);



    if(piece.right==EdgeType.tab){


      path.quadraticBezierTo(

        w+tab,

        h/2,

        w,

        h/2+tab,

      );


    }


    else if(piece.right==EdgeType.blank){


      path.quadraticBezierTo(

        w-tab,

        h/2,

        w,

        h/2+tab,

      );


    }



    path.lineTo(w,h);



    // الأسفل

    path.lineTo(w/2+tab,h);



    if(piece.bottom==EdgeType.tab){


      path.quadraticBezierTo(

        w/2,

        h+tab,

        w/2-tab,

        h,

      );


    }


    else if(piece.bottom==EdgeType.blank){


      path.quadraticBezierTo(

        w/2,

        h-tab,

        w/2-tab,

        h,

      );


    }



    path.lineTo(0,h);



    // اليسار

    path.lineTo(0,h/2+tab);



    if(piece.left==EdgeType.tab){


      path.quadraticBezierTo(

        -tab,

        h/2,

        0,

        h/2-tab,

      );


    }


    else if(piece.left==EdgeType.blank){


      path.quadraticBezierTo(

        tab,

        h/2,

        0,

        h/2-tab,

      );


    }



    path.close();



    return path;

  }





  @override

  bool shouldRepaint(

      covariant PuzzlePainter oldDelegate,

      ){

    return true;

  }

}