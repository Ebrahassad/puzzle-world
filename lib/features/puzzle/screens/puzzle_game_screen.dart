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



  final double boardSize = 360;



  final double trayHeight = 120;



  bool loading = true;







  @override
  void initState(){


    super.initState();


    loadImage();


  }








  //==================================================
  // تحميل صورة المرحلة
  //==================================================

  Future<void> loadImage() async {



    final provider =

    AssetImage(

      widget.level.image,

    );



    final stream =

    provider.resolve(

      const ImageConfiguration(),

    );



    late ImageStreamListener listener;



    listener = ImageStreamListener(

            (info, _) async {



          image = info.image;



          createPuzzle();



        }

    );



    stream.addListener(listener);



  }









  //==================================================
  // إنشاء البازل
  //==================================================

  void createPuzzle(){



    final size = Size(

      boardSize,

      boardSize,

    );



    pieces = PuzzleGenerator.generate(


      rows: widget.level.gridSize,


      columns: widget.level.gridSize,


      imageSize: Size(

        image!.width.toDouble(),

        image!.height.toDouble(),

      ),


      pieceSize: Size(

        boardSize / widget.level.gridSize,

        boardSize / widget.level.gridSize,

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

        backgroundColor: Colors.black,

        body: Center(

          child: CircularProgressIndicator(),

        ),

      );


    }






    return Scaffold(


      backgroundColor: Colors.transparent,



      body: SafeArea(



        child: Column(



          children: [







            //==========================================
            // شريط القطع العلوي
            //==========================================


            SizedBox(


              height: trayHeight,


              width: double.infinity,



              child: GestureDetector(



                onPanDown: (d){



                  controller.pointerDown(

                    d.localPosition,

                  );



                  setState((){});



                },




                onPanUpdate: (d){



                  controller.pointerMove(

                    d.localPosition,

                  );



                  setState((){});



                },




                onPanEnd: (_){



                  controller.pointerUp();



                  checkWin();



                },



                child: CustomPaint(



                  painter:

                  PuzzleBoardPainter(


                    image: image!,


                    pieces: pieces,


                    pieceSize:

                    boardSize /

                        widget.level.gridSize,



                    showReference: false,



                  ),



                ),


              ),


            ),







            const SizedBox(

              height: 20,

            ),








            //==========================================
            // لوحة البازل
            //==========================================


            SizedBox(


              width: boardSize,


              height: boardSize,



              child: Stack(



                children: [





                  // الصورة الشفافة الخلفية

                  Opacity(


                    opacity: 0.15,


                    child: Image.asset(


                      widget.level.image,


                      width: boardSize,


                      height: boardSize,


                      fit: BoxFit.cover,


                    ),


                  ),







                  GestureDetector(



                    onPanDown: (d){



                      controller.pointerDown(

                        d.localPosition,

                      );



                      setState((){});


                    },



                    onPanUpdate: (d){



                      controller.pointerMove(

                        d.localPosition,

                      );



                      setState((){});



                    },



                    onPanEnd: (_){



                      controller.pointerUp();



                      checkWin();



                    },



                    child: CustomPaint(



                      size: Size(

                        boardSize,

                        boardSize,

                      ),



                      painter:

                      PuzzleBoardPainter(


                        image: image!,


                        pieces: pieces,


                        pieceSize:

                        boardSize /

                            widget.level.gridSize,


                        showReference: true,


                      ),



                    ),



                  ),


                ],


              ),



            ),




          ],


        ),


      ),


    );



  }









  void checkWin(){



    if(controller.isCompleted){



      Future.delayed(

        const Duration(milliseconds: 600),

            (){


          Navigator.pop(context);



        },

      );


    }


  }


}






//==================================================
// رسام اللوحة
//==================================================

class PuzzleBoardPainter extends CustomPainter {



  final ui.Image image;


  final List<PuzzlePiece> pieces;


  final double pieceSize;


  final bool showReference;





  PuzzleBoardPainter({


    required this.image,


    required this.pieces,


    required this.pieceSize,


    this.showReference = false,


  });







  @override
  void paint(

      Canvas canvas,

      Size size,

      ){



    // رسم القطع

    for(final piece in pieces){



      PuzzlePiecePainter.paint(


        canvas: canvas,


        piece: piece,


        image: image,


        pieceSize: Size(

          pieceSize,

          pieceSize,

        ),


        showShadow: piece.dragging,


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