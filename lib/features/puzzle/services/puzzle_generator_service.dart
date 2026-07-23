import 'dart:math';

import 'package:flutter/material.dart';

import '../engine/puzzle_piece.dart';



class PuzzleGeneratorService {


  const PuzzleGeneratorService._();





  //==================================================
  // 🧩 إنشاء قطع البازل
  //==================================================

  static List<PuzzlePiece> generatePieces({

    required int gridSize,

    required double imageSize,

  }) {



    final pieces = <PuzzlePiece>[];



    final pieceSize =

    imageSize / gridSize;





    int index = 0;



    final random = Random();





    for(int row = 0; row < gridSize; row++){



      for(int column = 0; column < gridSize; column++){





        pieces.add(



          PuzzlePiece(



            id: "piece_$index",



            row: row,



            column: column,



            correctPosition: index,



            sourceRect:

            Rect.fromLTWH(

              column * pieceSize,

              row * pieceSize,

              pieceSize,

              pieceSize,

            ),





            top: EdgeType.flat,

            bottom: EdgeType.flat,

            left: EdgeType.flat,

            right: EdgeType.flat,





            position:

            Offset(

              random.nextDouble()

                  * (imageSize - pieceSize),



              random.nextDouble()

                  * (imageSize - pieceSize),

            ),



          ),



        );





        index++;



      }



    }





    pieces.shuffle();



    return pieces;


  }








  //==================================================
  // 🔄 إعادة خلط القطع
  //==================================================


  static List<PuzzlePiece> regenerate({

    required List<PuzzlePiece> pieces,

    required double boardSize,

  }) {



    final random = Random();





    for(final piece in pieces){



      piece.position = Offset(

        random.nextDouble()

            * boardSize,



        random.nextDouble()

            * boardSize,

      );





      piece.placed = false;



    }





    return pieces;


  }








  //==================================================
  // 🔢 عدد القطع
  //==================================================


  static int totalPieces(

      int gridSize,

      ) {



    return gridSize * gridSize;


  }








  //==================================================
  // 📐 حجم القطعة
  //==================================================


  static double calculatePieceSize({

    required double boardSize,

    required int gridSize,

  }) {



    return boardSize / gridSize;


  }





  //==================================================
  // ⭐ مستوى الصعوبة
  //==================================================


  static int calculateDifficulty(

      int gridSize,

      ) {



    if(gridSize <= 3){

      return 1;

    }



    if(gridSize == 4){

      return 2;

    }



    if(gridSize == 5){

      return 3;

    }



    return 4;


  }


}