import 'package:flutter/material.dart';

import '../data/puzzle_data.dart';
import '../data/puzzle_level_data.dart';
import '../managers/puzzle_progress_manager.dart';
import '../models/puzzle_model.dart';

import 'puzzle_level_screen.dart';



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
  void initState() {

    super.initState();

    loadStars();

  }



  Future<void> loadStars() async {

    final stars =
        await PuzzleProgressManager.getTotalStars();


    if (mounted) {

      setState(() {

        totalStars = stars;

        loading = false;

      });

    }

  }




  void openWorld(
      PuzzleModel world,
      ) {


    if (totalStars < world.requiredStars) {

      ScaffoldMessenger.of(context)
          .showSnackBar(

        SnackBar(

          content: Text(
            "تحتاج ${world.requiredStars} نجمة لفتح ${world.title}",
          ),

        ),

      );

      return;

    }



    final levels =
        PuzzleLevelData.getLevels(
          world.id,
        );


    if (levels.isEmpty) {

      return;

    }



    Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) => PuzzleLevelScreen(
          puzzle: world,
        ),

      ),

    );

  }





  Widget islandButton(
      String id,
      double x,
      double y,
      ) {


    final world =
    PuzzleData.getById(id);


    if (world == null) {

      return const SizedBox();

    }



    final locked =
        totalStars < world.requiredStars;



    return Positioned(

      left: x - 55,

      top: y - 55,

      width: 110,

      height: 110,

      child: GestureDetector(

        onTap: () {

          openWorld(world);

        },


        child: Stack(

          alignment: Alignment.center,

          children: [


            if (locked)

              Container(

                decoration: BoxDecoration(

                  color: Colors.black38,

                  borderRadius:
                  BorderRadius.circular(60),

                ),

                child: const Icon(

                  Icons.lock,

                  color: Colors.white,

                  size: 45,

                ),

              ),


          ],

        ),

      ),

    );

  }






  @override
  Widget build(BuildContext context) {


    if (loading) {

      return const Scaffold(

        body: Center(

          child: CircularProgressIndicator(),

        ),

      );

    }



    return Scaffold(

      body: Stack(

        children: [



          Positioned.fill(

            child: Image.asset(

              "assets/images/world/world_map.jpg",

              fit: BoxFit.cover,

            ),

          ),




          SafeArea(

            child: Column(

              children: [


                const SizedBox(height:20),



                Row(

                  mainAxisAlignment:
                  MainAxisAlignment.center,

                  children: [


                    const Text(

                      "🌍 Puzzle World",

                      style: TextStyle(

                        color: Colors.white,

                        fontSize: 32,

                        fontWeight:
                        FontWeight.bold,

                        shadows: [

                          Shadow(

                            color: Colors.black45,

                            blurRadius: 8,

                          ),

                        ],

                      ),

                    ),



                    const SizedBox(width:20),



                    Container(

                      padding:
                      const EdgeInsets.symmetric(

                        horizontal:15,

                        vertical:8,

                      ),

                      decoration: BoxDecoration(

                        color: Colors.black26,

                        borderRadius:
                        BorderRadius.circular(20),

                      ),

                      child: Text(

                        "⭐ $totalStars",

                        style: const TextStyle(

                          color: Colors.white,

                          fontSize:20,

                          fontWeight:
                          FontWeight.bold,

                        ),

                      ),

                    ),

                  ],

                ),



                Expanded(

                  child: LayoutBuilder(

                    builder:
                        (context,constraints) {


                      return Stack(

                        children: [



                          // جزيرة الحيوانات
                          islandButton(
                            "animals",
                            256,
                            200,
                          ),



                          // جزيرة السيارات
                          islandButton(
                            "cars",
                            212,
                            552,
                          ),



                          // جزيرة الفضاء
                          islandButton(
                            "space",
                            732,
                            252,
                          ),



                          // جزيرة المعالم
                          islandButton(
                            "landmarks",
                            784,
                            568,
                          ),



                          // جزيرة الطبيعة
                          islandButton(
                            "nature",
                            380,
                            793,
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