import '../engine/puzzle_piece.dart';



class PuzzleMoveService {


  int _moves = 0;


  int get moves => _moves;








  void addMove(){


    _moves++;


  }








  void reset(){


    _moves = 0;


  }








  void undoMove(){


    if(_moves > 0){


      _moves--;


    }


  }








  bool canUndo(){


    return _moves > 0;


  }








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








  bool checkMove({

    required PuzzlePiece piece,

    required double pieceSize,

  }) {



    return piece.isCorrect(

      pieceSize,

    );


  }








  int calculateScore({

    required int stars,

    required int seconds,

  }) {



    int score = stars * 100;





    score += seconds > 0

        ? (1000 ~/ seconds)

        : 0;





    score -= _moves * 5;





    if(score < 0){

      score = 0;

    }





    return score;


  }


}