import 'package:flutter/material.dart';



enum EdgeType {

  flat,

  tab,

  blank,

}





class PuzzlePiece {



  // معرف القطعة

  final String id;



  // مكانها الصحيح في الشبكة

  final int row;


  final int column;





  // رقم المكان الصحيح

  final int correctPosition;





  // مكان قصها من الصورة الأصلية

  final Rect sourceRect;





  // حواف القطعة

  final EdgeType top;


  final EdgeType bottom;


  final EdgeType left;


  final EdgeType right;





  // مكانها الحالي

  Offset position;





  // هل تم تركيبها

  bool placed;







  PuzzlePiece({



    required this.id,



    required this.row,



    required this.column,



    required this.correctPosition,



    required this.sourceRect,



    required this.top,



    required this.bottom,



    required this.left,



    required this.right,



    required this.position,



    this.placed = false,



  });









  // المكان الصحيح على اللوحة

  Offset get correctOffset {



    return Offset(



      column.toDouble(),



      row.toDouble(),



    );



  }









  // تثبيت القطعة بالتلميح

  void placeHint(double pieceSize){



    position = Offset(



      column * pieceSize,



      row * pieceSize,



    );



    placed = true;



  }









  // إعادة القطعة

  void reset(){



    position = Offset.zero;



    placed = false;



  }









  // حفظ البيانات

  Map<String,dynamic> toJson(){



    return {



      "id":id,


      "row":row,


      "column":column,


      "x":position.dx,


      "y":position.dy,


      "placed":placed,



    };



  }









  // استرجاع البيانات

  factory PuzzlePiece.fromJson(

      Map<String,dynamic> json,

      ){



    return PuzzlePiece(



      id:json['id'].toString(),



      row:json['row'],



      column:json['column'],



      correctPosition:

      json['row'] * 100 +

          json['column'],



      sourceRect:

      Rect.zero,



      top:EdgeType.flat,


      bottom:EdgeType.flat,


      left:EdgeType.flat,


      right:EdgeType.flat,



      position:Offset(



        (json['x'] ?? 0).toDouble(),



        (json['y'] ?? 0).toDouble(),



      ),



      placed:

      json['placed'] ?? false,



    );



  }



}