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

              milliseconds:120,

            ),



            decoration:BoxDecoration(



              borderRadius:

              BorderRadius.circular(12),



              boxShadow:[



                BoxShadow(



                  color:

                  Colors.black.withOpacity(



                    widget.piece.placed

                        ? 0.05

                        : pressed

                        ? 0.35

                        : 0.18,



                  ),



                  blurRadius:

                  pressed ? 18 : 8,



                  offset:Offset(



                    0,

                    pressed ? 8 : 4,



                  ),



                ),



              ],



            ),





            child:CustomPaint(



              size:

              Size(

                widget.size,

                widget.size,

              ),





              painter:PuzzlePainter(



                piece:

                widget.piece,



                image:

                widget.image,



              ),



            ),



          ),



        ),



      ),



    );



  }



}