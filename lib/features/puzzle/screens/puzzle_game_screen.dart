import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../models/puzzle_level_model.dart';

import '../engine/puzzle_piece.dart';
import '../engine/puzzle_generator.dart';
import '../engine/puzzle_controller.dart';
import '../engine/puzzle_painter.dart';



class PuzzleGameScreen extends StatefulWidget {


  final PuzzleLevelModel level;



  const PuzzleGameScreen({

    super.key,

    required this.level,

  });



  @override
  State<PuzzleGameScreen> createState()

      => _PuzzleGameScreenState();


}







class _PuzzleGameScreenState

    extends State<PuzzleGameScreen> {



  ui.Image? image;



  late PuzzleController controller;



  List<PuzzlePiece> pieces = [];



  bool loading = true;



  final double boardSize = 360;



  final double trayHeight = 170;






  @override
  void initState(){

    super.initState();

    loadImage();

  }








  //==============================================
  // تحميل صورة المرحلة
  //==============================================

  Future<void> loadImage() async {


    final provider = AssetImage(

      widget.level.image,

    );



    final stream = provider.resolve(

      const ImageConfiguration(),

    );



    stream.addListener(

      ImageStreamListener(

        (info, _) {


          image = info.image;



          createPuzzle();



        },

      ),

    );

  }








  //==============================================
  // إنشاء القطع
  //==============================================

  void createPuzzle(){



    final pieceSize =

        boardSize /

            widget.level.gridSize;




    pieces = PuzzleGenerator.generate(


      rows: widget.level.gridSize,


      columns: widget.level.gridSize,



      imageSize: Size(

        image!.width.toDouble(),

        image!.height.toDouble(),

      ),



      pieceSize: Size(

        pieceSize,

        pieceSize,

      ),



      traySize: Size(

        MediaQuery.of(context).size.width,

        trayHeight,

      ),


    );





    controller = PuzzleController(

      pieces: pieces,

    );




    setState((){

      loading = false;

    });


  }









  @override
  Widget build(BuildContext context){



    if(loading || image == null){


      return const Scaffold(

        body: Center(

          child:CircularProgressIndicator(),

        ),

      );


    }






    return Scaffold(


      backgroundColor: Colors.transparent,


      body: SafeArea(


        child: Column(


          children: [



            //====================================
            // شريط القطع
            //====================================


            SizedBox(

              height: trayHeight,

              width: double.infinity,


              child: GestureDetector(


                onPanDown:(d){


                  controller.pointerDown(

                    d.localPosition,

                  );


                  setState((){});


                },



                onPanUpdate:(d){


                  controller.pointerMove(

                    d.localPosition,

                  );


                  setState((){});


                },



                onPanEnd:(_){


                  controller.pointerUp();


                  setState((){});


                  checkWin();


                },



                child: CustomPaint(


                  painter: PuzzlePainter(


                    image:image!,


                    pieces:pieces,


                    pieceSize:

                    boardSize /

                        widget.level.gridSize,


                  ),


                ),


              ),

            ),





            const SizedBox(height:20),



            //====================================
            // لوحة البازل
            //====================================


            SizedBox(


              width:boardSize,


              height:boardSize,



              child: GestureDetector(


                onPanDown:(d){


                  controller.pointerDown(

                    d.localPosition,

                  );


                  setState((){});


                },



                onPanUpdate:(d){


                  controller.pointerMove(

                    d.localPosition,

                  );


                  setState((){});


                },



                onPanEnd:(_){


                  controller.pointerUp();


                  setState((){});


                  checkWin();


                },



                child: CustomPaint(


                  size:Size(

                    boardSize,

                    boardSize,

                  ),



                  painter:PuzzlePainter(


                    image:image!,


                    pieces:pieces,


                    pieceSize:

                    boardSize /

                        widget.level.gridSize,


                  ),


                ),


              ),


            ),


          ],


        ),

      ),

    );


  }

  //==============================================
  // فحص اكتمال البازل
  //==============================================

  void checkWin(){


    if(controller.isCompleted){


      Future.delayed(

        const Duration(milliseconds:500),

            (){


          Navigator.pop(context);


        },

      );


    }


  }



}








//==================================================
// رسام لوحة البازل
//==================================================

class PuzzlePainter extends CustomPainter {


  final ui.Image image;


  final List<PuzzlePiece> pieces;


  final double pieceSize;



  PuzzlePainter({

    required this.image,

    required this.pieces,

    required this.pieceSize,

  });






  @override
  void paint(

      Canvas canvas,

      Size size,

      ){



    for(final piece in pieces){



      PuzzlePiecePainter.paint(


        canvas:canvas,


        piece:piece,


        image:image,


        pieceSize:Size(

          pieceSize,

          pieceSize,

        ),


        showShadow:

        piece.dragging,


      );



    }



  }






  @override
  bool shouldRepaint(

      covariant CustomPainter oldDelegate,

      ){


    return true;


  }



}