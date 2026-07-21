import 'package:flutter/material.dart';

import '../models/puzzle_model.dart';
import '../models/puzzle_level_model.dart';

import '../puzzle_engine/puzzle_generator.dart';
import '../puzzle_engine/puzzle_piece.dart';
import '../puzzle_engine/puzzle_controller.dart';

import '../utils/image_helper.dart';
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


  late List<PuzzlePiece> pieces;

  late PuzzleController controller;


  final double boardSize = 350;



  @override
  void initState() {

    super.initState();


    pieces = PuzzleGenerator.generate(

      rows: widget.level.gridSize,

      columns: widget.level.gridSize,

      imageWidth: boardSize,

      imageHeight: boardSize,

    );


    controller = PuzzleController(

      pieces: pieces,

    );

  }





  void dropPiece(

      PuzzlePiece piece,

      Offset position,

      ) {


    setState(() {


      piece.position = Offset(

        position.dx - 40,

        position.dy - 120,

      );


      controller.checkPiecePosition(

        piece,

        boardSize / widget.level.gridSize,

      );


    });



    if(controller.isCompleted){

      showWinDialog();

    }

  }






  void showWinDialog(){


    Future.delayed(

      const Duration(milliseconds:500),

          (){


        if(!mounted) return;


        showDialog(


          context:context,


          builder:(context){


            return AlertDialog(


              shape:RoundedRectangleBorder(


                borderRadius:
                BorderRadius.circular(25),


              ),



              title:const Text(

                '🎉 أحسنت',

                textAlign:TextAlign.center,

              ),



              content:const Text(

                'أكملت البازل بنجاح',

                textAlign:TextAlign.center,

              ),



              actions:[


                Center(


                  child:ElevatedButton(


                    onPressed:(){


                      Navigator.pop(context);


                    },


                    child:const Text(

                      'ممتاز',

                    ),


                  ),


                )


              ],


            );


          },


        );


      },

    );

  }






  @override
  Widget build(BuildContext context) {


    final image = ImageHelper.getPuzzleImage(

      widget.puzzle.image,

    );



    final pieceSize =

        boardSize / widget.level.gridSize;




    return Scaffold(


      body:Container(


        decoration:const BoxDecoration(


          gradient:LinearGradient(


            colors:[

              Color(0xff89F7FE),

              Color(0xff66A6FF),

            ],


          ),


        ),



        child:SafeArea(


          child:Column(


            children:[



              const SizedBox(height:20),



              Text(


                widget.puzzle.title,


                style:const TextStyle(


                  color:Colors.white,


                  fontSize:30,


                  fontWeight:FontWeight.bold,


                ),


              ),




              Expanded(


                child:Stack(


                  children:[



                    Center(


                      child:Container(


                        width:boardSize,

                        height:boardSize,


                        decoration:BoxDecoration(


                          color:Colors.white24,


                          borderRadius:
                          BorderRadius.circular(20),


                          border:Border.all(

                            color:Colors.white,

                            width:2,

                          ),


                        ),


                      ),


                    ),





                    ...pieces.map((piece){


                      return Positioned(


                        left:piece.position.dx,

                        top:piece.position.dy,



                        child:Draggable<PuzzlePiece>(



                          data:piece,



                          feedback:PuzzlePieceWidget(


                            piece:piece,


                            image:image,


                            size:pieceSize,


                          ),



                          childWhenDragging:

                          const SizedBox(),




                          onDragEnd:(details){



                            dropPiece(


                              piece,


                              details.offset,


                            );



                          },



                          child:PuzzlePieceWidget(


                            piece:piece,


                            image:image,


                            size:pieceSize,


                          ),



                        ),


                      );


                    }),



                  ],


                ),

              ),



            ],


          ),

        ),


      ),


    );


  }


}