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



class _WorldMapScreenState extends State<WorldMapScreen> {



  static const String mapImage =
      "assets/images/world/world_map.png";



  late final List<PuzzleModel> islands;



  @override
  void initState() {
    super.initState();

    islands = PuzzleData.puzzles;
  }
  @override
  Widget build(BuildContext context) {
    

    return Scaffold(
      body: Stack(
        children: [

          //==================================================
          // صورة العالم الثابتة
          //==================================================

          Positioned.fill(
            child: Image.asset(
              mapImage,
             fit: BoxFit.contain,
            ),
          ),

          //==================================================
          // مناطق الضغط على الجزر
          //==================================================

          islandButton(
  x:466,
  y:328,
  size:90,
  islandId:"space",
),

islandButton(
  x:242,
  y:760,
  size:110,
  islandId:"animals",
),

islandButton(
  x:750,
  y:726,
  size:110,
  islandId:"landmarks",
),

islandButton(
  x:236,
  y:1212,
  size:110,
  islandId:"cars",
),

islandButton(
  x:774,
  y:1228,
  size:110,
  islandId:"nature",
),
        ],
      ),
    );
  }

  Widget islandButton({
  required double x,
  required double y,
  required double size,
  required String islandId,
}) {

  final screenSize = MediaQuery.of(context).size;


  // حساب حجم الصورة مع BoxFit.contain

  final imageRatio = 1024 / 1536;
  final screenRatio = screenSize.width / screenSize.height;


  double imageWidth;
  double imageHeight;
  double offsetX = 0;
  double offsetY = 0;


  if (screenRatio > imageRatio) {

    imageHeight = screenSize.height;
    imageWidth = imageHeight * imageRatio;

    offsetX = (screenSize.width - imageWidth) / 2;

  } else {

    imageWidth = screenSize.width;
    imageHeight = imageWidth / imageRatio;

    offsetY = (screenSize.height - imageHeight) / 2;

  }


  final scaleX = imageWidth / 1024;
  final scaleY = imageHeight / 1536;


  return Positioned(

    left: offsetX + (x * scaleX) - (size / 2),

    top: offsetY + (y * scaleY) - (size / 2),


    child: GestureDetector(

      behavior: HitTestBehavior.translucent,

      onTap: () {

        final island = islands.firstWhere(
          (item) => item.id == islandId,
        );

        openIsland(island);

      },

      child: Container(

        width: size,

        height: size,

        color: Colors.transparent,

      ),

    ),

  );
}

  void openIsland(PuzzleModel island) {
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