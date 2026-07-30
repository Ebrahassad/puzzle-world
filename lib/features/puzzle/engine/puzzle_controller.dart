import 'package:flutter/material.dart';

import 'puzzle_piece.dart';



class PuzzleController {


  final List<PuzzlePiece> pieces;



  final double boardOffsetX;

  final double boardOffsetY;



  PuzzleController({

    required this.pieces,

    this.boardOffsetX = 0,

    this.boardOffsetY = 0,

  });





  //=========================================
  // تحريك القطعة
  //=========================================


  void movePiece(

    PuzzlePiece piece,

    Offset position,

  ) {


    if (piece.placed) return;



    piece.position = position;


  }





  //=========================================
  // فحص مكان القطعة
  //=========================================


  bool checkPiecePosition(

    PuzzlePiece piece,

    double pieceSize,

  ) {


    if (piece.placed) {

      return true;

    }



    final target = _targetPosition(

      piece,

      pieceSize,

    );



    final distance =

        (piece.position - target).distance;



    final tolerance =

        pieceSize * 0.35;



    if (distance <= tolerance) {


      lockPiece(

        piece,

        pieceSize,

      );


      return true;

    }



    return false;

  }





  //=========================================
  // تثبيت القطعة
  //=========================================


  void lockPiece(

    PuzzlePiece piece,

    double pieceSize,

  ) {


    piece.position = _targetPosition(

      piece,

      pieceSize,

    );



    piece.placed = true;


  }

  //=========================================
  // المكان الصحيح للقطعة
  //=========================================


  Offset _targetPosition(

    PuzzlePiece piece,

    double pieceSize,

  ) {


    return Offset(

      boardOffsetX +

          (piece.column * pieceSize),


      boardOffsetY +

          (piece.row * pieceSize),

    );


  }





  //=========================================
  // تثبيت قطعة بواسطة التلميح
  //=========================================


  bool applyHint(

    PuzzlePiece piece,

    double pieceSize,

  ) {


    if (piece.placed) {

      return false;

    }



    lockPiece(

      piece,

      pieceSize,

    );



    return true;


  }





  //=========================================
  // عدد القطع المكتملة
  //=========================================


  int get completedPieces {


    return pieces

        .where(

          (p) => p.placed,

        )

        .length;


  }





  //=========================================
  // القطع المتبقية
  //=========================================


  int get remainingPieces {


    return pieces.length -

        completedPieces;


  }





  //=========================================
  // نسبة الإنجاز
  //=========================================


  double get progress {


    if (pieces.isEmpty) {

      return 0;

    }


    return completedPieces /

        pieces.length;


  }





  //=========================================
  // هل انتهى البازل
  //=========================================


  bool get isCompleted {


    return pieces.isNotEmpty &&

        pieces.every(

          (piece) => piece.placed,

        );


  }

  //=========================================
  // إعادة اللعبة
  //=========================================


  void reset() {


    for (final piece in pieces) {


      piece.reset();


    }


  }





  //=========================================
  // إنهاء البازل كامل
  //=========================================


  void completeAll(

    double pieceSize,

  ) {


    for (final piece in pieces) {


      lockPiece(

        piece,

        pieceSize,

      );


    }


  }





  //=========================================
  // إلغاء تثبيت قطعة
  //=========================================


  void unlockPiece(

    PuzzlePiece piece,

  ) {


    piece.placed = false;


  }





  //=========================================
  // البحث عن قطعة
  //=========================================


  PuzzlePiece? findPiece(

    String id,

  ) {


    try {


      return pieces.firstWhere(

        (piece) => piece.id == id,

      );


    } catch (_) {


      return null;


    }


  }


}