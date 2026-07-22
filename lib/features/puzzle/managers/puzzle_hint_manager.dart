import 'package:flutter/material.dart';

import '../engine/puzzle_piece.dart';
import 'puzzle_progress_manager.dart';



class PuzzleHintManager {



  // =========================
  // 💡 جلب عدد التلميحات
  // =========================

  static Future<int> getHints() async {

    return await PuzzleProgressManager.getHints();

  }





  // =========================
  // استهلاك تلميح واحد
  // =========================

  static Future<bool> consumeHint() async {

    return await PuzzleProgressManager.useHint();

  }





  // =========================
  // إضافة تلميحات
  // =========================

  static Future<void> addHints(

      int amount,

      ) async {


    await PuzzleProgressManager.addHints(

      amount,

    );


  }





  // =========================
  // هل يوجد تلميحات؟
  // =========================

  static Future<bool> hasHint() async {


    final value = await getHints();


    return value > 0;


  }





  // =========================
  // البحث عن قطعة غير مكتملة
  // =========================

  static PuzzlePiece? findAvailablePiece(

      List<PuzzlePiece> pieces,

      ){


    for(final piece in pieces){


      if(!piece.placed){


        return piece;


      }


    }


    return null;


  }





  // =========================
  // تطبيق التلميح
  // =========================

  static void applyHint(

      PuzzlePiece piece,

      double pieceSize,

      ){


    piece.position = Offset(

      piece.column * pieceSize,

      piece.row * pieceSize,

    );


    piece.placed = true;


  }





  // =========================
  // حساب القطع المتبقية
  // =========================

  static int remainingPieces(

      List<PuzzlePiece> pieces,

      ){


    return pieces

        .where(

          (piece)=>!piece.placed,

    )

        .length;


  }





  // =========================
  // إعطاء قطعة عشوائية كتلميح
  // =========================

  static PuzzlePiece? getHintPiece(

      List<PuzzlePiece> pieces,

      ){


    final available = pieces

        .where(

          (piece)=>!piece.placed,

    )

        .toList();



    if(available.isEmpty){

      return null;

    }



    available.shuffle();



    return available.first;


  }



}