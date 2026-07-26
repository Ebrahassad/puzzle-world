import 'package:flutter/material.dart';

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


  @override
  void initState() {

    super.initState();

    loadStars();

  }






  Future<void> loadStars() async {


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


    return Scaffold(


      body: Stack(


        children: [



          // خلفية الجزيرة

          Positioned.fill(

            child: Image.asset(

              widget.island.image,

              fit: BoxFit.contain,

              errorBuilder:
                  (context,error,stackTrace){

                return Container(

                  color:
                  Colors.blueGrey,

                );

              },

            ),

          ),





          // طبقة شفافة

          Positioned.fill(

            child: Container(

              color:
              Colors.black26,

            ),

          ),







          SafeArea(


            child: Column(


              children: [





                // شريط الأعلى

                Padding(

                  padding:
                  const EdgeInsets.symmetric(
                    horizontal:10,
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






                      Expanded(

                        child: Text(

                          widget.island.title,


                          textAlign:
                          TextAlign.center,


                          style:
                          const TextStyle(

                            color:
                            Colors.white,

                            fontSize:26,

                            fontWeight:
                            FontWeight.bold,

                            shadows:[

                              Shadow(

                                color:
                                Colors.black54,

                                blurRadius:8,

                              ),

                            ],

                          ),

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
                              Colors.black45,

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

                              // صفحة الإعدادات لاحقاً

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







                const Spacer(),








                // معلومات الجزيرة

                Container(

                  margin:
                  const EdgeInsets.all(20),


                  padding:
                  const EdgeInsets.all(20),


                  decoration:
                  BoxDecoration(

                    color:
                    Colors.white.withOpacity(0.85),


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

                          fontSize:18,

                          fontWeight:
                          FontWeight.bold,

                        ),

                      ),




                      const SizedBox(height:15),






                      Row(

                        mainAxisAlignment:
                        MainAxisAlignment.center,


                        children: [



                          const Icon(

                            Icons.extension,

                            color:
                            Colors.orange,

                          ),




                          const SizedBox(width:8),




                          Text(

                            "${widget.island.totalLevels} مراحل",


                            style:
                            const TextStyle(

                              fontSize:18,

                              fontWeight:
                              FontWeight.bold,

                            ),

                          ),


                        ],

                      ),



                    ],


                  ),

                ),







                // زر الدخول

                Padding(

                  padding:
                  const EdgeInsets.fromLTRB(
                    20,
                    0,
                    20,
                    25,
                  ),


                  child: ElevatedButton(

                    onPressed:
                    openLevels,


                    style:
                    ElevatedButton.styleFrom(


                      minimumSize:
                      const Size(
                        double.infinity,
                        60,
                      ),



                      backgroundColor:
                      Colors.orange,



                      shape:
                      RoundedRectangleBorder(

                        borderRadius:
                        BorderRadius.circular(35),

                      ),


                    ),



                    child:
                    const Text(

                      "ابدأ المغامرة 🧩",


                      style:
                      TextStyle(

                        fontSize:23,

                        fontWeight:
                        FontWeight.bold,

                        color:
                        Colors.white,

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