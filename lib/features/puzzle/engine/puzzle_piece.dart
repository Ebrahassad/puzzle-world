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

  board,      // خرجت للوحة

  locked,     // مثبتة

}


//==================================================
// نموذج قطعة البازل
//==================================================

class PuzzlePiece {


  final String id;


  // مكانها في الشبكة
  final int row;
  final int column;


  // الجزء المقصوص من الصورة
  final Rect sourceRect;



  // الحواف
  final EdgeType top;
  final EdgeType right;
  final EdgeType bottom;
  final EdgeType left;



  // مكانها الحالي
  Offset position;



  // مكانها داخل الشريط
  late Offset trayPosition;



  // مكانها الصحيح داخل اللوحة
  late Offset correctPosition;



  // حجم القطعة
  late Size size;



  // شكل القطعة
  late Path path;



  // الحالة
  PieceState state;



  // أثناء السحب
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


    this.size = size;


    path = PuzzleShapeBuilder.build(

      size: size,

      top: top,

      right: right,

      bottom: bottom,

      left: left,

    );


  }

  //==================================================
  // تحديد مكانها الصحيح في اللوحة
  //==================================================

  void setCorrectPosition(

      double pieceSize,

      Offset boardOffset,

      ) {


    correctPosition = Offset(

      boardOffset.dx +

          (column * pieceSize),


      boardOffset.dy +

          (row * pieceSize),

    );


  }







  //==================================================
  // تحديد مكانها في الشريط المتحرك
  //==================================================

  void setTrayPosition(

      Offset position,

      ) {


    trayPosition = position;


    this.position = position;


    state = PieceState.tray;


  }








  //==================================================
  // هل القطعة قريبة من مكانها
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
  // بدء السحب
  //==================================================

  void startDrag(){


    if(state == PieceState.locked){

      return;

    }


    dragging = true;


  }








  //==================================================
  // نقل القطعة
  //==================================================

  void move(

      Offset delta,

      ) {


    if(state == PieceState.locked){

      return;

    }


    position += delta;


  }








  //==================================================
  // نقل لمكان مباشر
  //==================================================

  void moveTo(

      Offset newPosition,

      ){


    if(state == PieceState.locked){

      return;

    }


    position = newPosition;


  }








  //==================================================
  // عند ترك القطعة
  //==================================================

  void endDrag(){


    dragging = false;


  }








  //==================================================
  // تثبيت القطعة
  //==================================================

  void lock(){


    position = correctPosition;


    state = PieceState.locked;


    dragging = false;


  }








  //==================================================
  // إعادة القطعة للشريط
  //==================================================

  void returnToTray(){


    position = trayPosition;


    state = PieceState.tray;


    dragging = false;


  }



}


//==================================================
// بناء شكل قطعة البازل
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



    path.moveTo(0, 0);



    // أعلى
    _horizontal(

      path,

      w,

      top,

      tab,

      true,

    );



    // يمين
    _vertical(

      path,

      h,

      right,

      tab,

      true,

    );



    // أسفل
    _horizontal(

      path,

      w,

      bottom,

      tab,

      false,

    );



    // يسار
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








  //==================================================
  // الحواف الأفقية
  //==================================================

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

      center - tab,

      y,

    );



    path.cubicTo(

      center - tab,

      y,

      center - tab / 2,

      y + amount,

      center,

      y + amount,

    );



    path.cubicTo(

      center + tab / 2,

      y + amount,

      center + tab,

      y,

      center + tab,

      y,

    );



    path.lineTo(

      length,

      y,

    );


  }








  //==================================================
  // الحواف العمودية
  //==================================================

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




    final center = length / 2;


    final direction = right ? 1 : -1;



    final amount =

        type == EdgeType.tab

            ? direction * tab

            : -direction * tab;





    path.lineTo(

      x,

      center - tab,

    );





    path.cubicTo(

      x,

      center - tab,

      x + amount,

      center - tab / 2,

      x + amount,

      center,

    );





    path.cubicTo(

      x + amount,

      center + tab / 2,

      x,

      center + tab,

      x,

      center + tab,

    );





    path.lineTo(

      x,

      length,

    );


  }


}