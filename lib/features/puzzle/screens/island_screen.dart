import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/island_background_data.dart';
import '../data/puzzle_level_data.dart';

import '../models/puzzle_model.dart';
import '../models/puzzle_level_model.dart';
import '../widgets/wallet_icon_widget.dart';

import 'puzzle_game_screen.dart';

class IslandScreen extends StatefulWidget {
  final PuzzleModel island;

  const IslandScreen({
    super.key,
    required this.island,
  });

  @override
  State<IslandScreen> createState() => _IslandScreenState();
}

class _IslandScreenState extends State<IslandScreen>
    with TickerProviderStateMixin {
  static const double worldWidth = 1080;
  static const double worldHeight = 1920;

  static const double islandAreaTop = worldHeight * 0.00;
  static const double islandAreaHeight = worldHeight * 0.66;

  static const double islandBackgroundOpacity = 0.55;
  static const double islandImageOpacity = 0.65;

  late final List<PuzzleLevelModel> levels;

  late final AnimationController worldController;
  late final Animation<double> worldScale;
  late final Animation<double> worldTranslateY;

  final List<Offset> levelPositions = const [
    Offset(0.50, 0.91), // 1
    Offset(0.31, 0.83), // 2
    Offset(0.64, 0.73), // 3
    Offset(0.36, 0.64), // 4
    Offset(0.67, 0.55), // 5
    Offset(0.33, 0.46), // 6
    Offset(0.60, 0.37), // 7
    Offset(0.35, 0.28), // 8
    Offset(0.56, 0.19), // 9
    Offset(0.50, 0.10), // 10
  ];

  @override
  void initState() {
    super.initState();

    levels = PuzzleLevelData.getLevels(
      widget.island.id,
    );

    worldController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);

    worldScale = Tween<double>(
      begin: 1.00,
      end: 1.05,
    ).animate(
      CurvedAnimation(
        parent: worldController,
        curve: Curves.easeInOut,
      ),
    );

    worldTranslateY = Tween<double>(
      begin: -15,
      end: 15,
    ).animate(
      CurvedAnimation(
        parent: worldController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    worldController.dispose();
    super.dispose();
  }

  void openLevel(
    PuzzleLevelModel level,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PuzzleGameScreen(
          level: level,
          island: widget.island,
        ),
      ),
    );
  }

  Widget levelButton(
    PuzzleLevelModel level, {
    required double size,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        openLevel(level);
      },
      child: SizedBox(
        width: size,
        height: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35),
                blurRadius: size * 0.10,
                offset: Offset(0, size * 0.05),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                "assets/images/ui/level_piece.png",
                fit: BoxFit.contain,
              ),
              Text(
                "${level.levelNumber}",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size * 0.34,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                  shadows: const [
                    Shadow(
                      color: Colors.black,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff020b24),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double screenWidth = constraints.maxWidth;
            final double screenHeight = constraints.maxHeight;

            if (screenWidth <= 0 || screenHeight <= 0) {
              return const SizedBox.shrink();
            }

            final double scale = math.max(
              screenWidth / worldWidth,
              screenHeight / worldHeight,
            );

            final double scaledWidth = worldWidth * scale;
            final double scaledHeight = worldHeight * scale;

            final double dx = (screenWidth - scaledWidth) / 2;
            final double dy = (screenHeight - scaledHeight) / 2;

            final double levelButtonSize =
                (80 / scale).clamp(150.0, 260.0);

            return Stack(
              children: [
                ClipRect(
                  child: Stack(
                    children: [
                      Positioned(
                        left: dx,
                        top: dy,
                        child: Transform.scale(
                          scale: scale,
                          alignment: Alignment.topLeft,
                          child: SizedBox(
                            width: worldWidth,
                            height: worldHeight,
                            child: AnimatedBuilder(
                              animation: worldController,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(0, worldTranslateY.value),
                                  child: Transform.scale(
                                    scale: worldScale.value,
                                    alignment: Alignment.center,
                                    child: child,
                                  ),
                                );
                              },
                              child: SizedBox(
                                width: worldWidth,
                                height: worldHeight,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Positioned.fill(
                                      child: Opacity(
                                        opacity: islandBackgroundOpacity,
                                        child: Image.asset(
                                          IslandBackgroundData.getBackground(
                                            widget.island.id,
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 0,
                                      top: islandAreaTop,
                                      width: worldWidth,
                                      height: islandAreaHeight,
                                      child: Opacity(
                                        opacity: islandImageOpacity,
                                        child: Image.asset(
                                          widget.island.image,
                                          fit: BoxFit.contain,
                                          alignment: Alignment.center,
                                        ),
                                      ),
                                    ),
                                    ...List.generate(
                                      levels.length,
                                      (index) {
                                        if (index >= levelPositions.length) {
                                          return const SizedBox.shrink();
                                        }

                                        final pos = levelPositions[index];

                                        return Positioned(
                                          left: (worldWidth * pos.dx) -
                                              (levelButtonSize / 2),
                                          top: (worldHeight * pos.dy) -
                                              (levelButtonSize / 2),
                                          child: levelButton(
                                            levels[index],
                                            size: levelButtonSize,
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // زر الرجوع في الأعلى
                Positioned(
                  top: 20,
                  left: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF8A2BE2),
                          Color(0xFF4B0082),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF9400D3).withOpacity(0.8),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.transparent,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 32,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                ),

                // أيقونة المحفظة في أسفل يسار الشاشة مع الوهج المشع
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.85),
                          blurRadius: 16,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Transform.scale(
                      scale: 1.15,
                      child: const WalletIconWidget(),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
