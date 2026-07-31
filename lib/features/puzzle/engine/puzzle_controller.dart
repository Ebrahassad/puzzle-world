import 'package:flutter/material.dart';

import 'puzzle_piece.dart';


//==================================================
// متحكم لعبة البازل
//==================================================

class PuzzleController {


  final List<PuzzlePiece> pieces;



  PuzzlePiece? activePiece;



  Offset lastPosition = Offset.zero;



  final double snapTolerance;



  // حدود لوحة البازل
  final Rect boardRect;



  PuzzleController({

    required this.pieces,

    required this.boardRect,

    this.snapTolerance = 35,

  });







  //==================================================
  // الضغط على قطعة
  //==================================================

  void pointerDown(

      Offset position,

      ) {



    // البحث من الأعلى للأسفل

    for(int i = pieces.length - 1; i >= 0; i--){



      final piece = pieces[i];




      if(piece.state == PieceState.locked){

        continue;

      }







      final local =

          position -

              piece.position;







      if(piece.path.contains(local)){



        activePiece = piece;



        lastPosition = position;



        piece.startDrag();







        // وضع القطعة فوق باقي القطع

        pieces.remove(piece);

        pieces.add(piece);




        break;

      }


    }


  }







  //==================================================
  // تحريك القطعة
  //==================================================

  void pointerMove(

      Offset position,

      ){



    if(activePiece == null){

      return;

    }






    final delta =

        position -

            lastPosition;






    activePiece!.move(

      delta,

    );





    lastPosition = position;



  }



//==================================================
// رفع الإصبع
//==================================================

void pointerUp(){



  if(activePiece == null){

    return;

  }



  final piece = activePiece!;







  // هل القطعة داخل حدود اللوحة

  if(_isInsideBoard(piece)){



    piece.state = PieceState.board;



    // هل اقتربت من مكانها الصحيح

    if(piece.isCorrect(

      snapTolerance,

    )){


      piece.lock();


    }else{


      // إذا لم تركب ترجع للشريط

      piece.returnToTray();


    }


  }else{


    // خارج اللوحة

    piece.returnToTray();


  }






  piece.endDrag();



  activePiece = null;



}









//==================================================
// التحقق أن القطعة داخل اللوحة
//==================================================

bool _isInsideBoard(

    PuzzlePiece piece,

    ){



  final center = Offset(

    piece.position.dx +

        piece.size.width / 2,


    piece.position.dy +

        piece.size.height / 2,

  );




  return boardRect.contains(center);


}









//==================================================
// نسبة الإنجاز
//==================================================

double get progress {



  if(pieces.isEmpty){

    return 0;

  }




  final completed = pieces

      .where(

        (piece)=>

    piece.state == PieceState.locked,

  )

      .length;




  return completed / pieces.length;



}









//==================================================
// هل اكتملت اللعبة
//==================================================

bool get isCompleted {



  if(pieces.isEmpty){

    return false;

  }



  return pieces.every(

        (piece)=>

    piece.state == PieceState.locked,

  );


}









//==================================================
// عدد القطع المثبتة
//==================================================

int get completedPieces {



  return pieces

      .where(

        (piece)=>

    piece.state == PieceState.locked,

  )

      .length;


}









//==================================================
// إعادة اللعبة
//==================================================

void reset(){



  for(final piece in pieces){



    piece.returnToTray();



  }



  activePiece = null;



}



}