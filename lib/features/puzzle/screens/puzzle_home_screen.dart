import 'package:flutter/material.dart';

import '../data/puzzle_data.dart';
import '../models/puzzle_model.dart';

import 'puzzle_levels_screen.dart';



class PuzzleHomeScreen extends StatelessWidget {

  const PuzzleHomeScreen({
    super.key,
  });



  @override
  Widget build(BuildContext context) {


    return Scaffold(


      body: Container(


        decoration: const BoxDecoration(


          gradient: LinearGradient(


            colors: [

              Color(0xff89F7FE),

              Color(0xff66A6FF),

            ],


            begin: Alignment.topCenter,

            end: Alignment.bottomCenter,


          ),


        ),




        child: SafeArea(


          child: Column(


            children: [



              const SizedBox(height:25),




              const Text(


                "🧩 عالم البازل",


                style: TextStyle(


                  color: Colors.white,

                  fontSize: 36,

                  fontWeight: FontWeight.bold,


                ),


              ),





              const SizedBox(height:20),





              Expanded(


                child: GridView.builder(


                  padding: const EdgeInsets.all(20),


                  itemCount: PuzzleData.puzzles.length,


                  gridDelegate:

                  const SliverGridDelegateWithFixedCrossAxisCount(


                    crossAxisCount:2,


                    crossAxisSpacing:18,


                    mainAxisSpacing:18,


                    childAspectRatio:0.75,


                  ),




                  itemBuilder:(context,index){


                    final puzzle =

                    PuzzleData.puzzles[index];



                    return PuzzleWorldCard(

                      puzzle:puzzle,

                    );


                  },


                ),


              ),



            ],


          ),


        ),


      ),


    );

  }

}








class PuzzleWorldCard extends StatefulWidget {


  final PuzzleModel puzzle;



  const PuzzleWorldCard({

    super.key,

    required this.puzzle,

  });



  @override
  State<PuzzleWorldCard> createState() =>

      _PuzzleWorldCardState();

}





class _PuzzleWorldCardState

    extends State<PuzzleWorldCard> {


  bool pressed = false;



  @override
  Widget build(BuildContext context) {


    return GestureDetector(


      onTapDown:(_){

        setState((){

          pressed=true;

        });

      },



      onTapCancel:(){

        setState((){

          pressed=false;

        });

      },



      onTapUp:(_){


        setState((){

          pressed=false;

        });



        Navigator.push(


          context,


          MaterialPageRoute(


            builder:(_)=>PuzzleLevelsScreen(

              puzzle:widget.puzzle,

            ),


          ),


        );


      },





      child: AnimatedScale(


        scale: pressed ? 0.95 : 1,


        duration:

        const Duration(

          milliseconds:120,

        ),





        child: Container(


          decoration: BoxDecoration(


            color: Colors.white,


            borderRadius:

            BorderRadius.circular(30),



            boxShadow:[


              BoxShadow(


                color:Colors.black.withOpacity(0.25),


                blurRadius:15,


                offset:

                const Offset(0,8),


              ),


            ],


          ),





          child: Column(


            children:[



              Expanded(


                child: Padding(


                  padding:

                  const EdgeInsets.all(15),


                  child: Image.asset(


                    widget.puzzle.image,


                    fit:BoxFit.contain,


                    errorBuilder:(context,error,stack){


                      return const Icon(


                        Icons.extension,


                        size:80,


                        color:Colors.orange,


                      );


                    },


                  ),


                ),


              ),





              Container(


                width:double.infinity,


                padding:

                const EdgeInsets.symmetric(

                  vertical:15,

                ),



                decoration:BoxDecoration(


                  color:

                  Colors.orange.shade400,


                  borderRadius:

                  const BorderRadius.vertical(

                    bottom:

                    Radius.circular(30),

                  ),


                ),





                child: Text(


                  widget.puzzle.title,


                  textAlign:

                  TextAlign.center,


                  style:const TextStyle(


                    color:Colors.white,


                    fontSize:20,


                    fontWeight:

                    FontWeight.bold,


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