import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/puzzle_data.dart';
import '../data/island_map_data.dart';

import '../models/puzzle_model.dart';
import '../models/island_map_model.dart';



import 'island_screen.dart';



class WorldMapScreen extends StatefulWidget {

  const WorldMapScreen({
    super.key,
  });

  @override
  State<WorldMapScreen> createState() =>
      _WorldMapScreenState();
}



class _WorldMapScreenState extends State<WorldMapScreen>
    with TickerProviderStateMixin {

  //==================================================
  // ASSETS / DESIGN SIZE
  //==================================================

  static const String mapImage =
      "assets/images/world/world_map.png";

  static const double designWidth = 1080;
  static const double designHeight = 1920;

  //==================================================
  // DATA
  //==================================================

  late final List<PuzzleModel> islands;

  final Map<String, IslandMapModel> islandPositions =
      IslandMapData.positions;

  String? selectedIsland;

  

  //==================================================
  // MAP ANIMATION
  //==================================================

  late final AnimationController mapController;
  late final Animation<double> mapScaleAnimation;
  late final Animation<Offset> mapMoveAnimation;

  //==================================================
  // STARS
  //==================================================

  late final AnimationController starsController;
  late final Animation<double> starsAnimation;

  //==================================================
  // SEA
  //==================================================

  late final AnimationController seaController;
  late final Animation<double> seaAnimation;

  //==================================================
  // ISLAND FLOAT
  //==================================================

  final Map<String, AnimationController> islandControllers = {};
  final Map<String, Animation<double>> islandAnimations = {};

  @override
  void initState() {
    super.initState();

    islands = PuzzleData.puzzles;

    //==================================================
    // MAP ANIMATION
    //==================================================

    mapController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 18,
      ),
    )..repeat(
        reverse: true,
      );

    mapScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(
      CurvedAnimation(
        parent: mapController,
        curve: Curves.easeInOut,
      ),
    );

    mapMoveAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(
        0.02,
        -0.02,
      ),
    ).animate(
      CurvedAnimation(
        parent: mapController,
        curve: Curves.easeInOut,
      ),
    );

    //==================================================
    // STARS ANIMATION
    //==================================================

    starsController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 8,
      ),
    )..repeat();

    starsAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: starsController,
        curve: Curves.linear,
      ),
    );

    //==================================================
    // SEA ANIMATION
    //==================================================

    seaController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 10,
      ),
    )..repeat(
        reverse: true,
      );

    seaAnimation = Tween<double>(
      begin: 0.05,
      end: 0.15,
    ).animate(
      CurvedAnimation(
        parent: seaController,
        curve: Curves.easeInOut,
      ),
    );

    //==================================================
    // ISLAND FLOAT ANIMATION
    //==================================================

    for (final island in islands) {
      final controller = AnimationController(
        vsync: this,
        duration: Duration(
          seconds: 3 + math.Random().nextInt(4),
        ),
      )..repeat(
          reverse: true,
        );

      final animation = Tween<double>(
        begin: -8,
        end: 8,
      ).animate(
        CurvedAnimation(
          parent: controller,
          curve: Curves.easeInOut,
        ),
      );

      islandControllers[island.id] = controller;
      islandAnimations[island.id] = animation;
    }
  }

  //==================================================
  // BUILD
  //==================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: SafeArea(
        top: false,
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final screenHeight = constraints.maxHeight;

            final scaleX = screenWidth / designWidth;
            final scaleY = screenHeight / designHeight;
            final islandScale = scaleX < scaleY ? scaleX : scaleY;

            return Stack(
              children: [

                //==================================================
                // BACKGROUND MAP
                //==================================================

                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: mapController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: mapMoveAnimation.value * 80,
                        child: Transform.scale(
                          scale: mapScaleAnimation.value,
                          child: Image.asset(
                            mapImage,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                //==================================================
                // STAR FIELD
                //==================================================

                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: starsController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: StarFieldPainter(
                            starsAnimation.value,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                //==================================================
                // SEA EFFECT
                //==================================================

                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: seaController,
                      builder: (context, child) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(
                                  seaAnimation.value,
                                ),
                                Colors.transparent,
                                Colors.blue.withOpacity(
                                  seaAnimation.value,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                //==================================================
                // ISLANDS
                //==================================================

                Center(
                  child: SizedBox(
                    width: designWidth,
                    height: designHeight,
                    child: Stack(
                      children: [
                        ...islands.map((island) {
                          final mapData = islandPositions[island.id];

                          if (mapData == null) {
                            return const SizedBox();
                          }

                          final animation = islandAnimations[island.id]!;

                          return AnimatedBuilder(
                            animation: animation,
                            builder: (context, child) {
                              final left = designWidth * mapData.x;
                              final top = designHeight * mapData.y;

                              final size = designWidth * mapData.size;

                              return Positioned(
                                left: left,
                                top: top + animation.value,
                                child: GestureDetector(
                                  onTapDown: (_) {
                                    setState(() {
                                      selectedIsland = island.id;
                                    });
                                  },
                                  onTapCancel: () {
                                    setState(() {
                                      selectedIsland = null;
                                    });
                                  },
                                  onTap: () {
                                    setState(() {
                                      selectedIsland = null;
                                    });

                                    openIsland(island);
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(
                                      milliseconds: 250,
                                    ),
                                    transform:
                                        selectedIsland == island.id
                                            ? (Matrix4.identity()
                                              ..scale(1.08))
                                            : Matrix4.identity(),
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Image.asset(
                                          island.image,
                                          width: size,
                                          height: size,
                                          fit: BoxFit.contain,
                                        ),
                                        if (selectedIsland == island.id)
                                          Container(
                                            width: size,
                                            height: size,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.yellow
                                                      .withOpacity(0.75),
                                                  blurRadius: 35,
                                                  spreadRadius: 8,
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                ),

//==================================================
// TOP BUTTONS
//==================================================

SafeArea(
  child: Padding(
    padding: EdgeInsets.symmetric(
      horizontal: MediaQuery.of(context).size.width * 0.04,
      vertical: MediaQuery.of(context).size.height * 0.015,
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        // الإعدادات يسار
        Container(
          width: MediaQuery.of(context).size.width * 0.12,
          height: MediaQuery.of(context).size.width * 0.12,
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(18),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.settings_rounded,
              color: Colors.white,
            ),
            onPressed: () {
              // فتح الإعدادات
            },
          ),
        ),


        // المحفظة يمين
        Container(
          width: MediaQuery.of(context).size.width * 0.12,
          height: MediaQuery.of(context).size.width * 0.12,
          decoration: BoxDecoration(
            color: Colors.amber,
            borderRadius: BorderRadius.circular(18),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/wallet',
              );
            },
          ),
        ),

      ],
    ),
  ),
) 

          ],
            );
          },
        ),
      ),
    );
  }

  //==================================================
  // OPEN ISLAND
  //==================================================

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

  //==================================================
  // DISPOSE
  //==================================================

  @override
  void dispose() {
    mapController.dispose();
    starsController.dispose();
    seaController.dispose();

    for (final controller in islandControllers.values) {
      controller.dispose();
    }

    super.dispose();
  }
}



//==================================================
// STAR FIELD PAINTER
//==================================================

class StarFieldPainter extends CustomPainter {
  final double animation;

  const StarFieldPainter(
    this.animation,
  );

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint();
    final random = math.Random(10);

    for (int i = 0; i < 80; i++) {
      final x = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;

      final y = (baseY +
              animation * 40 * (i % 3 + 1)) %
          size.height;

      final radius = random.nextDouble() * 1.8 + 0.5;

      paint.color = Colors.white.withOpacity(
        0.25 +
            (math.sin(
                      animation * math.pi * 2 + i,
                    ) +
                    1) /
                4,
      );

      canvas.drawCircle(
        Offset(
          x,
          y,
        ),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant StarFieldPainter oldDelegate,
  ) {
    return oldDelegate.animation != animation;
  }
}