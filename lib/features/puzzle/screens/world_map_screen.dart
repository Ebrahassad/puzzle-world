Import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../data/puzzle_data.dart';
import '../models/puzzle_model.dart';
import '../widgets/wallet_icon_widget.dart';
import 'island_screen.dart';

class _RelativeRect {
  Final String id;
  Final double left;
  Final double top;
  Final double width;
  Final double height;

  Const _RelativeRect({
    Required this.id,
    Required this.left,
    Required this.top,
    Required this.width,
    Required this.height,
  });
}

class _RelativeCloud {
  Final String image;
  Final double top;
  Final double size;
  Final double opacity;
  Final Duration duration;

  Const _RelativeCloud({
    Required this.image,
    Required this.top,
    Required this.size,
    Required this.opacity,
    Required this.duration,
  });
}

class WorldMapScreen extends StatefulWidget {
  Const WorldMapScreen({
    Super.key,
  });

  @override
  State<WorldMapScreen> createState() =>
      _WorldMapScreenState();
}

class _WorldMapScreenState
    Extends State<WorldMapScreen>
    With TickerProviderStateMixin {

  Static const String mapImage =
      "assets/images/world/world_map.jpg";

  Static const double worldWidth = 896;
  Static const double worldHeight = 1350;

  Late final List<PuzzleModel> islands;

  Late final AnimationController worldController;
  Late final Animation<double> worldScale;
  Late final Animation<double> worldTranslateY;

  Late final List<AnimationController> cloudControllers;
  Late final AudioPlayer audioPlayer;

  // تم تعديل إحداثيات الجزر بدقة:
  // 1. المعالم والسيارات مرفوعة قليلاً للأعلى.
  // 2. الطبيعة مرفوعة للأعلى لتترك مسافة فاصلة وآمنة تماماً بينها وبين جزيرة الحيوانات.
  Static final List<_RelativeRect> _islandRects = [

    // جزيرة الفضاء
    _RelativeRect(
      Id: "space",
      Left: 210 / worldWidth,
      Top: 9 / worldHeight,
      Width: 480 / worldWidth,
      Height: 540 / worldHeight,
    ),

    // المعالم (مرفوعة قليلاً)
    _RelativeRect(
      Id: "landmarks",
      Left: 100 / worldWidth,
      Top: 410 / worldHeight,
      Width: 335 / worldWidth,
      Height: 365 / worldHeight,
    ),

    // السيارات (مرفوعة قليلاً)
    _RelativeRect(
      Id: "cars",
      Left: 460 / worldWidth,
      Top: 410 / worldHeight,
      Width: 335 / worldWidth,
      Height: 365 / worldHeight,
    ),

    // الطبيعة (مرفوعة أكثر لتترك مسافة بينها وبين الحيوانات)
    _RelativeRect(
      Id: "nature",
      Left: 268 / worldWidth,
      Top: 605 / worldHeight,
      Width: 360 / worldWidth,
      Height: 380 / worldHeight,
    ),

    // الحيوانات (في الأسفل مع وجود مسافة فاصلة بينها وبين الطبيعة)
    _RelativeRect(
      Id: "animals",
      Left: 268 / worldWidth,
      Top: 935 / worldHeight,
      Width: 350 / worldWidth,
      Height: 380 / worldHeight,
    ),

  ];

  Static final List<_RelativeCloud> _clouds = [
    _RelativeCloud(
      Image: "assets/images/background/cloud_01.png",
      Top: 80 / worldHeight,
      Size: 280 / worldWidth,
      Opacity: 0.22,
      Duration: Duration(seconds: 55),
    ),
    _RelativeCloud(
      Image: "assets/images/background/cloud_02.png",
      Top: 200 / worldHeight,
      Size: 220 / worldWidth,
      Opacity: 0.22,
      Duration: Duration(seconds: 70),
    ),
    _RelativeCloud(
      Image: "assets/images/background/cloud_03.png",
      Top: 40 / worldHeight,
      Size: 170 / worldWidth,
      Opacity: 0.22,
      Duration: Duration(seconds: 90),
    ),
    _RelativeCloud(
      Image: "assets/images/background/cloud_04.png",
      Top: 300 / worldHeight,
      Size: 240 / worldWidth,
      Opacity: 0.22,
      Duration: Duration(seconds: 65),
    ),
  ];

  @override
  Void initState() {
    Super.initState();

    Islands = PuzzleData.puzzles;
    AudioPlayer = AudioPlayer();

    WorldController = AnimationController(
      Vsync: this,
      Duration: const Duration(seconds: 22),
    )..forward(from: 0.0);
    
    WorldController.repeat(reverse: true);

    WorldScale = Tween<double>(
      Begin: 1.00,
      End: 1.07,
    ).animate(
      CurvedAnimation(
        Parent: worldController,
        Curve: Curves.easeInOut,
      ),
    );

    WorldTranslateY = Tween<double>(
      Begin: -22,
      End: 22,
    ).animate(
      CurvedAnimation(
        Parent: worldController,
        Curve: Curves.easeInOut,
      ),
    );

    CloudControllers = _clouds
        .map(
          (cloud) => AnimationController(
            Vsync: this,
            Duration: cloud.duration,
          )..repeat(),
        )
        .toList();
  }

  @override
  Void dispose() {
    WorldController.dispose();
    AudioPlayer.dispose();

    For (final controller in cloudControllers) {
      Controller.dispose();
    }

    Super.dispose();
  }

  PuzzleModel? getIsland(String id) {
    For (final item in islands) {
      If (item.id == id) {
        Return item;
      }
    }
    Return null;
  }

  Future<void> playClickSound() async {
    Try {
      Await audioPlayer.play(AssetSource('audio/puzzle_click.mp3'));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    Return Scaffold(
      BackgroundColor: const Color(0xff08182b),
      Body: LayoutBuilder(
        Builder: (context, constraints) {
          Final double screenWidth = constraints.maxWidth;
          Final double screenHeight = constraints.maxHeight;

          If (screenWidth <= 0 || screenHeight <= 0) {
            Return const SizedBox.shrink();
          }

          Final double scale = math.max(
            ScreenWidth / worldWidth,
            ScreenHeight / worldHeight,
          );

          Final double scaledWidth = worldWidth * scale;
          Final double scaledHeight = worldHeight * scale;

          Final double dx = (screenWidth - scaledWidth) / 2;
          Final double dy = (screenHeight - scaledHeight) / 2;

          Return ClipRect(
            Child: Stack(
              Children: [
                Positioned(
                  Left: dx,
                  Top: dy,
                  Child: Transform.scale(
                    Scale: scale,
                    Alignment: Alignment.topLeft,
                    Child: SizedBox(
                      Width: worldWidth,
                      Height: worldHeight,
                      Child: AnimatedBuilder(
                        Animation: worldController,
                        Builder: (context, child) {
                          Return Transform.translate(
                            Offset: Offset(0, worldTranslateY.value),
                            Child: Transform.scale(
                              Scale: worldScale.value,
                              Alignment: Alignment.center,
                              Child: child,
                            ),
                          );
                        },
                        Child: SizedBox(
                          Width: worldWidth,
                          Height: worldHeight,
                          Child: Stack(
                            ClipBehavior: Clip.none,
                            Children: [
                              Positioned.fill(
                                Child: Image.asset(
                                  MapImage,
                                  Fit: BoxFit.cover,
                                  ErrorBuilder: (context, error, stack) =>
                                      const SizedBox.shrink(),
                                ),
                              ),

                              For (int i = 0; i < _clouds.length; i++)
                                cloudWidget(
                                  Cloud: _clouds[i],
                                  Controller: cloudControllers[i],
                                ),

                              For (final rect in _islandRects)
                                islandImage(
                                  Rect: rect,
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
                  Bottom: 25,
                  Left: 20,
                  Child: GestureDetector(
                    OnTap: () async {
                      Await playClickSound();
                    },
                    Child: Container(
                      Decoration: BoxDecoration(
                        Shape: BoxShape.circle,
                        BoxShadow: [
                          BoxShadow(
                            Color: Colors.amber.withOpacity(0.85),
                            BlurRadius: 16,
                            SpreadRadius: 4,
                          ),
                        ],
                      ),
                      Child: Transform.scale(
                        Scale: 1.15,
                        Child: const WalletIconWidget(),
                      ),
                    ),
                  ),
                ),

                // أيقونة إضافة صورة جديدة: أسفل يمين الشاشة بنفس تنسيق وحجم ومؤثيرات أيقونة المحفظة
                Positioned(
                  Bottom: 25,
                  Right: 20,
                  Child: GestureDetector(
                    OnTap: () async {
                      Await playClickSound();
                      // هنا يمكنك إضافة الكود الخاص بفتح استوديو الهاتف لاختيار الصورة
                    },
                    Child: Container(
                      Decoration: BoxDecoration(
                        Shape: BoxShape.circle,
                        BoxShadow: [
                          BoxShadow(
                            Color: Colors.amber.withOpacity(0.85),
                            BlurRadius: 16,
                            SpreadRadius: 4,
                          ),
                        ],
                      ),
                      Child: Transform.scale(
                        Scale: 1.15,
                        Child: SizedBox(
                          Width: 55, // تحديد حجم متناسق يشبه أيقونة المحفظة
                          Height: 55,
                          Child: Image.asset(
                            "Assets/images/ui/add_pic.png",
                            Fit: BoxFit.contain,
                            ErrorBuilder: (context, error, stack) =>
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
    Required _RelativeCloud cloud,
    Required AnimationController controller,
  }) {
    Final double top = cloud.top * worldHeight;
    Final double size = cloud.size * worldWidth;

    Return AnimatedBuilder(
      Animation: controller,
      Builder: (context, child) {
        Return Positioned(
          Left: (worldWidth + 100) -
              (controller.value * (worldWidth + 400)),
          Top: top,
          Child: Opacity(
            Opacity: cloud.opacity,
            Child: Transform.rotate(
              Angle: controller.value * 0.15,
              Child: child,
            ),
          ),
        );
      },
      Child: Image.asset(
        Cloud.image,
        Width: size,
        ErrorBuilder: (context, error, stack) => const SizedBox.shrink(),
      ),
    );
  }

  Widget islandImage({
    Required _RelativeRect rect,
  }) {
    Final island = getIsland(rect.id);

    If (island == null) {
      Return const SizedBox.shrink();
    }

    Final double left = rect.left * worldWidth;
    Final double top = rect.top * worldHeight;
    Final double width = rect.width * worldWidth;
    Final double height = rect.height * worldHeight;

    Return Positioned(
      Left: left,
      Top: top,
      Width: width,
      Height: height,
      Child: GestureDetector(
        OnTap: () async {
          Await playClickSound();
          OpenIsland(island);
        },
        Behavior: HitTestBehavior.opaque,
        Child: Image.asset(
          Island.image,
          Fit: BoxFit.contain,
          ErrorBuilder: (context, error, stack) => const SizedBox.shrink(),
        ),
      ),
    );
  }

  Void openIsland(PuzzleModel island) {
    Navigator.push(
      Context,
      MaterialPageRoute(
        Builder: (_) => IslandScreen(
          Island: island,
        ),
      ),
    );
  }
}
