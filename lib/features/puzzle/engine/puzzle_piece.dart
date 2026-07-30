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





  // مكان القطعة داخل الشاشة/اللوحة

  Offset position;



  // مكان القطعة أثناء السحب

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







  Offset get gridPosition {


    return Offset(

      column.toDouble(),

      row.toDouble(),

    );


  }








  // المكان النهائي داخل لوحة البازل

  Offset correctOffset(

    double pieceSize,

  ) {


    return Offset(

      column * pieceSize,

      row * pieceSize,

    );


  }







  // تحريك القطعة

  void moveTo(

    Offset value,

  ) {


    if (placed) return;



    position = value;


  }







  // تحديث مكان السحب

  void setPosition(

    Offset value,

  ) {


    if (!placed) {


      position = value;


    }


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







  // فك التثبيت

  void unlock() {


    placed = false;


  }







  // إعادة القطعة

  void reset() {


    position = Offset.zero;


    dragOffset = null;


    placed = false;


  }







  // فحص قرب القطعة من مكانها

  bool isCorrect(

    double pieceSize,

    double tolerance,

  ) {


    final target = correctOffset(

      pieceSize,

    );



    final distance =

        (position - target).distance;



    return distance <= tolerance;


  }







  // نسخة جديدة

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

  // حفظ حالة القطعة

  Map<String, dynamic> toJson() {


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







  // استرجاع حالة القطعة

  factory PuzzlePiece.fromJson(

    Map<String, dynamic> json,

  ) {


    return PuzzlePiece(


      id:

          json["id"]?.toString() ?? "",


      row:

          json["row"] ?? 0,


      column:

          json["column"] ?? 0,


      correctPosition:

          json["correctPosition"] ?? 0,



      // يتم إعادة بناء الصورة من الـ Generator

      sourceRect:

          Rect.zero,



      top:

          EdgeType.flat,


      right:

          EdgeType.flat,


      bottom:

          EdgeType.flat,


      left:

          EdgeType.flat,



      position:

          Offset(

            (json["x"] ?? 0).toDouble(),

            (json["y"] ?? 0).toDouble(),

          ),



      placed:

          json["placed"] ?? false,


    );


  }







  @override

  bool operator ==(

    Object other,

  ) {


    return identical(

      this,

      other,

    ) ||


        other is PuzzlePiece &&

        other.id == id;


  }







  @override

  int get hashCode =>

      id.hashCode;







  @override

  String toString() {


    return

    "PuzzlePiece("

    "id:$id, "

    "row:$row, "

    "column:$column, "

    "position:$position, "

    "placed:$placed"

    ")";


  }


}