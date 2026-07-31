import 'package:flutter/material.dart';

import 'puzzle_piece.dart';



///======================================================
/// التحكم الكامل بحركة قطع البازل
///======================================================

class PuzzleController {


  final List<PuzzlePiece> pieces;



  PuzzlePiece? activePiece;



  Offset? pointerPosition;



  PuzzleController({

    required this.pieces,

  });





  //====================================================
  // بدء سحب قطعة
  //====================================================

  void startDrag(

    PuzzlePiece piece,

    Offset position,

  ) {


    if (piece.isLocked) return;



    activePiece = piece;



    piece.startDrag(

      position,

    );



    _bringToFront(

      piece,

    );

  }





  //====================================================
  // تحديث السحب
  //====================================================

  void updateDrag(

    Offset position,

  ) {


    final piece = activePiece;



    if (piece == null) return;



    pointerPosition = position;



    piece.updateDrag(

      position,

    );

  }





  //====================================================
  // إنهاء السحب
  //====================================================

  void endDrag(

    double snapDistance,

  ) {


    final piece = activePiece;



    if (piece == null) return;



    if (

      piece.canSnap(

        snapDistance,

      )

    ) {


      piece.snap();


    }

    else {


      piece.endDrag();


    }



    activePiece = null;



    pointerPosition = null;


  }





  //====================================================
  // إضافة قطعة فوق البقية
  //====================================================

  void _bringToFront(

    PuzzlePiece piece,

  ) {


    int maxZ = 0;



    for(final item in pieces) {


      if(item.zIndex > maxZ) {

        maxZ = item.zIndex;

      }

    }



    piece.zIndex = maxZ + 1;


    piece.isDragging = true;


  }

  //====================================================
  // إنهاء السحب مع إعادة ترتيب الحالة
  //====================================================

  void cancelDrag() {


    final piece = activePiece;


    if (piece == null) return;



    piece.endDrag();



    activePiece = null;



    pointerPosition = null;


  }





  //====================================================
  // تثبيت قطعة يدوياً
  //====================================================

  void lockPiece(

    PuzzlePiece piece,

  ) {


    piece.snap();

  }





  //====================================================
  // فك تثبيت قطعة
  //====================================================

  void unlockPiece(

    PuzzlePiece piece,

  ) {


    piece.unlock();

  }





  //====================================================
  // عدد القطع المكتملة
  //====================================================

  int get completedCount {


    return pieces

        .where(

          (piece) => piece.isLocked,

        )

        .length;

  }





  //====================================================
  // عدد القطع المتبقية
  //====================================================

  int get remainingCount {


    return pieces.length -

        completedCount;

  }





  //====================================================
  // نسبة الإنجاز
  //====================================================

  double get progress {


    if (pieces.isEmpty) {

      return 0;

    }



    return completedCount /

        pieces.length;

  }





  //====================================================
  // هل انتهت اللعبة
  //====================================================

  bool get isCompleted {


    if (pieces.isEmpty) {

      return false;

    }



    return pieces.every(

      (piece) => piece.isLocked,

    );

  }





  //====================================================
  // إعادة اللعبة
  //====================================================

  void reset() {


    for (final piece in pieces) {


      piece.reset(

        piece.targetPosition,

      );


    }



    activePiece = null;



    pointerPosition = null;


  }





  //====================================================
  // إيجاد قطعة بالمعرف
  //====================================================

  PuzzlePiece? findPiece(

    String id,

  ) {


    for(final piece in pieces) {


      if(piece.id == id) {


        return piece;


      }

    }


    return null;


  }





  //====================================================
  // ترتيب القطع للرسم
  //====================================================

  List<PuzzlePiece> get sortedPieces {


    final result =

        List<PuzzlePiece>.from(

          pieces,

        );



    result.sort(

      (a,b) =>

          a.zIndex.compareTo(

            b.zIndex,

          ),

    );



    return result;

  }


}