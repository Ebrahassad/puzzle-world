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








  // المكان الصحيح للقطعة داخل اللوحة

  Offset correctOffset(double pieceSize){



    return Offset(



      column * pieceSize,



      row * pieceSize,



    );



  }








  // موقع الشبكة

  Offset get gridPosition {



    return Offset(

      column.toDouble(),

      row.toDouble(),

    );



  }








  // وضع القطعة مباشرة بواسطة التلميح

  void placeHint(double pieceSize){



    position = correctOffset(pieceSize);



    placed = true;



  }








  // إعادة القطعة

  void reset(){



    position = Offset.zero;



    placed = false;



  }








  // هل القطعة في مكانها الصحيح

  bool isCorrect(double pieceSize){



    final target = correctOffset(pieceSize);





    return (position - target).distance <=

        pieceSize * 0.35;



  }








  // تثبيت القطعة

  void place(){



    placed = true;



  }








  // تحريك القطعة

  void moveTo(Offset newPosition){



    if(!placed){



      position = newPosition;



    }



  }








  // نسخ القطعة

  PuzzlePiece copyWith({



    Offset? position,



    bool? placed,



  }){



    return PuzzlePiece(



      id: id,



      row: row,



      column: column,



      correctPosition: correctPosition,



      sourceRect: sourceRect,



      top: top,



      bottom: bottom,



      left: left,



      right: right,



      position: position ?? this.position,



      placed: placed ?? this.placed,



    );



  }








  // حفظ التقدم

  Map<String,dynamic> toJson(){



    return {



      "id": id,



      "row": row,



      "column": column,



      "correctPosition": correctPosition,



      "x": position.dx,



      "y": position.dy,



      "placed": placed,



    };



  }








  // استرجاع التقدم

  factory PuzzlePiece.fromJson(

      Map<String,dynamic> json,

      ){



    return PuzzlePiece(



      id: json["id"]?.toString() ?? "0",



      row: json["row"] ?? 0,



      column: json["column"] ?? 0,



      correctPosition:

      json["correctPosition"] ?? 0,



      sourceRect:

      Rect.zero,



      top:

      EdgeType.flat,



      bottom:

      EdgeType.flat,



      left:

      EdgeType.flat,



      right:

      EdgeType.flat,



      position: Offset(



        (json["x"] ?? 0).toDouble(),



        (json["y"] ?? 0).toDouble(),



      ),



      placed:

      json["placed"] ?? false,



    );



  }








  @override

  bool operator ==(Object other){



    return identical(this, other) ||

        other is PuzzlePiece &&

            other.id == id;



  }








  @override

  int get hashCode => id.hashCode;







  @override

  String toString(){



    return """

PuzzlePiece(

 id: $id,

 row: $row,

 column: $column,

 position: $position,

 placed: $placed

)

""";



  }



}