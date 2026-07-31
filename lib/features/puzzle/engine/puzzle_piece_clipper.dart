import 'package:flutter/material.dart';

import 'puzzle_piece.dart';





class PuzzlePieceClipper extends CustomClipper<Path> {



  final PuzzlePiece piece;





  PuzzlePieceClipper({

    required this.piece,

  });







  @override

  Path getClip(

    Size size,

  ) {



    final path = Path();





    final w = size.width;


    final h = size.height;






    const double tabSize = 0.18;





    path.moveTo(

      0,

      0,

    );







    //==================================
    // الحافة العلوية
    //==================================


    if(piece.top == EdgeType.flat) {


      path.lineTo(

        w,

        0,

      );


    }

    else {


      path.lineTo(

        w * 0.35,

        0,

      );



      path.cubicTo(

        w * 0.35,

        h * -tabSize,



        w * 0.65,

        h * -tabSize,



        w * 0.65,

        0,

      );



      path.lineTo(

        w,

        0,

      );


    }







    //==================================
    // الحافة اليمنى
    //==================================


    if(piece.right == EdgeType.flat) {


      path.lineTo(

        w,

        h,

      );


    }

    else {


      path.lineTo(

        w,

        h * 0.35,

      );



      path.cubicTo(

        w + w * tabSize,

        h * 0.35,



        w + w * tabSize,

        h * 0.65,



        w,

        h * 0.65,

      );



      path.lineTo(

        w,

        h,

      );


    }

    //==================================
    // الحافة السفلية
    //==================================


    if(piece.bottom == EdgeType.flat) {


      path.lineTo(

        0,

        h,

      );


    }

    else {


      path.lineTo(

        w * 0.65,

        h,

      );



      path.cubicTo(

        w * 0.65,

        h + h * tabSize,



        w * 0.35,

        h + h * tabSize,



        w * 0.35,

        h,

      );



      path.lineTo(

        0,

        h,

      );


    }







    //==================================
    // الحافة اليسرى
    //==================================


    if(piece.left == EdgeType.flat) {


      path.lineTo(

        0,

        0,

      );


    }

    else {


      path.lineTo(

        0,

        h * 0.65,

      );



      path.cubicTo(

        w * -tabSize,

        h * 0.65,



        w * -tabSize,

        h * 0.35,



        0,

        h * 0.35,

      );



      path.lineTo(

        0,

        0,

      );


    }






    path.close();





    return path;


  }







  @override

  bool shouldReclip(

    covariant PuzzlePieceClipper oldClipper,

  ) {


    return

        oldClipper.piece.top != piece.top

        ||

        oldClipper.piece.right != piece.right

        ||

        oldClipper.piece.bottom != piece.bottom

        ||

        oldClipper.piece.left != piece.left;


  }



}