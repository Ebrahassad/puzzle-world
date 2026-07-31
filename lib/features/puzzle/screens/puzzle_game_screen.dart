import 'dart:async';
import 'dart:math' as math;
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





  PuzzlePiece? draggingPiece;



  Offset dragPosition = Offset.zero;



  Offset dragAnchor = Offset.zero;



  Offset boardPosition = Offset.zero;



  final GlobalKey boardKey = GlobalKey();



  bool boardReady = false;






  double get boardSize {


    return MediaQuery.of(context).size.width * 0.90;


  }






  double get pieceSize {


    return boardSize /

        widget.level.gridSize;


  }






  double get trayPieceSize {


    return math.max(

      95,

      math.min(

        120,

        boardSize * 0.28,

      ),

    );


  }






  double get trayHeight {


    return trayPieceSize + 35;


  }







  @override
  void initState(){


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



    if(!mounted) return;



    setState((){


      loading = false;


    });



    WidgetsBinding.instance

        .addPostFrameCallback((_){


      updateBoardPosition();


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



        if(!completer.isCompleted){


          completer.complete(

            info.image,

          );


        }



        stream.removeListener(

          listener,

        );


      },


      onError:(error,stackTrace){


        completer.completeError(

          error,

          stackTrace,

        );


      },

    );



    stream.addListener(

      listener,

    );



    return completer.future;

  }







  void preparePieces(){


    pieces.shuffle();



    for(final piece in pieces){


      piece.reset();


    }


  }






  void updateBoardPosition(){


    final box =

        boardKey.currentContext

        ?.findRenderObject()

        as RenderBox?;



    if(box != null){


      boardPosition =

          box.localToGlobal(

            Offset.zero,

          );



      boardReady = true;


    }


  }

  //=====================================
  // بداية السحب
  //=====================================

  void startDrag(
    PuzzlePiece piece,
    Offset globalPosition,
  ) {

    if(piece.placed) return;


    updateBoardPosition();



    final currentSize =
        piece.position == Offset.zero
            ? trayPieceSize
            : pieceSize;



    if(piece.position == Offset.zero){

      dragAnchor = Offset(
        currentSize / 2,
        currentSize / 2,
      );

    } else {

      dragAnchor =
          globalPosition -
          (boardPosition + piece.position);

    }



    setState((){

      draggingPiece = piece;

      dragPosition = globalPosition;

    });


  }







  //=====================================
  // تحريك القطعة
  //=====================================

  void updateDrag(
    DragUpdateDetails details,
  ){

    if(draggingPiece == null) return;



    setState((){


      dragPosition += details.delta;



      final topLeft =
          dragPosition - dragAnchor;



      draggingPiece!.position =
          topLeft - boardPosition;



    });


  }







  //=====================================
  // إنهاء السحب
  //=====================================

  void endDrag(){


    if(draggingPiece == null) return;



    final piece = draggingPiece!;



    final correct =
        controller.checkPiecePosition(
          piece,
          pieceSize,
        );



    if(!correct){


      final center =

          boardPosition +

          piece.position +

          Offset(
            trayPieceSize / 2,
            trayPieceSize / 2,
          );



      if(center.dy < trayHeight){


        piece.position =
            Offset.zero;


      }


    }



    controller.endDragging(piece);



    setState((){


      draggingPiece = null;


    });



    checkComplete();


  }







  //=====================================
  // فحص الفوز
  //=====================================

  void checkComplete(){


    if(
      controller.isCompleted &&
      !completed
    ){


      completed = true;



      Future.delayed(

        const Duration(
          milliseconds:500,
        ),

        (){


          if(!mounted) return;



          showDialog(

            context: context,

            builder:(_){


              return AlertDialog(

                title:

                    const Text(
                      "🎉 أحسنت",
                    ),


                content:

                    const Text(
                      "اكتملت الصورة",
                    ),

              );


            },

          );


        },

      );


    }


  }







  //=====================================
  // القطع التي خرجت من الشريط
  //=====================================

  bool isFloatingPiece(
    PuzzlePiece piece,
  ){

    return

        !piece.placed &&

        piece.position != Offset.zero &&

        piece != draggingPiece;

  }







  //=====================================
  // قطعة الشريط
  //=====================================

  Widget buildTrayPiece(
    PuzzlePiece piece,
  ){

    return GestureDetector(

      behavior:
          HitTestBehavior.translucent,


      onPanStart:(details){

        startDrag(

          piece,

          details.globalPosition,

        );

      },


      onPanUpdate:

          updateDrag,


      onPanEnd:(_){

        endDrag();

      },


      child:

      PuzzlePieceWidget(

        piece:piece,

        image:puzzleImage,

        size:trayPieceSize,

        isActive:

            draggingPiece == piece,

      ),

    );


  }







  //=====================================
  // قطعة حرة فوق اللوحة
  //=====================================

  Widget buildFloatingPiece(
    PuzzlePiece piece,
  ){

    return Positioned(

      left:

          boardPosition.dx +

          piece.position.dx,


      top:

          boardPosition.dy +

          piece.position.dy,


      child:

      GestureDetector(

        behavior:

            HitTestBehavior.translucent,


        onPanStart:(details){

          startDrag(

            piece,

            details.globalPosition,

          );

        },


        onPanUpdate:

            updateDrag,


        onPanEnd:(_){

          endDrag();

        },


        child:

        PuzzlePieceWidget(

          piece:piece,

          image:puzzleImage,

          size:trayPieceSize,

          isActive:

              draggingPiece == piece,

        ),

      ),

    );


  }

  //=====================================
  // القطع المثبتة داخل اللوحة
  //=====================================

  Widget buildPlacedPiece(
    PuzzlePiece piece,
  ){

    return Positioned(

      left:

          piece.column * pieceSize,


      top:

          piece.row * pieceSize,


      child:

      PuzzlePieceWidget(

        piece:piece,

        image:puzzleImage,

        size:pieceSize,

      ),

    );


  }







  //=====================================
  // لوحة البازل
  //=====================================

  Widget buildBoard(){


    return Container(

      key:boardKey,


      width:boardSize,


      height:boardSize,



      decoration:BoxDecoration(

        color:

            Colors.black.withOpacity(0.25),


        borderRadius:

            BorderRadius.circular(25),


        boxShadow:[


          BoxShadow(

            color:

                Colors.black.withOpacity(0.45),


            blurRadius:25,


            offset:

                const Offset(0,12),

          ),


        ],

      ),



      child:

      ClipRRect(

        borderRadius:

            BorderRadius.circular(25),



        child:

        Stack(

          clipBehavior:

              Clip.none,


          children:[



            Positioned.fill(

              child:

              IgnorePointer(

                child:

                Opacity(

                  opacity:0.08,


                  child:

                  Image.asset(

                    widget.level.image,

                    fit:BoxFit.cover,

                  ),

                ),

              ),

            ),





            ...pieces

                .where(

                  (p)=>p.placed,

                )

                .map(

                  buildPlacedPiece,

                ),



          ],

        ),

      ),

    );


  }







  //=====================================
  // شريط القطع
  //=====================================

  Widget buildTray(){



    final trayPieces =

        pieces.where(

          (p)=>

          !p.placed &&

          p.position == Offset.zero &&

          p != draggingPiece,

        ).toList();





    return Container(

      height:

          trayHeight,


      margin:

          const EdgeInsets.symmetric(

            horizontal:12,

          ),


      padding:

          const EdgeInsets.symmetric(

            vertical:8,

          ),



      decoration:BoxDecoration(

        color:

            Colors.white.withOpacity(0.06),


        borderRadius:

            BorderRadius.circular(22),

      ),



      child:

      ListView.separated(

        scrollDirection:

            Axis.horizontal,


        padding:

            const EdgeInsets.symmetric(

              horizontal:12,

            ),



        itemCount:

            trayPieces.length,



        separatorBuilder:

            (_,__) =>

            const SizedBox(

              width:12,

            ),



        itemBuilder:

            (context,index){



          return SizedBox(

            width:

                trayPieceSize,


            child:

            Center(

              child:

              buildTrayPiece(

                trayPieces[index],

              ),

            ),

          );


        },


      ),


    );


  }








  //=====================================
  // القطعة أثناء السحب
  //=====================================

  Widget buildDraggingPiece(){


    final piece = draggingPiece!;



    return Positioned(

      left:

          dragPosition.dx -

          dragAnchor.dx,


      top:

          dragPosition.dy -

          dragAnchor.dy,



      child:

      IgnorePointer(

        child:

        AnimatedScale(

          scale:1.08,


          duration:

              const Duration(

                milliseconds:120,

              ),



          child:

          PuzzlePieceWidget(

            piece:piece,

            image:puzzleImage,

            size:trayPieceSize,

            isActive:true,

          ),

        ),

      ),

    );


  }







  @override
  Widget build(
    BuildContext context,
  ){


    if(loading){


      return const Scaffold(

        body:

        Center(

          child:

          CircularProgressIndicator(),

        ),

      );


    }





    if(!boardReady){


      WidgetsBinding.instance

          .addPostFrameCallback((_){

        updateBoardPosition();

      });


    }






    return Scaffold(

      backgroundColor:

          const Color(0xff10233d),



      body:

      SafeArea(

        child:

        Stack(

          children:[



            Column(

              children:[


                buildTray(),



                const SizedBox(

                  height:15,

                ),



                Expanded(

                  child:

                  Center(

                    child:

                    buildBoard(),

                  ),

                ),


              ],

            ),






            ...pieces

                .where(

                  isFloatingPiece,

                )

                .map(

                  buildFloatingPiece,

                ),





            if(draggingPiece != null)

              buildDraggingPiece(),



          ],

        ),

      ),

    );


  }








  @override
  void dispose(){


    draggingPiece = null;


    super.dispose();


  }



}