import 'package:flutter/material.dart';

import '../data/puzzle_data.dart';
import '../models/puzzle_model.dart';

import 'island_screen.dart';


/// نظام إحداثيات نسبي: كل موقع/حجم يُعرَّف كنسبة (0.0 - 1.0)
/// من أبعاد صورة الخريطة الأصلية، وليس كرقم بكسل ثابت.
/// هذا يضمن أن الجزر تبقى فوق أماكنها الصحيحة مهما تغير حجم الشاشة،
/// لأنها تتحرك وتتحجم بنفس نسبة تحرك وتحجم الخريطة نفسها.
class _RelativeRect {
  final String id;
  final double left; // نسبة من عرض الخريطة
  final double top; // نسبة من ارتفاع الخريطة
  final double width; // نسبة من عرض الخريطة
  final double height; // نسبة من ارتفاع الخريطة

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
  final double top; // نسبة من ارتفاع الخريطة
  final double size; // نسبة من عرض الخريطة
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

  // الأبعاد الأصلية لصورة الخريطة (تُستخدم فقط كمرجع نسبة أبعاد،
  // وليست حجماً ثابتاً يُفرض على الشاشة).
  static const double worldWidth = 896;
  static const double worldHeight = 1350;

  late final List<PuzzleModel> islands;

  // متحكم واحد فقط لكل "العالم": الخريطة + الجزر + السحب.
  // أي تغيّر في هذا المتحكم ينعكس على الطبقة كاملة كوحدة واحدة.
  late final AnimationController worldController;
  late final Animation<double> worldScale;

  // مواقع الجزر كنسب من أبعاد الخريطة الأصلية (0.0 - 1.0).
  // نفس القيم القديمة (left/top/width/height) لكن محوّلة إلى نسب.
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

  // إعدادات السحب كنسب أيضاً، مع الحفاظ على نفس الشفافية والسرعات السابقة.
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

  // متحكمات حركة السحب (درفت أفقي) - كل سحابة تحتفظ بسرعتها الخاصة،
  // لكنها تبقى مرسومة داخل نفس طبقة العالم فتتأثر بأي scale/transform عليه.
  late final List<AnimationController> cloudControllers;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff08182b),

      // FittedBox مع BoxFit.contain يعرض الخريطة كاملة دون أي قص،
      // مع الحفاظ على نسبة أبعادها الأصلية، وتوسيطها تلقائياً
      // في أي حجم شاشة (هاتف صغير/كبير/تابلت).
      body: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.contain,
          alignment: Alignment.center,
          child: SizedBox(
            width: worldWidth,
            height: worldHeight,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // نستخدم أبعاد "لوحة العالم" الثابتة (worldWidth/worldHeight)
                // كمساحة إحداثيات مرجعية فقط. FittedBox أعلاه هو من يتكفل
                // بتحجيمها لتلائم أي شاشة، لذلك كل ما نحسبه هنا يبقى
                // بنفس النسبة الصحيحة تلقائياً على كل الأجهزة.
                return AnimatedBuilder(
                  animation: worldController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: worldScale.value,
                      alignment: Alignment.center,
                      child: child,
                    );
                  },
                  // كل شيء (خريطة + سحب + جزر) داخل هذا الـ child الواحد،
                  // فيتحرك كطبقة واحدة موحدة وليس كعناصر منفصلة.
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
                        cloudWidget(
                          cloud: _clouds[i],
                          controller: cloudControllers[i],
                        ),

                      for (final rect in _islandRects)
                        islandImage(rect: rect),
                    ],
                  ),
                );
              },
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

  Widget islandImage({
    required _RelativeRect rect,
  }) {
    final island = getIsland(rect.id);

    // تحويل الإحداثيات النسبية إلى بكسلات ضمن لوحة العالم المرجعية.
    // بما أن اللوحة كاملة تُحجَّم عبر FittedBox و Transform.scale معاً،
    // فإن موقع/حجم كل جزيرة يبقى مرتبطاً بصورة الخريطة بنفس النسبة دائماً.
    final double left = rect.left * worldWidth;
    final double top = rect.top * worldHeight;
    final double width = rect.width * worldWidth;
    final double height = rect.height * worldHeight;

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      // لا يوجد أي تحريك مستقل هنا (لا AnimationController خاص بالجزيرة):
      // حركتها بالكامل تأتي من Transform.scale المشترك مع بقية العالم.
      child: GestureDetector(
        onTap: () => openIsland(island),
        child: Image.asset(
          island.image,
          fit: BoxFit.contain,
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