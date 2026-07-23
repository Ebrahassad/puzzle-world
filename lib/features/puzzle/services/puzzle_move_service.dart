import 'dart:ui';

import '../engine/puzzle_piece.dart';



class PuzzleMoveService {


  PuzzleMoveService();





  int _moves = 0;




  int get moves => _moves;








  //==================================================
  // ➕ إضافة حركة
  //==================================================

  void addMove(){


    _moves++;


  }








  //==================================================
  // 🔄 إعادة الضبط
  //==================================================

  void reset(){


    _moves = 0;


  }








  //==================================================
  // ↩️ تراجع
  //==================================================

  void undoMove(){


    if(_moves > 0){


      _moves--;


    }


  }








  bool canUndo(){


    return _moves > 0;


  }








  //==================================================
  // 🧩 تحريك قطعة
  //==================================================

  void movePiece({

    required PuzzlePiece piece,

    required double x,

    required double y,

  }) {



    if(piece.placed){

      return;

    }





    piece.position = Offset(

      x,

      y,

    );





    addMove();


  }








  //==================================================
  // ✅ فحص الحركة
  //==================================================

  bool checkMove({

    required PuzzlePiece piece,

    required double pieceSize,

  }) {



    return piece.isCorrect(

      pieceSize,

    );


  }








  //==================================================
  // ⭐ حساب النقاط
  //==================================================

  int calculateScore({

    required int stars,

    required int seconds,

  }) {



    int score = stars * 100;





    if(seconds > 0){


      score += 1000 ~/ seconds;


    }





    score -= _moves * 5;





    if(score < 0){


      score = 0;


    }





    return score;


  }


}