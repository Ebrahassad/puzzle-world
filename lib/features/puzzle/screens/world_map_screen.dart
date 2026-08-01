import 'package:flutter/material.dart';

import '../data/puzzle_data.dart';
import '../models/puzzle_model.dart';

import 'island_screen.dart';

/// موقع/حجم جزيرة كنسبة (0.0 - 1.0) من أبعاد صورة الخريطة الأصلية.
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

/// إعداد سحابة كنسبة من أبعاد الخريطة، مع سرعة درفت خاصة بها.
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
  State<WorldMapScreen> createState() => _WorldMapScreenState();
}

class _WorldMapScreenState extends State<WorldMapScreen>
    with TickerProviderStateMixin {
  static const String mapImage = "assets/images/world/world_map.png";

  // Canvas مرجعي لأبعاد صورة الخريطة الأصلية. هذا ليس حجم العرض على
  // الشاشة، بل مساحة إحداثيات ثابتة تُحسب عليها كل المواقع (جزر + سحب).
  static const double worldWidth = 896;
  static const double worldHeight = 1350;

  // هامش أمان صغير فوق قيمة الـ cover المحسوبة، حتى لا تظهر أي شعرة
  // فراغ عند أطراف الشاشة بسبب فروقات التقريب أو حركة التنفس.
  static const double _safetyMargin = 1.02;

  late final List<PuzzleModel> islands;

  // AnimationController واحد فقط لحركة "التنفس" الخفيفة للعالم كاملاً.
  late final AnimationController worldController;
  late final Animation<double> breathingScale;

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
      duration: const Duration(seconds: 55),
    ),
    _RelativeCloud(
      image: "assets/images/background/cloud_02.png",
      top: 200 / worldHeight,
      size: 220 / worldWidth,
      opacity: 0.22,
      duration: const Duration(seconds: 70),
    ),
    _RelativeCloud(
      image: "assets/images/background/cloud_03.png",
      top: 40 / worldHeight,
      size: 170 / worldWidth,
      opacity: 0.22,
      duration: const Duration(seconds: 90),
    ),
    _RelativeCloud(
      image: "assets/images/background/cloud_04.png",
      top: 300 / worldHeight,
      size: 240 / worldWidth,
      opacity: 0.22,
      duration: const Duration(seconds: 65),
    ),
  ];

  late final List<AnimationController> cloudControllers;

  @override
  void initState() {
    super.initState();

    islands = PuzzleData.puzzles;

    worldController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat(reverse: true);

    // تنفس خفيف جداً فوق الـ base scale المحسوب ديناميكياً.
    breathingScale = Tween<double>(
      begin: 1.0,
      end: 1.012,
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
    return islands.firstWhere((item) => item.id == id);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff08182b),
      body: SizedBox.expand(
        // LayoutBuilder يعطينا أبعاد الشاشة الفعلية (هاتف صغير/كبير/
        // تابلت) لحساب نسبة تحجيم ديناميكية بدل الاعتماد على
        // BoxFit.contain (يترك فراغات) أو BoxFit.cover المباشر
        // (يقص بلا تحكم).
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double screenWidth = constraints.maxWidth;
            final double screenHeight = constraints.maxHeight;

            // نفس منطق "cover" لكن محسوب يدوياً: نختار أكبر نسبة بين
            // (عرض الشاشة / عرض الخريطة) و (ارتفاع الشاشة / ارتفاع
            // الخريطة) بحيث تغطي الخريطة الشاشة بالكامل دون أي فراغ،
            // مع هامش أمان بسيط يمنع ظهور أي شعرة فراغ عند الحواف.
            final double coverScale = [
              screenWidth / worldWidth,
              screenHeight / worldHeight,
            ].reduce((a, b) => a > b ? a : b);

            final double baseScale = coverScale * _safetyMargin;

            return ClipRect(
              child: Center(
                child: AnimatedBuilder(
                  animation: worldController,
                  builder: (context, child) {
                    // الـ scale النهائي = تغطية الشاشة (ديناميكي حسب
                    // الجهاز) × تنفس العالم الخفيف. كل عنصر داخل هذه
                    // الطبقة (خريطة + سحب + جزر) يتحرك بنفس القيمة
                    // معاً، فلا يوجد قص واضح ولا فراغات سوداء على أي
                    // حجم شاشة.
                    final double finalScale =
                        baseScale * breathingScale.value;

                    return Transform.scale(
                      scale: finalScale,
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

                        for (int i = 0; i < _clouds.length; i++)
                          _CloudLayer(
                            cloud: _clouds[i],
                            controller: cloudControllers[i],
                            worldWidth: worldWidth,
                            worldHeight: worldHeight,
                          ),

                        for (final rect in _islandRects)
                          _IslandLayer(
                            rect: rect,
                            island: getIsland(rect.id),
                            worldWidth: worldWidth,
                            worldHeight: worldHeight,
                            onTap: openIsland,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// سحابة واحدة تتحرك أفقياً بسرعتها الخاصة داخل نفس طبقة العالم،
/// فتتأثر تلقائياً بأي scale يُطبَّق على العالم كله (تغطية الشاشة +
/// التنفس معاً).
class _CloudLayer extends StatelessWidget {
  final _RelativeCloud cloud;
  final AnimationController controller;
  final double worldWidth;
  final double worldHeight;

  const _CloudLayer({
    required this.cloud,
    required this.controller,
    required this.worldWidth,
    required this.worldHeight,
  });

  @override
  Widget build(BuildContext context) {
    final double top = cloud.top * worldHeight;
    final double size = cloud.size * worldWidth;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Positioned(
          left: (worldWidth + 100) - (controller.value * (worldWidth + 400)),
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
}

/// جزيرة واحدة مثبتة بإحداثيات نسبية ثابتة ضمن لوحة العالم، بلا أي
/// AnimationController خاص بها - حركتها بالكامل نتيجة الـ Transform
/// المشترك في الشاشة الأم.
class _IslandLayer extends StatelessWidget {
  final _RelativeRect rect;
  final PuzzleModel island;
  final double worldWidth;
  final double worldHeight;
  final ValueChanged<PuzzleModel> onTap;

  const _IslandLayer({
    required this.rect,
    required this.island,
    required this.worldWidth,
    required this.worldHeight,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
        onTap: () => onTap(island),
        child: Image.asset(
          island.image,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}