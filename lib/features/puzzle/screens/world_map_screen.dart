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
    final size = MediaQuery.of(context).size;

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
            left: size.width * 0.23,
            top: size.height * 0.29,
            width: size.width * 0.22,
            islandId: "animals",
          ),

          islandButton(
            left: size.width * 0.43,
            top: size.height * 0.08,
            width: size.width * 0.18,
            islandId: "space",
          ),

          islandButton(
            left: size.width * 0.62,
            top: size.height * 0.30,
            width: size.width * 0.22,
            islandId: "landmarks",
          ),

          islandButton(
            left: size.width * 0.23,
            top: size.height * 0.56,
            width: size.width * 0.22,
            islandId: "cars",
          ),

          islandButton(
            left: size.width * 0.62,
            top: size.height * 0.56,
            width: size.width * 0.22,
            islandId: "nature",
          ),
        ],
      ),
    );
  }

  Widget islandButton({
    required double left,
    required double top,
    required double width,
    required String islandId,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          final island = islands.firstWhere(
            (item) => item.id == islandId,
          );

          openIsland(island);
        },
        child: Container(
          width: width,
          height: width,
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