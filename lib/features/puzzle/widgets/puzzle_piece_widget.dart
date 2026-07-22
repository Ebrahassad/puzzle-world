import 'package:flutter/material.dart';

import '../engine/puzzle_piece.dart';
import '../engine/puzzle_painter.dart';



class PuzzlePieceWidget extends StatefulWidget {

  final PuzzlePiece piece;

  final ImageProvider image;

  final double size;


  const PuzzlePieceWidget({

    super.key,

    required this.piece,

    required this.image,

    required this.size,

  });



  @override
  State<PuzzlePieceWidget> createState() =>
      _PuzzlePieceWidgetState();

}





class _PuzzlePieceWidgetState
    extends State<PuzzlePieceWidget> {


  bool pressed = false;



  void setPressed(bool value){


    if(widget.piece.placed){

      return;

    }


    setState((){

      pressed = value;

    });


  }






  @override
  Widget build(BuildContext context){


    final placed = widget.piece.placed;



    return RepaintBoundary(


      child: GestureDetector(


        onTapDown:(_){

          setPressed(true);

        },


        onTapUp:(_){

          setPressed(false);

        },


        onTapCancel:(){

          setPressed(false);

        },



        child:AnimatedScale(


          scale:

          pressed ? 1.08 : 1,


          duration:

          const Duration(

            milliseconds:120,

          ),



          child:AnimatedContainer(


            duration:

            const Duration(

              milliseconds:250,

            ),



            clipBehavior:

            Clip.antiAlias,



            decoration:BoxDecoration(


              borderRadius:

              BorderRadius.circular(12),



              boxShadow:[


                BoxShadow(


                  color:

                  Colors.black.withOpacity(

                    placed

                        ? 0.08

                        : pressed

                        ? 0.35

                        : 0.18,

                  ),



                  blurRadius:

                  placed ? 5 : pressed ? 18 : 8,



                  offset:

                  Offset(

                    0,

                    pressed ? 8 : 4,

                  ),



                ),



              ],



            ),



            child:Stack(


              children:[



                CustomPaint(


                  size:

                  Size(

                    widget.size,

                    widget.size,

                  ),



                  painter:

                  PuzzlePainter(


                    piece:

                    widget.piece,


                    image:

                    widget.image,


                  ),



                ),




                if(placed)

                  Positioned.fill(


                    child:Container(


                      decoration:

                      BoxDecoration(


                        color:

                        Colors.white.withOpacity(

                          0.15,

                        ),



                        borderRadius:

                        BorderRadius.circular(12),



                      ),



                    ),


                  ),



              ],


            ),



          ),



        ),


      ),


    );


  }


}