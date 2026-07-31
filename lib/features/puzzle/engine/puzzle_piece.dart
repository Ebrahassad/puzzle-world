import 'dart:ui' as ui;
import 'package:flutter/material.dart';


//==================================================
// نوع الحافة
//==================================================

enum EdgeType {

  flat,

  tab,     // نتوء خارج

  blank,   // فراغ داخل

}





//==================================================
// نموذج قطعة البازل
//==================================================

class PuzzlePiece {



  final String id;



  // مكان القطعة في الشبكة

  final int row;

  final int column;





  // الجزء الخاص بها من الصورة الأصلية

  final Rect sourceRect;





  // الحواف

  final EdgeType top;

  final EdgeType right;

  final EdgeType bottom;

  final EdgeType left;





  // شكل القطعة

  late Path path;





  PuzzlePiece({

    required this.id,

    required this.row,

    required this.column,

    required this.sourceRect,

    required this.top,

    required this.right,

    required this.bottom,

    required this.left,

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





    path.moveTo(

      0,

      0,

    );





    // الأعلى

    _horizontal(

      path,

      w,

      top,

      tab,

      true,

    );





    // اليمين

    _vertical(

      path,

      h,

      right,

      tab,

      true,

    );





    // الأسفل

    _horizontal(

      path,

      w,

      bottom,

      tab,

      false,

    );





    // اليسار

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
  // حافة أفقية
  //==================================================

  static void _horizontal(

      Path path,

      double length,

      EdgeType type,

      double tab,

      bool top,

      ) {



    final y = top ? 0.0 : length;



    if(type == EdgeType.flat) {



      path.lineTo(

        length,

        y,

      );



      return;

    }







    final center = length / 2;



    final direction =

    top ? -1 : 1;



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
  // حافة عمودية
  //==================================================

  static void _vertical(

      Path path,

      double length,

      EdgeType type,

      double tab,

      bool right,

      ) {



    final x = right ? length : 0.0;



    if(type == EdgeType.flat) {



      path.lineTo(

        x,

        length,

      );



      return;

    }







    final center = length / 2;



    final direction =

    right ? 1 : -1;



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