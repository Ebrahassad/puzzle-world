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





  final double width;


  final double height;







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



    this.width = 0,


    this.height = 0,



  });









  // المكان الصحيح الحقيقي على اللوحة


  Offset correctOffset(double pieceWidth,double pieceHeight){



    return Offset(


      column * pieceWidth,


      row * pieceHeight,


    );


  }









  // تثبيت القطعة بالتلميح


  void placeHint(



      double pieceWidth,

      double pieceHeight,

      ){



    position = correctOffset(

      pieceWidth,

      pieceHeight,

    );



    placed = true;



  }









  // هل القطعة في مكانها؟


  bool isCorrect(



      double pieceWidth,

      double pieceHeight,

      double tolerance,

      ){



    final target = correctOffset(

      pieceWidth,

      pieceHeight,

    );



    return

        (position.dx - target.dx).abs() < tolerance &&

        (position.dy - target.dy).abs() < tolerance;



  }









  // إعادة القطعة


  void reset(){



    position = Offset.zero;


    placed = false;



  }









  // تحويل للحفظ


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









  // استرجاع من الحفظ


  factory PuzzlePiece.fromJson(

      Map<String,dynamic> json,

      ){



    return PuzzlePiece(



      id: json["id"].toString(),



      row: json["row"] ?? 0,



      column: json["column"] ?? 0,



      correctPosition:

      json["correctPosition"] ?? 0,



      sourceRect:

      Rect.zero,



      top: EdgeType.flat,


      bottom: EdgeType.flat,


      left: EdgeType.flat,


      right: EdgeType.flat,



      position: Offset(



        (json["x"] ?? 0).toDouble(),



        (json["y"] ?? 0).toDouble(),



      ),



      placed:

      json["placed"] ?? false,



    );



  }



}