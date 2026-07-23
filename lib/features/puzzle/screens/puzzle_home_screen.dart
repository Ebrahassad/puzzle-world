import 'package:flutter/material.dart';

import '../data/puzzle_data.dart';
import '../data/puzzle_level_data.dart';

import '../models/puzzle_model.dart';

import '../managers/puzzle_progress_manager.dart';


import 'puzzle_level_screen.dart';



class PuzzleHomeScreen extends StatefulWidget {

  const PuzzleHomeScreen({
    super.key,
  });


  @override
  State<PuzzleHomeScreen> createState() =>
      _PuzzleHomeScreenState();

}





class _PuzzleHomeScreenState
    extends State<PuzzleHomeScreen> {



  int totalStars = 0;

  bool loading = true;






  @override
  void initState(){

    super.initState();

    loadData();

  }







  Future<void> loadData() async {


    final stars =
        await PuzzleProgressManager.getTotalStars();


    if(mounted){

      setState((){

        totalStars = stars;

        loading = false;

      });

    }


  }









  void openWorld(
      PuzzleModel puzzle,
      ){



    final levels =
        PuzzleLevelData.getLevels(
          puzzle.id,
        );



    if(levels.isEmpty){

      return;

    }






    Navigator.push(

      context,

      MaterialPageRoute(

        builder:(_)=>

            PuzzleLevelScreen(

              puzzle:puzzle,

            ),

      ),

    );



  }









  @override
  Widget build(BuildContext context){


    if(loading){

      return const Scaffold(

        body:Center(

          child:CircularProgressIndicator(),

        ),

      );

    }






    return Scaffold(



      body:Container(



        decoration:const BoxDecoration(



          gradient:LinearGradient(



            colors:[

              Color(0xff89F7FE),

              Color(0xff66A6FF),

            ],



            begin:

            Alignment.topCenter,



            end:

            Alignment.bottomCenter,



          ),



        ),





        child:SafeArea(



          child:Column(



            children:[




              const SizedBox(height:25),




Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [

    Image.asset(
      "assets/images/ui/puzzle_logo.png",
      width: 65,
      height: 65,
      fit: BoxFit.contain,
    ),

    const SizedBox(width: 12),

    const Text(
      "Puzzle World",
      style: TextStyle(
        color: Colors.white,
        fontSize: 32,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            color: Colors.black38,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
    ),

    const SizedBox(width: 15),

    Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 8,
      ),

      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Text(
        "⭐ $totalStars",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

  ],
),







              const SizedBox(height:30),







              Expanded(



                child:GridView.builder(



                  padding:
                  const EdgeInsets.all(20),



                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(



                    crossAxisCount:2,



                    mainAxisSpacing:20,



                    crossAxisSpacing:20,



                    childAspectRatio:0.85,



                  ),





                  itemCount:
                  PuzzleData.puzzles.length,





                  itemBuilder:(context,index){



                    final puzzle =
                    PuzzleData.puzzles[index];



                    final levelCount =
                    PuzzleLevelData
                        .getLevels(
                      puzzle.id,
                    )
                        .length;






                    return GestureDetector(



                      onTap:(){

                        openWorld(
                          puzzle,
                        );

                      },





                      child:Container(



                        decoration:BoxDecoration(



                          color:Colors.white,



                          borderRadius:
                          BorderRadius.circular(30),




                          boxShadow:[



                            BoxShadow(



                              color:
                              Colors.black26,



                              blurRadius:15,



                              offset:
                              const Offset(
                                0,
                                8,
                              ),



                            ),



                          ],



                        ),





                        child:Column(



                          mainAxisAlignment:
                          MainAxisAlignment.center,



                          children:[





                            Expanded(



                              child:Padding(



                                padding:
                                const EdgeInsets.all(15),



                                child:Image.asset(



                                  puzzle.image,



                                  fit:
                                  BoxFit.contain,



                                  errorBuilder:
                                      (context,error,stack){



                                    return const Icon(

                                      Icons.extension,

                                      size:70,

                                      color:
                                      Colors.orange,

                                    );



                                  },



                                ),



                              ),



                            ),







                            Text(



                              puzzle.title,



                              textAlign:
                              TextAlign.center,



                              style:const TextStyle(



                                fontSize:20,



                                fontWeight:
                                FontWeight.bold,



                                color:
                                Colors.blue,



                              ),



                            ),






                            const SizedBox(height:8),





                            Text(



                              "🧩 $levelCount مراحل",



                              style:const TextStyle(



                                fontSize:16,



                                color:
                                Colors.grey,



                              ),



                            ),





                            const SizedBox(height:15),



                          ],



                        ),



                      ),



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