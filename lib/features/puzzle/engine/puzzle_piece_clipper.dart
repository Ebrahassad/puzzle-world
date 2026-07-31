import 'package:flutter/material.dart';

import 'puzzle_piece.dart';


///======================================================
/// مسؤول عن رسم شكل قطعة البازل
/// (نتوءات + تجاويف + حواف مستقيمة)
///======================================================

class PuzzlePieceClipper extends CustomClipper<Path> {


  final PuzzlePiece piece;


  const PuzzlePieceClipper({

    required this.piece,

  });




  @override
  Path getClip(
    Size size,
  ) {


    final path =
        Path();



    final w =
        size.width;



    final h =
        size.height;



    final tab =
        piece.tabSize;




    // البداية من أعلى اليسار

    path.moveTo(
      0,
      0,
    );



    //==================================================
    // الحافة العلوية
    //==================================================

    _drawTopEdge(

      path,

      w,

      h,

      tab,

      piece.top.type,

    );



    //==================================================
    // الحافة اليمنى
    //==================================================

    _drawRightEdge(

      path,

      w,

      h,

      tab,

      piece.right.type,

    );



    //==================================================
    // الحافة السفلية
    //==================================================

    _drawBottomEdge(

      path,

      w,

      h,

      tab,

      piece.bottom.type,

    );



    //==================================================
    // الحافة اليسرى
    //==================================================

    _drawLeftEdge(

      path,

      w,

      h,

      tab,

      piece.left.type,

    );



    path.close();



    return path;

  }



  //====================================================
  // رسم الحافة العلوية
  //====================================================

  void _drawTopEdge(

    Path path,

    double w,

    double h,

    double tab,

    EdgeType type,

  ) {


    switch(type) {


      case EdgeType.flat:

        path.lineTo(
          w,
          0,
        );

        break;



      case EdgeType.tab:

        path.lineTo(
          w * 0.35,
          0,
        );


        path.cubicTo(

          w * 0.35,

          -tab,

          w * 0.65,

          -tab,

          w * 0.65,

          0,

        );


        path.lineTo(
          w,
          0,
        );

        break;



      case EdgeType.blank:

        path.lineTo(
          w * 0.35,
          0,
        );


        path.cubicTo(

          w * 0.35,

          tab,

          w * 0.65,

          tab,

          w * 0.65,

          0,

        );


        path.lineTo(
          w,
          0,
        );

        break;

    }

  }

  //====================================================
  // رسم الحافة اليمنى
  //====================================================

  void _drawRightEdge(

    Path path,

    double w,

    double h,

    double tab,

    EdgeType type,

  ) {


    switch(type) {


      case EdgeType.flat:

        path.lineTo(
          w,
          h,
        );

        break;



      case EdgeType.tab:

        path.lineTo(
          w,
          h * 0.35,
        );


        path.cubicTo(

          w + tab,

          h * 0.35,

          w + tab,

          h * 0.65,

          w,

          h * 0.65,

        );


        path.lineTo(
          w,
          h,
        );

        break;



      case EdgeType.blank:

        path.lineTo(
          w,
          h * 0.35,
        );


        path.cubicTo(

          w - tab,

          h * 0.35,

          w - tab,

          h * 0.65,

          w,

          h * 0.65,

        );


        path.lineTo(
          w,
          h,
        );

        break;

    }

  }




  //====================================================
  // رسم الحافة السفلية
  //====================================================

  void _drawBottomEdge(

    Path path,

    double w,

    double h,

    double tab,

    EdgeType type,

  ) {


    switch(type) {


      case EdgeType.flat:

        path.lineTo(
          0,
          h,
        );

        break;



      case EdgeType.tab:

        path.lineTo(
          w * 0.65,
          h,
        );


        path.cubicTo(

          w * 0.65,

          h + tab,

          w * 0.35,

          h + tab,

          w * 0.35,

          h,

        );


        path.lineTo(
          0,
          h,
        );

        break;



      case EdgeType.blank:

        path.lineTo(
          w * 0.65,
          h,
        );


        path.cubicTo(

          w * 0.65,

          h - tab,

          w * 0.35,

          h - tab,

          w * 0.35,

          h,

        );


        path.lineTo(
          0,
          h,
        );

        break;

    }

  }




  //====================================================
  // رسم الحافة اليسرى
  //====================================================

  void _drawLeftEdge(

    Path path,

    double w,

    double h,

    double tab,

    EdgeType type,

  ) {


    switch(type) {


      case EdgeType.flat:

        path.lineTo(
          0,
          0,
        );

        break;



      case EdgeType.tab:

        path.lineTo(
          0,
          h * 0.65,
        );


        path.cubicTo(

          -tab,

          h * 0.65,

          -tab,

          h * 0.35,

          0,

          h * 0.35,

        );


        path.lineTo(
          0,
          0,
        );

        break;



      case EdgeType.blank:

        path.lineTo(
          0,
          h * 0.65,
        );


        path.cubicTo(

          tab,

          h * 0.65,

          tab,

          h * 0.35,

          0,

          h * 0.35,

        );


        path.lineTo(
          0,
          0,
        );

        break;

    }

  }





  @override
  bool shouldReclip(
    covariant PuzzlePieceClipper oldClipper,
  ) {

    return oldClipper.piece != piece;

  }

}