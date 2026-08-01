import 'package:flutter/material.dart';

import '../data/puzzle_data.dart';
import '../models/puzzle_model.dart';
import 'island_screen.dart';

class _RelativeRect {
  final String id;
  final double left;
  final double top;
  final double width;
  final double height;

  const _RelativeRect({
    required this.id,
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });
}

class _RelativeCloud {
  final String image;
  final double top;
  final double size;
  final double opacity;
  final Duration duration;

  const _RelativeCloud({
    required this.image,
    required this.top,
    required this.size,
    required this.opacity,
    required this.duration,
  });
}

class WorldMapScreen extends StatefulWidget {
  const WorldMapScreen({
    super.key,
  });

  @override
  State<WorldMapScreen> createState() =>
      _WorldMapScreenState();
}

class _WorldMapScreenState
    extends State<WorldMapScreen>
    with TickerProviderStateMixin {

  static const String mapImage =
      "assets/images/world/world_map.jpg";

  static const double worldWidth = 896;
  static const double worldHeight = 1350;

  late final List<PuzzleModel> islands;

  late final AnimationController worldController;
  late final Animation<double> worldScale;

  late final List<AnimationController> cloudControllers;

  static final List<_RelativeRect> _islandRects = [

    _RelativeRect(
      id: "space",
      left: 260 / worldWidth,
      top: 20 / worldHeight,
      width: 370 / worldWidth,
      height: 450 / worldHeight,
    ),

    _RelativeRect(
      id: "landmarks",
      left: 120 / worldWidth,
      top: 330 / worldHeight,
      width: 280 / worldWidth,
      height: 360 / worldHeight,
    ),

    _RelativeRect(
      id: "cars",
      left: 500 / worldWidth,
      top: 330 / worldHeight,
      width: 280 / worldWidth,
      height: 360 / worldHeight,
    ),

    _RelativeRect(
      id: "nature",
      left: 275 / worldWidth,
      top: 590 / worldHeight,
      width: 320 / worldWidth,
      height: 395 / worldHeight,
    ),

    _RelativeRect(
      id: "animals",
      left: 285 / worldWidth,
      top: 980 / worldHeight,
      width: 320 / worldWidth,
      height: 390 / worldHeight,
    ),

  ];

  static final List<_RelativeCloud> _clouds = [

    _RelativeCloud(
      image: "assets/images/background/cloud_01.png",
      top: 80 / worldHeight,
      size: 280 / worldWidth,
      opacity: 0.22,
      duration: Duration(seconds: 55),
    ),

    _RelativeCloud(
      image: "assets/images/background/cloud_02.png",
      top: 200 / worldHeight,
      size: 220 / worldWidth,
      opacity: 0.22,
      duration: Duration(seconds: 70),
    ),

    _RelativeCloud(
      image: "assets/images/background/cloud_03.png",
      top: 40 / worldHeight,
      size: 170 / worldWidth,
      opacity: 0.22,
      duration: Duration(seconds: 90),
    ),

    _RelativeCloud(
      image: "assets/images/background/cloud_04.png",
      top: 300 / worldHeight,
      size: 240 / worldWidth,
      opacity: 0.22,
      duration: Duration(seconds: 65),
    ),

  ];

  @override
  void initState() {
    super.initState();

    islands = PuzzleData.puzzles;

    worldController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat(reverse: true);


    worldScale = Tween<double>(
      begin: 1.02,
      end: 1.04,
    ).animate(
      CurvedAnimation(
        parent: worldController,
        curve: Curves.easeInOut,
      ),
    );


    cloudControllers = _clouds
        .map(
          (cloud) => AnimationController(
            vsync: this,
            duration: cloud.duration,
          )..repeat(),
        )
        .toList();
  }


  @override
  void dispose() {

    worldController.dispose();

    for (final controller in cloudControllers) {
      controller.dispose();
    }

    super.dispose();
  }


  PuzzleModel getIsland(String id) {
    return islands.firstWhere(
      (item) => item.id == id,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xff08182b),

      body: SizedBox.expand(

        child: ClipRect(

          child: OverflowBox(

            alignment: Alignment.center,

            maxWidth: double.infinity,

            maxHeight: double.infinity,

            child: AspectRatio(

              aspectRatio: worldWidth / worldHeight,

              child: AnimatedBuilder(

                animation: worldController,

                builder: (context, child) {

                  return Transform.scale(

                    scale: worldScale.value,

                    alignment: Alignment.center,

                    child: child,

                  );

                },

                child: SizedBox(

                  width: worldWidth,

                  height: worldHeight,

                  child: Stack(

                    clipBehavior: Clip.none,

                    children: [

                      Positioned.fill(

                        child: Image.asset(

                          mapImage,

                          fit: BoxFit.cover,

                        ),

                      ),


                      for (int i = 0; i < _clouds.length; i++)

                        cloudWidget(

                          cloud: _clouds[i],

                          controller: cloudControllers[i],

                        ),


                      for (final rect in _islandRects)

                        islandImage(

                          rect: rect,

                        ),

                    ],

                  ),

                ),

              ),

            ),

          ),

        ),

      ),

    );

  }

  Widget cloudWidget({

    required _RelativeCloud cloud,

    required AnimationController controller,

  }) {

    final double top =
        cloud.top * worldHeight;

    final double size =
        cloud.size * worldWidth;


    return AnimatedBuilder(

      animation: controller,

      builder: (context, child) {

        return Positioned(

          left: (worldWidth + 100) -
              (controller.value *
                  (worldWidth + 400)),

          top: top,

          child: Opacity(

            opacity: cloud.opacity,

            child: Transform.rotate(

              angle: controller.value * 0.15,

              child: child,

            ),

          ),

        );

      },


      child: Image.asset(

        cloud.image,

        width: size,

      ),

    );

  }



  Widget islandImage({

    required _RelativeRect rect,

  }) {

    final island = getIsland(rect.id);


    final double left =
        rect.left * worldWidth;

    final double top =
        rect.top * worldHeight;

    final double width =
        rect.width * worldWidth;

    final double height =
        rect.height * worldHeight;


    return Positioned(

      left: left,

      top: top,

      width: width,

      height: height,

      child: Transform.scale(

        scale: 1.08,

        child: GestureDetector(

          onTap: () => openIsland(island),

          child: Image.asset(

            island.image,

            fit: BoxFit.contain,

          ),

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