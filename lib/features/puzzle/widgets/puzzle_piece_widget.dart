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
    extends State<PuzzlePieceWidget>
    with SingleTickerProviderStateMixin {


  bool pressed = false;



  late AnimationController _glowController;


  late Animation<double> _glowAnimation;







  @override
  void initState(){

    super.initState();



    _glowController = AnimationController(

      vsync: this,

      duration: const Duration(seconds:2),

    );



    _glowAnimation = Tween<double>(

      begin:0,

      end:1,

    ).animate(

      CurvedAnimation(

        parent:_glowController,

        curve: Curves.easeInOut,

      ),

    );



    if(widget.piece.placed){

      _glowController.repeat(

        reverse:true,

      );

    }

  }








  @override
  void didUpdateWidget(
      covariant PuzzlePieceWidget oldWidget,
      ){


    super.didUpdateWidget(oldWidget);



    if(widget.piece.placed &&
        !oldWidget.piece.placed){


      _glowController.repeat(

        reverse:true,

      );

    }

  }







  void setPressed(bool value){



    if(widget.piece.placed){

      return;

    }



    setState((){

      pressed=value;

    });


  }








  @override
  void dispose(){


    _glowController.dispose();


    super.dispose();

  }








  @override
  Widget build(BuildContext context){


    final placed =
        widget.piece.placed;





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




        child: AnimatedScale(



          scale:

          pressed ? 1.04 : 1,



          duration:

          const Duration(

            milliseconds:120,

          ),




          child: AnimatedContainer(



            duration:

            const Duration(

              milliseconds:300,

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

                        ?0.12

                        :pressed

                        ?0.35

                        :0.18,

                  ),




                  blurRadius:

                  placed

                      ?10

                      :pressed

                      ?18

                      :8,




                  offset:

                  Offset(

                    0,

                    pressed ?8:4,

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







                // لمعة القطعة بعد التركيب

                if(placed)

                  AnimatedBuilder(



                    animation:

                    _glowAnimation,



                    builder:

                        (context,child){



                      return Positioned.fill(



                        child: Container(



                          decoration:

                          BoxDecoration(



                            borderRadius:

                            BorderRadius.circular(12),



                            gradient:

                            LinearGradient(



                              begin:

                              Alignment.topLeft,



                              end:

                              Alignment.bottomRight,



                              colors:[



                                Colors.white.withOpacity(

                                  0.35 *

                                      _glowAnimation.value,

                                ),



                                Colors.transparent,



                              ],



                            ),



                          ),



                        ),



                      );



                    },


                  ),





                // طبقة نجاح خفيفة

                if(placed)

                  Positioned.fill(



                    child: Container(



                      decoration:

                      BoxDecoration(



                        color:

                        Colors.white.withOpacity(

                          0.08,

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