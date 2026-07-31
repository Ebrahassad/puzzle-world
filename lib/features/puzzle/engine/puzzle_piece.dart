import 'package:flutter/material.dart';





enum EdgeType {

  flat,

  tab,

  blank,

}







class PuzzlePiece {



  final String id;



  final int row;


  final int column;



  final int correctPosition;



  final Rect sourceRect;





  final EdgeType top;


  final EdgeType right;


  final EdgeType bottom;


  final EdgeType left;






  Offset position;



  Offset? dragOffset;



  bool placed;







  PuzzlePiece({

    required this.id,


    required this.row,


    required this.column,


    required this.correctPosition,


    required this.sourceRect,


    required this.top,


    required this.right,


    required this.bottom,


    required this.left,


    required this.position,


    this.placed = false,


    this.dragOffset,


  });







  double get x => position.dx;



  double get y => position.dy;







  // المكان الصحيح داخل اللوحة

  Offset correctOffset(

    double pieceSize,

  ) {



    return Offset(

      column * pieceSize,


      row * pieceSize,

    );


  }







  // تحريك القطعة

  void move(

    Offset delta,

  ) {



    if(placed) return;



    position += delta;


  }







  // تثبيت القطعة

  void lock(

    double pieceSize,

  ) {



    position = correctOffset(

      pieceSize,

    );



    placed = true;



    dragOffset = null;


  }

  //==================================================
  // فك التثبيت
  //==================================================

  void unlock() {


    placed = false;


  }







  //==================================================
  // إعادة القطعة
  //==================================================

  void reset() {


    position = Offset.zero;


    dragOffset = null;


    placed = false;


  }







  //==================================================
  // فحص قرب المكان الصحيح
  //==================================================

  bool isCorrect(

    double pieceSize,

    double tolerance,

  ) {



    final target =

        correctOffset(

          pieceSize,

        );





    return

        (position - target)

            .distance <= tolerance;


  }







  //==================================================
  // نسخة من القطعة
  //==================================================

  PuzzlePiece copyWith({

    Offset? position,


    bool? placed,


    Offset? dragOffset,


  }) {



    return PuzzlePiece(


      id: id,


      row: row,


      column: column,


      correctPosition:

          correctPosition,



      sourceRect:

          sourceRect,



      top:

          top,



      right:

          right,



      bottom:

          bottom,



      left:

          left,



      position:

          position ?? this.position,



      placed:

          placed ?? this.placed,



      dragOffset:

          dragOffset ?? this.dragOffset,

    );


  }







  //==================================================
  // حفظ الحالة
  //==================================================

  Map<String,dynamic> toJson() {



    return {


      "id": id,


      "row": row,


      "column": column,


      "correctPosition":

          correctPosition,


      "x":

          position.dx,


      "y":

          position.dy,


      "placed":

          placed,


    };


  }







  //==================================================
  // مقارنة القطع
  //==================================================

  @override

  bool operator ==(

    Object other,

  ) {



    return identical(

      this,

      other,

    )

    ||

    other is PuzzlePiece

    &&

    other.id == id;


  }







  @override

  int get hashCode => id.hashCode;







  @override

  String toString() {


    return

        "PuzzlePiece(id:$id,row:$row,column:$column,placed:$placed)";


  }



}