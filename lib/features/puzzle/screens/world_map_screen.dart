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

backgroundColor: const Color(0xff08182b),

      body: LayoutBuilder(

        builder: (context, constraints) {

          final scaleX =
              constraints.maxWidth / mapWidth;

          final scaleY =
              constraints.maxHeight / mapHeight;

          final scale =
              scaleX > scaleY ? scaleX : scaleY;


          final dx =
              (constraints.maxWidth - (mapWidth * scale)) / 2;


          final dy =
              (constraints.maxHeight - (mapHeight * scale)) / 2;



          return Stack(

            children: [

              Positioned(

                left: dx,

                top: dy,


                child: Transform.scale(

                  scale: scale,

                  alignment: Alignment.topLeft,


                  child: SizedBox(

                    width: mapWidth,

                    height: mapHeight,


                    child: Stack(

                      children: [

                        Positioned.fill(

                          child: Image.asset(

                            mapImage,

                            fit: BoxFit.fill,

                          ),

                        ),


                        islandButton(
                          rect: const Rect.fromLTWH(
                            274,
                            120,
                            475,
                            470,
                          ),
                          islandId: "space",
                        ),


                        islandButton(
                          rect: const Rect.fromLTWH(
                            70,
                            510,
                            370,
                            410,
                          ),
                          islandId: "animals",
                        ),


                        islandButton(
                          rect: const Rect.fromLTWH(
                            520,
                            515,
                            395,
                            425,
                          ),
                          islandId: "landmarks",
                        ),


                        islandButton(
                          rect: const Rect.fromLTWH(
                            80,
                            955,
                            370,
                            405,
                          ),
                          islandId: "cars",
                        ),


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

            ],

          );

        },

      ),

    );

  }






  Widget islandButton({

    required Rect rect,

    required String islandId,

  }) {


    return Positioned(

      left: rect.left,

      top: rect.top,

      width: rect.width,

      height: rect.height,


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