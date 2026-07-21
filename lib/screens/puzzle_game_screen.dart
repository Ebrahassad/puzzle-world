import 'package:flutter/material.dart';

import '../models/puzzle_model.dart';
import '../models/puzzle_level_model.dart';


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


  late List<int> pieces;



  @override
  void initState() {

    super.initState();

    createPieces();

  }



  void createPieces(){

    pieces = List.generate(

      widget.level.piecesCount,

          (index)=> index,

    );


    pieces.shuffle();

  }



  @override
  Widget build(BuildContext context) {


    return Scaffold(


      body: Container(


        decoration: const BoxDecoration(


          gradient: LinearGradient(


            colors:[

              Color(0xff89F7FE),

              Color(0xff66A6FF),

            ],

          ),


        ),



        child: SafeArea(


          child: Column(


            children:[


              Padding(


                padding:
                const EdgeInsets.all(16),


                child: Text(


                  widget.puzzle.title,


                  style:const TextStyle(


                    color:Colors.white,


                    fontSize:30,


                    fontWeight:
                    FontWeight.bold,


                  ),


                ),


              ),




              Expanded(


                child:Center(


                  child:Container(


                    margin:
                    const EdgeInsets.all(20),


                    padding:
                    const EdgeInsets.all(10),


                    decoration:BoxDecoration(


                      color:Colors.white,


                      borderRadius:
                      BorderRadius.circular(25),


                      boxShadow:const[


                        BoxShadow(


                          color:Colors.black26,


                          blurRadius:15,


                          offset:Offset(0,8),


                        )


                      ],


                    ),



                    child:GridView.builder(


                      shrinkWrap:true,


                      itemCount:pieces.length,


                      gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(


                        crossAxisCount:
                        widget.level.gridSize,


                      ),



                      itemBuilder:(context,index){


                        return DragTarget<int>(


                          onAccept:(data){


                            setState((){


                              final old =
                              pieces.indexOf(data);


                              pieces[old]=
                              pieces[index];


                              pieces[index]=data;


                            });


                          },


                          builder:
                              (context,candidate,rejected){


                            return Draggable<int>(


                              data:pieces[index],


                              feedback:_PieceBox(

                                number:
                                pieces[index],

                              ),



                              childWhenDragging:
                              Container(),



                              child:_PieceBox(

                                number:
                                pieces[index],

                              ),



                            );


                          },

                        );


                      },


                    ),


                  ),


                ),


              ),



            ],


          ),


        ),


      ),


    );


  }

}





class _PieceBox extends StatelessWidget {


  final int number;


  const _PieceBox({

    required this.number,

  });



  @override
  Widget build(BuildContext context) {


    return Container(


      margin:
      const EdgeInsets.all(3),


      decoration:BoxDecoration(


        color:Colors.blue.shade300,


        borderRadius:
        BorderRadius.circular(8),


      ),



      child:Center(


        child:Text(


          '${number+1}',


          style:const TextStyle(


            color:Colors.white,


            fontSize:20,


            fontWeight:
            FontWeight.bold,


          ),


        ),


      ),


    );

  }

}