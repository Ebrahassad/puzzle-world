import 'package:flutter/material.dart';

import '../models/puzzle_model.dart';

import '../engine/puzzle_controller.dart';
import '../engine/puzzle_generator.dart';
import '../engine/puzzle_piece.dart';

import '../widgets/puzzle_piece_widget.dart';





class PuzzleGameScreen extends StatefulWidget {


  final PuzzleModel puzzle;




  const PuzzleGameScreen({

    super.key,


    required this.puzzle,

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



  bool ready = false;






  @override
  void initState() {


    super.initState();


    createGame();


  }






  //==================================================
  // إنشاء اللعبة
  //==================================================

  void createGame() {


    final pieces =

        PuzzleGenerator.generate(

          rows: 3,


          columns: 3,


          imageWidth:

              boardSize,


          imageHeight:

              boardSize,

        );



    pieceSize =

        boardSize / 3;



    controller =

        PuzzleController(

          pieces: pieces,

        );



    ready = true;


  }


  //==================================================
  // بداية السحب
  //==================================================

  void startDrag(

    PuzzlePiece piece,

  ) {


    setState(() {


      controller.startDragging(

        piece,

      );


    });


  }







  //==================================================
  // حركة السحب
  //==================================================

  void updateDrag(

    PuzzlePiece piece,

    Offset delta,

  ) {


    if(piece.placed) return;



    setState(() {


      piece.position += delta;


    });


  }







  //==================================================
  // نهاية السحب
  //==================================================

  void endDrag(

    PuzzlePiece piece,

  ) {


    setState(() {


      controller.endDragging(

        piece,

      );



      controller.checkPiecePosition(

        piece,

        pieceSize,

      );


    });



    if(controller.isCompleted) {


      showWin();


    }


  }







  //==================================================
  // الفوز
  //==================================================

  void showWin() {


    Future.delayed(

      const Duration(

        milliseconds: 300,

      ),


      () {


        if(!mounted) return;



        showDialog(

          context: context,


          builder:

              (_) => AlertDialog(

                title:

                    const Text(

                      "🎉 أحسنت",

                    ),



                content:

                    const Text(

                      "تم تركيب الصورة بنجاح",

                    ),


                actions: [


                  TextButton(

                    onPressed: () {


                      Navigator.pop(context);


                    },


                    child:

                        const Text(

                          "موافق",

                        ),

                  ),


                ],

              ),


        );


      },


    );


  }

  //==================================================
  // بناء الشاشة
  //==================================================

  @override
  Widget build(

    BuildContext context,

  ) {



    if(!ready) {


      return const Scaffold(

        body:

            Center(

              child:

                  CircularProgressIndicator(),

            ),

      );


    }






    return Scaffold(

      backgroundColor:

          Colors.black12,



      body:

          SafeArea(

            child:

                Column(

                  mainAxisAlignment:

                      MainAxisAlignment.center,


                  children: [





                    Text(

                      widget.puzzle.title,


                      style:

                          const TextStyle(

                            fontSize: 24,

                            fontWeight:

                                FontWeight.bold,

                          ),

                    ),





                    const SizedBox(

                      height: 20,

                    ),






                    SizedBox(

                      width:

                          boardSize,


                      height:

                          boardSize,



                      child:

                          Stack(

                            clipBehavior:

                                Clip.none,


                            children:

                                controller.pieces

                                    .map(

                                      (piece) {


                                        return PuzzlePieceWidget(

                                          piece:

                                              piece,


                                          image:

                                              AssetImage(

                                                widget.puzzle.image,

                                              ),



                                          size:

                                              pieceSize,



                                          active:

                                              controller.draggingPiece ==

                                                  piece,



                                          onDragStart:

                                              (p) {


                                                startDrag(

                                                  p,

                                                );


                                              },



                                          onDragUpdate:

                                              (delta) {


                                                updateDrag(

                                                  piece,

                                                  delta,

                                                );


                                              },



                                          onDragEnd:

                                              () {


                                                endDrag(

                                                  piece,

                                                );


                                              },

                                        );


                                      },

                                    )

                                    .toList(),

                          ),

                    ),







                    const SizedBox(

                      height:

                          30,

                    ),






                    Text(

                      "${controller.completedPieces}/${controller.pieces.length}",


                      style:

                          const TextStyle(

                            fontSize:

                                18,

                          ),

                    ),






                    const SizedBox(

                      height:

                          20,

                    ),






                    ElevatedButton(

                      onPressed: () {


                        setState(() {


                          createGame();


                        });


                      },


                      child:

                          const Text(

                            "إعادة اللعب",

                          ),

                    ),


                  ],

                ),

          ),

    );


  }


}