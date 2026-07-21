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





  @override
  Widget build(BuildContext context) {



    return GestureDetector(



      onTapDown:(_){


        setState((){


          pressed = true;


        });


      },



      onTapUp:(_){


        setState((){


          pressed = false;


        });


      },



      onTapCancel:(){


        setState((){


          pressed = false;


        });


      },



      child:AnimatedScale(



        scale:

        pressed ? 1.12 : 1,



        duration:

        const Duration(

          milliseconds:150,

        ),




        child:AnimatedContainer(



          duration:

          const Duration(

            milliseconds:150,

          ),



          decoration:

          BoxDecoration(



            boxShadow:[



              BoxShadow(



                color:

                Colors.black.withOpacity(



                  pressed ? 0.35 : 0.15,



                ),



                blurRadius:

                pressed ? 18 : 8,



                offset:Offset(



                  0,


                  pressed ? 10 : 5,



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




            painter:

            PuzzlePainter(



              piece:

              widget.piece,



              image:

              widget.image,



            ),



          ),



        ),



      ),



    );


  }


}