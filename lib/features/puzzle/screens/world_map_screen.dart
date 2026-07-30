import 'package:flutter/material.dart';

import '../data/puzzle_data.dart';
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



  static const String mapImage =
      "assets/images/world/world_map.png";



  // أبعاد صورة الخريطة الأصلية
  static const double mapWidth = 1024;

  static const double mapHeight = 1536;



  late final List<PuzzleModel> islands;




  @override
  void initState() {

    super.initState();

    islands = PuzzleData.puzzles;

  }






  @override
  Widget build(BuildContext context) {


    return Scaffold(


      backgroundColor: Colors.black,



      body: SafeArea(


        child: Center(


          child: FittedBox(

            fit: BoxFit.contain,


            child: SizedBox(


              width: mapWidth,

              height: mapHeight,



              child: Stack(


                clipBehavior: Clip.none,


                children: [



                  //=========================================
                  // خلفية العالم
                  //=========================================

                  Positioned.fill(

                    child: Image.asset(

                      mapImage,

                      fit: BoxFit.cover,

                    ),

                  ),





                  //=========================================
                  // جزيرة الفضاء
                  //=========================================

                  islandButton(

                    rect: const Rect.fromLTWH(

                      274,

                      120,

                      475,

                      470,

                    ),

                    islandId: "space",

                  ),






                  //=========================================
                  // جزيرة الحيوانات
                  //=========================================

                  islandButton(

                    rect: const Rect.fromLTWH(

                      70,

                      510,

                      370,

                      410,

                    ),

                    islandId: "animals",

                  ),






                  //=========================================
                  // جزيرة المعالم
                  //=========================================

                  islandButton(

                    rect: const Rect.fromLTWH(

                      520,

                      515,

                      395,

                      425,

                    ),

                    islandId: "landmarks",

                  ),






                  //=========================================
                  // جزيرة السيارات
                  //=========================================

                  islandButton(

                    rect: const Rect.fromLTWH(

                      80,

                      955,

                      370,

                      405,

                    ),

                    islandId: "cars",

                  ),






                  //=========================================
                  // جزيرة الطبيعة
                  //=========================================

                  islandButton(

                    rect: const Rect.fromLTWH(

                      560,

                      965,

                      380,

                      430,

                    ),

                    islandId: "nature",

                  ),


                ],


              ),


            ),


          ),


        ),


      ),


    );

  }







  Widget islandButton({

    required Rect rect,

    required String islandId,

  }) {



    return Positioned.fromRect(


      rect: rect,


      child: GestureDetector(


        behavior: HitTestBehavior.translucent,



        onTap: () {



          final island =
              islands.firstWhere(

                (item) =>
                    item.id == islandId,

              );



          openIsland(island);


        },



        child: Container(

          color: Colors.transparent,

        ),



      ),


    );


  }







  void openIsland(
      PuzzleModel island,
      ) {


    Navigator.push(


      context,


      MaterialPageRoute(


        builder: (_) => IslandScreen(

          island: island,

        ),


      ),


    );


  }


}