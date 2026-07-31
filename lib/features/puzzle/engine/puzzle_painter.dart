import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'puzzle_piece.dart';


class PuzzlePainter extends CustomPainter {


  final PuzzlePiece piece;

  final ImageProvider image;

  final ui.Image? cachedImage;


  // حجم الخلية الحقيقي
  final double pieceSize;


  // الهامش الإضافي للنتوءات
  final double padding;



  PuzzlePainter({

    required this.piece,

    required this.image,

    this.cachedImage,

    required this.pieceSize,

    this.padding = 0,

  });



  @override
  void paint(

    Canvas canvas,

    Size size,

  ) {


    final path = createPiecePath(

      size,

    );



    //==================================================
    // ظل القطعة
    //==================================================


    canvas.drawPath(

      path,

      Paint()

        ..color = Colors.black.withOpacity(0.22)

        ..maskFilter = const MaskFilter.blur(

          BlurStyle.normal,

          5,

        ),

    );



    //==================================================
    // رسم الصورة داخل شكل القطعة
    //==================================================


    if (cachedImage != null) {


      canvas.save();


      canvas.clipPath(path);



      final source = piece.sourceRect;



      final destination = Rect.fromLTWH(

        padding,

        padding,

        pieceSize,

        pieceSize,

      );



      canvas.drawImageRect(

        cachedImage!,

        source,

        destination,

        Paint()

          ..filterQuality = FilterQuality.high

          ..isAntiAlias = true,

      );



      canvas.restore();

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


    final target =
        _targetPosition(
          piece,
          pieceSize,
        );


    final distance =
        (piece.position - target).distance;


    // سماحية الإدخال
    final tolerance =
        pieceSize * 0.45;



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

    piece.lock(
      pieceSize,
    );

  }



  //=========================================
  // مكان القطعة الصحيح
  //=========================================

  Offset _targetPosition(
    PuzzlePiece piece,
    double pieceSize,
  ) {

    return Offset(

      piece.column *
          pieceSize,


      piece.row *
          pieceSize,

    );

  }




  //=========================================
  // التلميح
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
          (p)=>p.placed,
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

    if(pieces.isEmpty){
      return 0;
    }


    return completedPieces /
        pieces.length;

  }



  //=========================================
  // هل انتهى البازل
  //=========================================

  bool get isCompleted {

    if(pieces.isEmpty){
      return false;
    }


    return pieces.every(
      (p)=>p.placed,
    );

  }



  //=========================================
  // إعادة اللعبة
  //=========================================

  void reset(){

    for(final piece in pieces){

      piece.reset();

    }

  }



  //=========================================
  // فك قطعة
  //=========================================

  void unlockPiece(
    PuzzlePiece piece,
  ){

    piece.unlock();

  }



  //=========================================
  // البحث عن قطعة
  //=========================================

  PuzzlePiece? findPiece(
    String id,
  ){

    for(final piece in pieces){

      if(piece.id == id){
        return piece;
      }

    }

    return null;

  }


}