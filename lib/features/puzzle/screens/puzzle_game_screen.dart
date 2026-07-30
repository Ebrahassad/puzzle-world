import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../engine/puzzle_controller.dart';
import '../engine/puzzle_generator.dart';
import '../engine/puzzle_piece.dart';

import '../models/puzzle_level_model.dart';
import '../models/puzzle_model.dart';

import '../widgets/puzzle_piece_widget.dart';



class PuzzleGameScreen extends StatefulWidget {


  final PuzzleModel puzzle;

  final PuzzleLevelModel level;



  const PuzzleGameScreen({

    super.key,

    required this.puzzle,

    required this.level,

  });



  @override
  State<PuzzleGameScreen> createState() =>

      _PuzzleGameScreenState();

}






class _PuzzleGameScreenState

    extends State<PuzzleGameScreen> {


  late AssetImage puzzleImage;


  ui.Image? image;


  late PuzzleController controller;



  List<PuzzlePiece> pieces = [];



  bool loading = true;

  bool completed = false;



  // القطعة التي يتم سحبها حاليا

  PuzzlePiece? draggingPiece;



  Offset dragPosition = Offset.zero;



  final GlobalKey boardKey = GlobalKey();





  double get boardSize {


    final size = MediaQuery.of(context).size;


    return size.width * 0.90;


  }





  double get pieceSize =>

      boardSize / widget.level.gridSize;





  @override

  void initState() {

    super.initState();



    puzzleImage = AssetImage(

      widget.level.image,

    );



    loadGame();

  }

  Future<void> loadGame() async {


    image = await loadImage(

      widget.level.image,

    );



    pieces = PuzzleGenerator.generate(

      rows: widget.level.gridSize,

      columns: widget.level.gridSize,

      imageWidth:

          image!.width.toDouble(),

      imageHeight:

          image!.height.toDouble(),

    );



    controller = PuzzleController(

      pieces: pieces,

    );



    preparePieces();



    if (!mounted) return;



    setState(() {

      loading = false;

    });


  }







  Future<ui.Image> loadImage(

    String path,

  ) async {


    final completer =

        Completer<ui.Image>();



    final stream = AssetImage(path)

        .resolve(

          const ImageConfiguration(),

        );



    late ImageStreamListener listener;



    listener = ImageStreamListener(

      (info, _) {


        if (!completer.isCompleted) {


          completer.complete(

            info.image,

          );


        }


        stream.removeListener(

          listener,

        );


      },


      onError: (error, stack) {


        completer.completeError(

          error,

          stack,

        );


        stream.removeListener(

          listener,

        );


      },


    );



    stream.addListener(

      listener,

    );



    return completer.future;


  }







  void preparePieces() {


    pieces.shuffle();



    for (final piece in pieces) {


      piece.position = Offset.zero;


      piece.placed = false;


      piece.dragOffset = null;


    }


  }







  // بداية سحب القطعة

  void startDrag(

    PuzzlePiece piece,

    Offset globalPosition,

  ) {


    if (piece.placed) return;



    setState(() {


      draggingPiece = piece;


      dragPosition = globalPosition;


      piece.dragOffset =

          globalPosition;


    });


  }







  // تحريك القطعة فوق الشاشة

  void updateDrag(

    DragUpdateDetails details,

  ) {


    if (draggingPiece == null) return;



    setState(() {


      dragPosition += details.delta;



      draggingPiece!.position =

          Offset(

            dragPosition.dx -

                pieceSize / 2,

            dragPosition.dy -

                pieceSize / 2,

          );


    });


  }







  // إنهاء السحب

  void endDrag() {


    if (draggingPiece == null)

      return;



    final piece = draggingPiece!;



    final correct =

        controller.checkPiecePosition(

          piece,

          pieceSize,

        );



    setState(() {


      if (correct) {


        piece.lock(

          pieceSize,

        );


      } else {


        // رجوع للشريط

        piece.position =

            Offset.zero;


      }



      draggingPiece = null;


      piece.dragOffset = null;


    });



    checkComplete();


  }

  void checkComplete() {


    if (controller.isCompleted &&

        !completed) {


      completed = true;



      Future.delayed(

        const Duration(

          milliseconds: 400,

        ),


        () {


          if (!mounted) return;



          showDialog(

            context: context,

            builder: (_) => AlertDialog(

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

                  },

                  child:

                      const Text(

                    "ممتاز",

                  ),

                ),

              ],

            ),

          );


        },

      );


    }

  }








  @override

  Widget build(

    BuildContext context,

  ) {



    if (loading) {


      return const Scaffold(

        body: Center(

          child:

              CircularProgressIndicator(),

        ),

      );


    }





    return Scaffold(


      backgroundColor:

          const Color(0xff10233d),



      appBar: AppBar(


        backgroundColor:

            Colors.transparent,


        elevation: 0,


        title:

            Text(

          widget.level.title,

        ),

      ),





      body: Stack(


        children: [


          SafeArea(


            child: Column(


              children: [





                //==========================
                // شريط القطع
                //==========================


                SizedBox(


                  height:

                      pieceSize + 35,



                  child:

                      ListView.builder(


                    scrollDirection:

                        Axis.horizontal,



                    padding:

                        const EdgeInsets.symmetric(

                      horizontal: 15,

                    ),



                    itemCount:

                        pieces.length,



                    itemBuilder:

                        (context,index){


                      final piece =

                          pieces[index];



                      if(piece.placed){

                        return const SizedBox(

                          width: 5,

                        );

                      }



                      return GestureDetector(


                        onPanStart:

                            (details){


                          startDrag(

                            piece,

                            details.globalPosition,

                          );


                        },



                        child:

                            AnimatedScale(


                          duration:

                              const Duration(

                            milliseconds: 180,

                          ),



                          scale:

                              draggingPiece == piece

                                  ? 1.15

                                  : 1,



                          child:

                              PuzzlePieceWidget(


                            piece:

                                piece,



                            image:

                                puzzleImage,



                            size:

                                pieceSize,


                          ),


                        ),


                      );


                    },


                  ),


                ),







                const SizedBox(

                  height: 15,

                ),





                //==========================
                // لوحة البازل
                //==========================


                Expanded(


                  child:

                      Center(


                    child:

                        Container(


                      key:

                          boardKey,



                      width:

                          boardSize,



                      height:

                          boardSize,



                      decoration:

                          BoxDecoration(


                        color:

                            Colors.black26,



                        borderRadius:

                            BorderRadius.circular(

                              25,

                            ),



                        boxShadow: const [

                          BoxShadow(

                            color:

                                Colors.black45,

                            blurRadius:

                                25,

                            offset:

                                Offset(

                              0,

                              12,

                            ),

                          ),

                        ],


                      ),



                      child:

                          Stack(


                        clipBehavior:

                            Clip.none,


                        children: [



                          // القطع المثبتة


                          ...pieces

                              .where(

                                (p)=>

                                    p.placed,

                              )

                              .map(

                                (piece){


                              return Positioned(


                                left:

                                    piece.column *

                                        pieceSize,


                                top:

                                    piece.row *

                                        pieceSize,



                                child:

                                    PuzzlePieceWidget(


                                  piece:

                                      piece,


                                  image:

                                      puzzleImage,


                                  size:

                                      pieceSize,


                                ),


                              );


                            },

                          ),


                        ],


                      ),

                    ),

                  ),

                ),


              ],


            ),

          ),



          //==============================
          // القطعة أثناء السحب
          //==============================


          if(draggingPiece != null)

            Positioned(

              left:

                  dragPosition.dx -

                      pieceSize / 2,


              top:

                  dragPosition.dy -

                      pieceSize / 2,



              child:

                  IgnorePointer(

                    child:

                        AnimatedScale(

                      duration:

                          const Duration(

                        milliseconds:150,

                      ),

                      scale:

                          1.15,

                      child:

                          PuzzlePieceWidget(


                        piece:

                            draggingPiece!,



                        image:

                            puzzleImage,



                        size:

                            pieceSize,


                      ),

                    ),

                  ),

            ),


        ],

      ),

    );

  }

  @override
  void dispose() {

    draggingPiece = null;

    super.dispose();

  }


}