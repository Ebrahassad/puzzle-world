import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'private_island_screen.dart';
import '../data/puzzle_data.dart';
import '../models/puzzle_model.dart';
import '../widgets/wallet_icon_widget.dart';
import 'island_screen.dart';
// import 'puzzle_game_screen.dart'; // <--- قم بإلغاء التعليق واستيراد شاشة اللعب الخاصة بك إذا لزم الأمر

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
  late final Animation<double> worldTranslateY;

  late final List<AnimationController> cloudControllers;
  late final AudioPlayer audioPlayer;

  // تم تعديل إحداثيات الجزر بدقة:
  // 1. المعالم والسيارات مرفوعة قليلاً للأعلى.
  // 2. الطبيعة مرفوعة للأعلى لتترك مسافة فاصلة وآمنة تماماً بينها وبين جزيرة الحيوانات.
  static final List<_RelativeRect> _islandRects = [

    // جزيرة الفضاء
    _RelativeRect(
      id: "space",
      left: 210 / worldWidth,
      top: 9 / worldHeight,
      width: 480 / worldWidth,
      height: 540 / worldHeight,
    ),

    // المعالم (مرفوعة قليلاً)
    _RelativeRect(
      id: "landmarks",
      left: 100 / worldWidth,
      top: 408 / worldHeight,
      width: 335 / worldWidth,
      height: 365 / worldHeight,
    ),

    // السيارات (مرفوعة قليلاً)
    _RelativeRect(
      id: "cars",
      left: 460 / worldWidth,
      top: 408 / worldHeight,
      width: 335 / worldWidth,
      height: 365 / worldHeight,
    ),

    // الطبيعة (مرفوعة أكثر لتترك مسافة بينها وبين الحيوانات)
    _RelativeRect(
      id: "nature",
      left: 268 / worldWidth,
      top: 600 / worldHeight,
      width: 360 / worldWidth,
      height: 380 / worldHeight,
    ),

    // الحيوانات (في الأسفل مع وجود مسافة فاصلة بينها وبين الطبيعة)
    _RelativeRect(
      id: "animals",
      left: 268 / worldWidth,
      top: 935 / worldHeight,
      width: 350 / worldWidth,
      height: 380 / worldHeight,
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
    audioPlayer = AudioPlayer();

    worldController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..forward(from: 0.0);
    
    worldController.repeat(reverse: true);

    worldScale = Tween<double>(
      begin: 1.00,
      end: 1.07,
    ).animate(
      CurvedAnimation(
        parent: worldController,
        curve: Curves.easeInOut,
      ),
    );

    worldTranslateY = Tween<double>(
      begin: -22,
      end: 22,
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
    audioPlayer.dispose();

    for (final controller in cloudControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  PuzzleModel? getIsland(String id) {
    for (final item in islands) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  Future<void> playClickSound() async {
    try {
      await audioPlayer.play(AssetSource('audio/puzzle_click.mp3'));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff08182b),
      body: LayoutBuilder(
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

          return ClipRect(
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
                                child: Image.asset(
                                  mapImage,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stack) =>
                                      const SizedBox.shrink(),
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
                
                // أيقونة المحفظة: أسفل يسار الشاشة مع وهج مشع وآمن لا يغطي الشاشة
                Positioned(
                  bottom: 25,
                  left: 20,
                  child: GestureDetector(
                    onTap: () async {
                      await playClickSound();
                    },
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
                ),

                // أيقونة الجزيرة الخاصة: تفتح استوديو الصور
                Positioned(
                  bottom: 25,
                  right: 20,
                  child: GestureDetector(
                    onTap: () async {
                      await playClickSound();

                      if (!context.mounted) return;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PrivateIslandScreen(),
                        ),
                      );
                    },
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
                        child: SizedBox(
                          width: 55,
                          height: 55,
                          child: Image.asset(
                            "assets/images/ui/add_pic.png",
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stack) =>
                                const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget cloudWidget({
    required _RelativeCloud cloud,
    required AnimationController controller,
  }) {
    final double top = cloud.top * worldHeight;
    final double size = cloud.size * worldWidth;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Positioned(
          left: (worldWidth + 100) -
              (controller.value * (worldWidth + 400)),
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
        errorBuilder: (context, error, stack) => const SizedBox.shrink(),
      ),
    );
  }

  Widget islandImage({
    required _RelativeRect rect,
  }) {
    final island = getIsland(rect.id);

    if (island == null) {
      return const SizedBox.shrink();
    }

    final double left = rect.left * worldWidth;
    final double top = rect.top * worldHeight;
    final double width = rect.width * worldWidth;
    final double height = rect.height * worldHeight;

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: GestureDetector(
        onTap: () async {
          await playClickSound();
          openIsland(island);
        },
        behavior: HitTestBehavior.opaque,
        child: Image.asset(
          island.image,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stack) => const SizedBox.shrink(),
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
