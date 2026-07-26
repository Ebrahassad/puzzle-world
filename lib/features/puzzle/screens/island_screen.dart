import 'package:flutter/material.dart';

import '../data/puzzle_level_data.dart';
import '../managers/puzzle_progress_manager.dart';
import '../models/puzzle_model.dart';

import 'puzzle_level_screen.dart';



class IslandScreen extends StatefulWidget {

  final PuzzleModel island;


  const IslandScreen({

    super.key,

    required this.island,

  });



  @override
  State<IslandScreen> createState() =>
      _IslandScreenState();

}





class _IslandScreenState
    extends State<IslandScreen> {


  int totalStars = 0;


  int completedLevels = 0;



  @override
  void initState() {

    super.initState();

    loadData();

  }




  Future<void> loadData() async {


    final stars =
        await PuzzleProgressManager.getTotalStars();



    if(mounted){

      setState(() {

        totalStars = stars;

      });

    }


  }





  void openLevels(){


    Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) =>
            PuzzleLevelScreen(

              puzzle: widget.island,

            ),

      ),

    );


  }







  @override
  Widget build(BuildContext context) {


    final levels =
    PuzzleLevelData.getLevels(
      widget.island.id,
    );



    return Scaffold(


      body: Stack(


        children: [



          Positioned.fill(


            child: Image.asset(

              widget.island.image,

              fit: BoxFit.cover,

              errorBuilder:
                  (context,error,stack){

                return Container(

                  color:
                  Colors.blueGrey,

                );

              },

            ),

          ),





          Container(

            color:
            Colors.black38,

          ),







          SafeArea(


            child: Column(


              children: [





                // شريط الأعلى

                Padding(

                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),

                  child: Row(


                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,


                    children: [




                      IconButton(

                        onPressed: (){

                          Navigator.pop(context);

                        },

                        icon:
                        const Icon(

                          Icons.arrow_back,

                          color:
                          Colors.white,

                          size:32,

                        ),

                      ),





                      Text(

                        widget.island.title,

                        style:
                        const TextStyle(

                          color:
                          Colors.white,

                          fontSize:26,

                          fontWeight:
                          FontWeight.bold,

                        ),

                      ),





                      Row(

                        children: [



                          Container(

                            padding:
                            const EdgeInsets.symmetric(

                              horizontal:12,

                              vertical:7,

                            ),

                            decoration:
                            BoxDecoration(

                              color:
                              Colors.black38,

                              borderRadius:
                              BorderRadius.circular(20),

                            ),

                            child: Text(

                              "⭐ $totalStars",

                              style:
                              const TextStyle(

                                color:
                                Colors.white,

                                fontSize:18,

                                fontWeight:
                                FontWeight.bold,

                              ),

                            ),

                          ),



                          IconButton(

                            onPressed: (){

                              // الإعدادات لاحقاً

                            },

                            icon:
                            const Icon(

                              Icons.settings,

                              color:
                              Colors.white,

                            ),

                          ),


                        ],

                      ),



                    ],


                  ),

                ),





                const SizedBox(height:20),






                // الصورة والوصف


                Container(

                  margin:
                  const EdgeInsets.symmetric(
                    horizontal:20,
                  ),


                  padding:
                  const EdgeInsets.all(15),


                  decoration:
                  BoxDecoration(

                    color:
                    Colors.white24,

                    borderRadius:
                    BorderRadius.circular(30),

                  ),


                  child: Column(


                    children: [



                      Text(

                        widget.island.description,

                        textAlign:
                        TextAlign.center,

                        style:
                        const TextStyle(

                          color:
                          Colors.white,

                          fontSize:18,

                        ),

                      ),



                      const SizedBox(height:10),



                      Text(

                        "${widget.island.totalLevels} مراحل",

                        style:
                        const TextStyle(

                          color:
                          Colors.white,

                          fontSize:18,

                          fontWeight:
                          FontWeight.bold,

                        ),

                      ),



                    ],


                  ),


                ),






                const SizedBox(height:25),






                Expanded(


                  child: GridView.builder(


                    padding:
                    const EdgeInsets.all(20),


                    itemCount:
                    levels.length,


                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(


                      crossAxisCount:4,


                      crossAxisSpacing:15,


                      mainAxisSpacing:15,


                    ),



                    itemBuilder:
                        (context,index){



                      final levelNumber =
                          index + 1;



                      final unlocked =
                          levelNumber == 1 ||
                          levelNumber <= completedLevels + 1;




                      return GestureDetector(


                        onTap: unlocked
                            ? openLevels
                            : null,


                        child: Container(


                          decoration:
                          BoxDecoration(


                            color:
                            unlocked
                                ? Colors.white
                                : Colors.black45,


                            borderRadius:
                            BorderRadius.circular(20),


                          ),



                          child:
                          Center(


                            child:
                            unlocked


                                ? Column(

                              mainAxisAlignment:
                              MainAxisAlignment.center,

                              children: [


                                Text(

                                  "$levelNumber",

                                  style:
                                  const TextStyle(

                                    fontSize:26,

                                    fontWeight:
                                    FontWeight.bold,

                                    color:
                                    Colors.blue,

                                  ),

                                ),


                                const Text(

                                  "⭐",

                                  style:
                                  TextStyle(

                                    fontSize:18,

                                  ),

                                ),



                              ],

                            )



                                : const Icon(

                              Icons.lock,

                              color:
                              Colors.white,

                              size:30,

                            ),


                          ),


                        ),


                      );

                    },


                  ),

                ),





                // زر دخول الجزيرة


                Padding(

                  padding:
                  const EdgeInsets.all(15),


                  child: ElevatedButton(

                    style:
                    ElevatedButton.styleFrom(

                      minimumSize:
                      const Size(
                        double.infinity,
                        55,
                      ),

                      shape:
                      RoundedRectangleBorder(

                        borderRadius:
                        BorderRadius.circular(30),

                      ),

                    ),


                    onPressed:
                    openLevels,


                    child:
                    const Text(

                      "ابدأ المغامرة 🧩",

                      style:
                      TextStyle(

                        fontSize:22,

                        fontWeight:
                        FontWeight.bold,

                      ),

                    ),

                  ),

                ),



              ],


            ),


          ),


        ],


      ),


    );

  }

}