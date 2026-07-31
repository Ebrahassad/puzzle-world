import 'package:flutter/material.dart';

import '../data/puzzle_data.dart';
import '../models/puzzle_model.dart';

import 'island_screen.dart';

class WorldMapScreen extends StatefulWidget {
  const WorldMapScreen({super.key});

  @override
  State<WorldMapScreen> createState() => _WorldMapScreenState();
}

class _WorldMapScreenState extends State<WorldMapScreen>
    with TickerProviderStateMixin {
  static const String mapImage = "assets/images/world/world_map.png";

  // حجم اللوحة الداخلية للعالم
  static const double worldWidth = 896;
  static const double worldHeight = 1350;

  late final List<PuzzleModel> islands;

  late final AnimationController worldController;
  late final Animation<double> worldScale;

  late final AnimationController islandController;
  late final Animation<double> islandFloat;

  late final AnimationController cloudController;
  late final Animation<double> cloudMove;

  @override
  void initState() {
    super.initState();

    islands = PuzzleData.puzzles;

    worldController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat(reverse: true);

    worldScale = Tween<double>(
      begin: 1.0,
      end: 1.012,
    ).animate(
      CurvedAnimation(
        parent: worldController,
        curve: Curves.easeInOut,
      ),
    );

    islandController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    islandFloat = Tween<double>(
      begin: -4,
      end: 4,
    ).animate(
      CurvedAnimation(
        parent: islandController,
        curve: Curves.easeInOut,
      ),
    );

    cloudController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 45),
    )..repeat();

    cloudMove = Tween<double>(
      begin: 1100,
      end: -500,
    ).animate(
      CurvedAnimation(
        parent: cloudController,
        curve: Curves.linear,
      ),
    );
  }

  @override
  void dispose() {
    worldController.dispose();
    islandController.dispose();
    cloudController.dispose();
    super.dispose();
  }

  PuzzleModel getIsland(String id) {
    return islands.firstWhere((item) => item.id == id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff08182b),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox.expand(
            child: ClipRect(
              child: FittedBox(
                fit: BoxFit.cover,
                alignment: Alignment.center,
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
                            fit: BoxFit.fill,
                          ),
                        ),

                        Positioned.fill(
                          child: IgnorePointer(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.white.withOpacity(0.05),
                                    Colors.blue.withOpacity(0.12),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        AnimatedBuilder(
                          animation: cloudController,
                          builder: (context, child) {
                            return Positioned(
                              left: cloudMove.value,
                              top: 90,
                              child: child!,
                            );
                          },
                          child: Opacity(
                            opacity: 0.18,
                            child: Image.asset(
                              "assets/images/background/clouds.png",
                              width: 320,
                            ),
                          ),
                        ),

                        AnimatedBuilder(
                          animation: cloudController,
                          builder: (context, child) {
                            return Positioned(
                              left: cloudMove.value * 0.65,
                              top: 330,
                              child: child!,
                            );
                          },
                          child: Opacity(
                            opacity: 0.12,
                            child: Image.asset(
                              "assets/images/background/clouds.png",
                              width: 250,
                            ),
                          ),
                        ),

                        islandImage(
                          id: "space",
                          left: 285,
                          top: 35,
                          width: 320,
                          height: 390,
                        ),
                        islandImage(
                          id: "landmarks",
                          left: 35,
                          top: 325,
                          width: 305,
                          height: 390,
                        ),
                        islandImage(
                          id: "cars",
                          left: 560,
                          top: 325,
                          width: 305,
                          height: 390,
                        ),
                        islandImage(
                          id: "nature",
                          left: 275,
                          top: 660,
                          width: 320,
                          height: 395,
                        ),
                        islandImage(
                          id: "animals",
                          left: 285,
                          top: 980,
                          width: 320,
                          height: 390,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget islandImage({
    required String id,
    required double left,
    required double top,
    required double width,
    required double height,
  }) {
    final island = getIsland(id);

    return AnimatedBuilder(
      animation: islandController,
      builder: (context, child) {
        return Positioned(
          left: left,
          top: top + islandFloat.value,
          width: width,
          height: height,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => openIsland(island),
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: width * 0.88,
                  height: height * 0.60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.14),
                        blurRadius: 36,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
                Center(
                  child: SizedBox(
                    width: width,
                    height: height,
                    child: Image.asset(
                      island.image,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void openIsland(PuzzleModel island) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => IslandScreen(island: island),
      ),
    );
  }
}