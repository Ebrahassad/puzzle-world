import 'package:flutter/material.dart';



class PuzzlePiece {



  // معرف القطعة

  final String id;



  // مكان القطعة الصحيح داخل الشبكة

  final int row;


  final int column;





  // مكانها الحالي على اللوحة

  Offset position;





  // هل وضعت في مكانها الصحيح؟

  bool placed;







  // حجم القطعة (اختياري للاستخدام لاحقاً)

  final double width;


  final double height;







  PuzzlePiece({



    required this.id,


    required this.row,


    required this.column,



    required this.position,



    this.placed = false,



    this.width = 0,


    this.height = 0,



  });









  // =========================
  // المكان الصحيح للقطعة
  // =========================


  Offset get correctPosition {



    return Offset(

      column.toDouble(),

      row.toDouble(),

    );


  }









  // =========================
  // تحويل إلى بيانات للحفظ
  // =========================


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









  // =========================
  // إنشاء قطعة من البيانات
  // =========================


  factory PuzzlePiece.fromJson(

      Map<String,dynamic> json,

      ){



    return PuzzlePiece(



      id:json['id'],



      row:json['row'],



      column:json['column'],



      position:Offset(



        (json['x'] ?? 0).toDouble(),



        (json['y'] ?? 0).toDouble(),



      ),



      placed:

      json['placed'] ?? false,



    );



  }









  // =========================
  // إعادة القطعة لبداية اللعبة
  // =========================


  void reset(){



    position = Offset.zero;



    placed = false;



  }









  // =========================
  // تثبيت القطعة بالتلميح
  // =========================


  void placeHint(

      double pieceSize,

      ){



    position = Offset(



      column * pieceSize,



      row * pieceSize,



    );



    placed = true;



  }





}