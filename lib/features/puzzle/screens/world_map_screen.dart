import 'package:flutter/material.dart';

import '../data/puzzle_data.dart';
import '../managers/puzzle_progress_manager.dart';
import '../models/puzzle_model.dart';

import 'island_screen.dart';



class WorldMapScreen extends StatefulWidget {


  const WorldMapScreen({

    super.key,

  });



  @override
  State<WorldMapScreen> createState() =>
      _WorldMapScreenState();


}





class _WorldMapScreenState
    extends State<WorldMapScreen> {


  int totalStars = 0;


  bool loading = true;






  @override
  void initState(){

    super.initState();

    loadStars();

  }







  Future<void> loadStars() async {


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

      PuzzleModel world,

      ){



    if(totalStars < world.requiredStars){



      ScaffoldMessenger.of(context)
          .showSnackBar(


        SnackBar(

          content: Text(

            "تحتاج ⭐ ${world.requiredStars} لفتح ${world.title}",

          ),

        ),


      );

      return;

    }






    Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) =>

            IslandScreen(

              island: world,

            ),

      ),

    );


  }








  Widget islandButton(

      String id,

      double x,

      double y,

      ){



    final world =
    PuzzleData.getById(id);




    if(world == null){

      return const SizedBox();

    }





    final locked =
        totalStars < world.requiredStars;







    return Positioned(


      left: x - 40,


      top: y - 40,


      width: 80,


      height: 80,



      child: GestureDetector(



        onTap: (){


          openWorld(world);


        },



        child: Stack(

          alignment:
          Alignment.center,



          children: [




            // مكان الجزيرة

            Container(

              decoration:
              BoxDecoration(


                color:
                Colors.white24,


                shape:
                BoxShape.circle,



                border:
                Border.all(

                  color:
                  Colors.white54,

                  width:2,

                ),


              ),

            ),






            if(locked)


              Container(

                decoration:
                const BoxDecoration(


                  color:
                  Colors.black45,


                  shape:
                  BoxShape.circle,


                ),


                child:
                const Icon(


                  Icons.lock,


                  color:
                  Colors.white,


                  size:35,


                ),


              ),



          ],


        ),


      ),


    );


  }









  @override
  Widget build(BuildContext context){



    if(loading){


      return const Scaffold(


        body:
        Center(

          child:
          CircularProgressIndicator(),

        ),

      );


    }







    return Scaffold(



      body:
      Stack(



        children: [





          Positioned.fill(



            child: Image.asset(



              "assets/images/world/world_map.jpg",



              fit:
              BoxFit.cover,




              errorBuilder:
                  (context,error,stackTrace){



                return Container(


                  color:
                  Colors.lightBlue,


                );


              },



            ),



          ),







          SafeArea(



            child: Column(



              children: [






                Padding(



                  padding:
                  const EdgeInsets.symmetric(

                    horizontal:15,

                  ),



                  child: Row(



                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,



                    children: [





                      IconButton(



                        onPressed: (){


                          // الإعدادات لاحقاً


                        },



                        icon:
                        const Icon(



                          Icons.settings,



                          color:
                          Colors.white,



                          size:32,


                        ),



                      ),






                      const Text(



                        "🌍 Puzzle World",



                        style:
                        TextStyle(



                          color:
                          Colors.white,



                          fontSize:30,



                          fontWeight:
                          FontWeight.bold,



                          shadows:[



                            Shadow(



                              color:
                              Colors.black45,



                              blurRadius:
                              8,



                            ),


                          ],



                        ),



                      ),







                      Container(



                        padding:
                        const EdgeInsets.symmetric(



                          horizontal:12,



                          vertical:8,



                        ),



                        decoration:
                        BoxDecoration(



                          color:
                          Colors.white24,



                          borderRadius:
                          BorderRadius.circular(20),



                        ),




                        child:
                        Text(



                          "⭐ $totalStars",



                          style:
                          const TextStyle(



                            color:
                            Colors.white,



                            fontSize:20,



                            fontWeight:
                            FontWeight.bold,



                          ),



                        ),



                      ),





                    ],



                  ),



                ),







                Expanded(



                  child:
                  LayoutBuilder(



                    builder:
                        (context,constraints){



                      final width =
                          constraints.maxWidth;



                      final height =
                          constraints.maxHeight;






                      return Stack(



                        children: [





                          // الحيوانات

                          islandButton(

                            "animals",

                            width * 0.256,

                            height * 0.20,

                          ),






                          // السيارات

                          islandButton(

                            "cars",

                            width * 0.212,

                            height * 0.552,

                          ),






                          // الفضاء

                          islandButton(

                            "space",

                            width * 0.732,

                            height * 0.252,

                          ),






                          // المعالم

                          islandButton(

                            "landmarks",

                            width * 0.784,

                            height * 0.568,

                          ),






                          // الطبيعة

                          islandButton(

                            "nature",

                            width * 0.380,

                            height * 0.793,

                          ),





                        ],



                      );



                    },


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