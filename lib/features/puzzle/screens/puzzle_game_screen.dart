import 'package:flutter/material.dart';

import '../engine/puzzle_controller.dart';
import '../engine/puzzle_generator.dart';
import '../engine/puzzle_piece.dart';
import '../widgets/puzzle_piece_widget.dart';



///======================================================
/// شاشة لعبة البازل
///======================================================

class PuzzleGameScreen extends StatefulWidget {


  final ImageProvider image;


  final int rows;


  final int columns;



  const PuzzleGameScreen({

    super.key,


    required this.image,


    this.rows = 3,


    this.columns = 3,

  });



  @override
  State<PuzzleGameScreen> createState()

      => _PuzzleGameScreenState();

}






class _PuzzleGameScreenState

    extends State<PuzzleGameScreen> {


  late PuzzleController controller;



  final double boardSize = 350;



  late double pieceSize;



  bool initialized = false;




  //====================================================
  // إنشاء اللعبة
  //====================================================

  @override
  void initState() {


    super.initState();


    _createGame();


  }





  void _createGame() {


    pieceSize =

        boardSize /

            widget.columns;



    final pieces =

        PuzzleGenerator.generate(

          rows: widget.rows,

          columns: widget.columns,

          imageWidth: boardSize,

          imageHeight: boardSize,

        );



    controller =

        PuzzleController(

          pieces: pieces,

        );



    initialized = true;


  }





  //====================================================
  // بدء السحب
  //====================================================

  void _onDragStart(

    PuzzlePiece piece,

  ) {


    setState(() {


      controller.startDrag(

        piece,

        piece.position,

      );


    });

  }





  //====================================================
  // تحديث الحركة
  //====================================================

  void _onDragUpdate(

    Offset position,

  ) {


    setState(() {


      controller.updateDrag(

        position,

      );


    });

  }





  //====================================================
  // نهاية السحب
  //====================================================

  void _onDragEnd() {


    setState(() {


      controller.endDrag(

        pieceSize * 0.35,

      );


    });



    if(controller.isCompleted) {


      _showWin();


    }


  }

  //====================================================
  // إعادة اللعبة
  //====================================================

  void _restartGame() {


    setState(() {


      _createGame();


    });

  }





  //====================================================
  // رسالة الفوز
  //====================================================

  void _showWin() {


    Future.delayed(

      const Duration(

        milliseconds: 300,

      ),

      () {


        if(!mounted) return;



        showDialog(

          context: context,

          builder: (_) {


            return AlertDialog(

              title:

                  const Text(

                    "🎉 أحسنت",

                  ),


              content:

                  const Text(

                    "اكتملت الصورة",

                  ),


              actions: [


                TextButton(

                  onPressed: () {


                    Navigator.pop(context);


                    _restartGame();


                  },


                  child:

                      const Text(

                        "لعب مرة أخرى",

                      ),

                ),


              ],

            );


          },

        );


      },

    );


  }






  //====================================================
  // بناء الشاشة
  //====================================================

  @override
  Widget build(

    BuildContext context,

  ) {


    if(!initialized) {


      return const Scaffold(

        body:

            Center(

              child:

                  CircularProgressIndicator(),

            ),

      );


    }



    final pieces =

        controller.sortedPieces;



    return Scaffold(

      body:

          SafeArea(

            child:

                Column(

                  children: [


                    const SizedBox(

                      height: 20,

                    ),



                    Text(

                      "Puzzle",

                      style:

                          Theme.of(context)

                              .textTheme

                              .headlineSmall,

                    ),




                    const SizedBox(

                      height: 20,

                    ),





                    SizedBox(

                      width: boardSize,

                      height: boardSize,


                      child:

                          Stack(


                            clipBehavior:

                                Clip.none,


                            children:

                                pieces

                                    .map(

                                      (piece) {


                                        return PuzzlePieceWidget(


                                          piece:

                                              piece,


                                          image:

                                              widget.image,


                                          size:

                                              pieceSize,


                                          active:

                                              piece ==

                                                  controller.activePiece,



                                          onDragStart:

                                              (_) {

                                                _onDragStart(

                                                  piece,

                                                );

                                              },



                                          onDragUpdate:

                                              _onDragUpdate,



                                          onDragEnd:

                                              _onDragEnd,


                                        );


                                      },

                                    )

                                    .toList(),


                          ),

                    ),





                    const SizedBox(

                      height: 30,

                    ),





                    Text(

                      "${controller.completedCount}/${controller.pieces.length}",


                      style:

                          const TextStyle(

                            fontSize: 18,

                          ),

                    ),





                    const SizedBox(

                      height: 15,

                    ),





                    ElevatedButton(

                      onPressed:

                          _restartGame,


                      child:

                          const Text(

                            "إعادة",

                          ),

                    ),


                  ],

                ),

          ),

    );

  }


}