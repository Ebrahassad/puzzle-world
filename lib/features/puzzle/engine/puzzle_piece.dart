import 'dart:ui';
import 'package:flutter/material.dart';


//==================================================
// نوع الحافة
//==================================================

enum EdgeType {
  flat,
  tab,
  blank,
}


//==================================================
// حالة القطعة
//==================================================

enum PieceState {
  tray,       // داخل الشريط
  board,      // على اللوحة
  locked,     // مثبتة
}


//==================================================
// نموذج قطعة البازل
//==================================================

class PuzzlePiece {


  final String id;


  // مكانها الأصلي
  final int row;
  final int column;


  // مكانها في الصورة
  final Rect sourceRect;


  // الحواف
  final EdgeType top;
  final EdgeType right;
  final EdgeType bottom;
  final EdgeType left;



  // مكانها الحالي على الشاشة
  Offset position;


  // مكانها الصحيح في اللوحة
  late Offset correctPosition;



  // شكل القطعة
  late Path path;



  // الحالة
  PieceState state;



  // هل يتم سحبها
  bool dragging;



  PuzzlePiece({

    required this.id,

    required this.row,

    required this.column,

    required this.sourceRect,

    required this.top,

    required this.right,

    required this.bottom,

    required this.left,


    required this.position,


    this.state = PieceState.tray,


    this.dragging = false,

  });






  //==================================================
  // إنشاء شكل القطعة
  //==================================================

  void createShape(

      Size size,

      ) {


    path = PuzzleShapeBuilder.build(

      size: size,

      top: top,

      right: right,

      bottom: bottom,

      left: left,

    );


  }






  //==================================================
  // تحديد مكانها الصحيح
  //==================================================

  void setCorrectPosition(

      double pieceSize,

      ) {


    correctPosition = Offset(

      column * pieceSize,

      row * pieceSize,

    );


  }






  //==================================================
  // هل قريبة من المكان الصحيح
  //==================================================

  bool isCorrect(

      double tolerance,

      ) {


    return (

        position -

            correctPosition

    )

        .distance <= tolerance;


  }







  //==================================================
  // تثبيت القطعة
  //==================================================

  void lock() {


    position = correctPosition;


    state = PieceState.locked;


    dragging = false;


  }







  //==================================================
  // بداية السحب
  //==================================================

  void startDrag() {


    if(state == PieceState.locked) {

      return;

    }


    dragging = true;


    state = PieceState.board;


  }







  //==================================================
  // تحريك
  //==================================================

  void move(

      Offset delta,

      ) {


    if(state == PieceState.locked) {

      return;

    }


    position += delta;


  }







  //==================================================
  // نهاية السحب
  //==================================================

  void endDrag() {


    dragging = false;


  }


}






//==================================================
// بناء شكل القطعة
//==================================================

class PuzzleShapeBuilder {


  static Path build({

    required Size size,

    required EdgeType top,

    required EdgeType right,

    required EdgeType bottom,

    required EdgeType left,

  }) {



    final path = Path();


    final w = size.width;

    final h = size.height;


    final tab = w * 0.22;



    path.moveTo(0,0);



    _horizontal(
      path,
      w,
      top,
      tab,
      true,
    );



    _vertical(
      path,
      h,
      right,
      tab,
      true,
    );



    _horizontal(
      path,
      w,
      bottom,
      tab,
      false,
    );



    _vertical(
      path,
      h,
      left,
      tab,
      false,
    );


    path.close();


    return path;

  }






  static void _horizontal(

      Path path,

      double length,

      EdgeType type,

      double tab,

      bool top,

      ) {


    final y = top ? 0.0 : length;



    if(type == EdgeType.flat){

      path.lineTo(
        length,
        y,
      );

      return;

    }



    final center = length / 2;


    final direction = top ? -1 : 1;


    final amount =
        type == EdgeType.tab
            ? direction * tab
            : -direction * tab;



    path.lineTo(
      center-tab,
      y,
    );


    path.cubicTo(
      center-tab,
      y,
      center-tab/2,
      y+amount,
      center,
      y+amount,
    );


    path.cubicTo(
      center+tab/2,
      y+amount,
      center+tab,
      y,
      center+tab,
      y,
    );


    path.lineTo(
      length,
      y,
    );

  }







  static void _vertical(

      Path path,

      double length,

      EdgeType type,

      double tab,

      bool right,

      ) {


    final x = right ? length : 0.0;



    if(type == EdgeType.flat){

      path.lineTo(
        x,
        length,
      );

      return;

    }



    final center = length/2;


    final direction = right ? 1 : -1;


    final amount =
        type == EdgeType.tab
            ? direction*tab
            : -direction*tab;



    path.lineTo(
      x,
      center-tab,
    );



    path.cubicTo(
      x,
      center-tab,
      x+amount,
      center-tab/2,
      x+amount,
      center,
    );



    path.cubicTo(
      x+amount,
      center+tab/2,
      x,
      center+tab,
      x,
      center+tab,
    );


    path.lineTo(
      x,
      length,
    );

  }

}