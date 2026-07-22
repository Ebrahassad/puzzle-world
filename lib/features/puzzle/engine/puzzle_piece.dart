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


  final EdgeType bottom;


  final EdgeType left;


  final EdgeType right;




  Offset position;



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









  // الموقع الصحيح الحقيقي حسب حجم القطعة

  Offset correctOffset(double pieceSize){


    return Offset(

      column * pieceSize,

      row * pieceSize,

    );


  }









  // تثبيت القطعة بالتلميح

  void placeHint(double pieceSize){


    position = correctOffset(pieceSize);


    placed = true;


  }









  // إعادة القطعة

  void reset(){


    position = Offset.zero;


    placed = false;


  }









  // حفظ

  Map<String,dynamic> toJson(){


    return {


      "id":id,


      "row":row,


      "column":column,


      "correctPosition":correctPosition,


      "x":position.dx,


      "y":position.dy,


      "placed":placed,


    };


  }









  // تحميل

  factory PuzzlePiece.fromJson(

      Map<String,dynamic> json,

      ){


    return PuzzlePiece(


      id: json['id'].toString(),


      row: json['row'] ?? 0,


      column: json['column'] ?? 0,


      correctPosition:

      json['correctPosition'] ?? 0,



      sourceRect: Rect.zero,



      top: EdgeType.flat,


      bottom: EdgeType.flat,


      left: EdgeType.flat,


      right: EdgeType.flat,



      position: Offset(


        (json['x'] ?? 0).toDouble(),


        (json['y'] ?? 0).toDouble(),


      ),



      placed: json['placed'] ?? false,


    );


  }



}