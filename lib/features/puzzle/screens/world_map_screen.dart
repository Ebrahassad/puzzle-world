import 'dart:math' as math;

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

  // لوحة إحداثيات مرجعية ثابتة للعالم كاملاً (خلفية + غيوم + جزر).
  // نفس فكرة IslandScreen: كل شيء يُوضع بإحداثيات ضمن هذه اللوحة،
  // ثم يُحسب Scale حقيقي من حجم الشاشة عبر LayoutBuilder بحيث تغطي
  // اللوحة الشاشة بالكامل (بدون أي فراغ أسود وبدون أي تشويه) على
  // أي جهاز — هاتف صغير، هاتف طويل، أو تابلت.
  static const double worldWidth = 896;
  static const double worldHeight = 1350;

  late final List<PuzzleModel> islands;

  // متحكم حركة واحد فقط لكل العالم (خلفية + غيوم + جزر معاً) —
  // بالضبط كما هو مطلوب: عنصر واحد يتحرك، وليس كل جزيرة بمفردها.
  late final AnimationController worldController;
  late final Animation<double> worldScale;
  late final Animation<double> worldTranslateY;

  late final List<AnimationController> cloudControllers;

  // مواقع الجزر مُعرَّفة بوحدات لوحة العالم (896x1350) ثم تُحوَّل إلى
  // نسب طبيعية (0.0-1.0) تلقائياً في المُنشئ أدناه، وتُستخدم هذه
  // النسب لاحقاً لحساب أي حجم شاشة فعلي — لا توجد أي قيم بكسل
  // خاصة بجهاز معيّن.
  //
  // جزيرة "space" هي المحور الرئيسي: مركزية أعلى الخريطة، وأكبر من
  // بقية الجزر بحوالي 30%. باقي الجزر مرتبة حولها بأحجام متفاوتة
  // ومتداخلة قليلاً مع حافتها السفلى لخلق شعور "عالم واحد متصل"
  // بدل صور منفصلة على خلفية.
  static final List<_RelativeRect> _islandRects = [

  // جزيرة الفضاء: أعلى المنتصف كما هي
  _RelativeRect(
  id: "space",
  left: 210 / worldWidth,
  top: 10 / worldHeight,
  width: 480 / worldWidth,
  height: 540 / worldHeight,
),


  // المعالم: يسار تحت الفضاء
  _RelativeRect(
    id: "landmarks",
    left: 70 / worldWidth,
    top: 470 / worldHeight,
    width: 300 / worldWidth,
    height: 330 / worldHeight,
  ),


  // السيارات: يمين تحت الفضاء وقريبة من المعالم
  _RelativeRect(
    id: "cars",
    left: 525 / worldWidth,
    top: 470 / worldHeight,
    width: 300 / worldWidth,
    height: 330 / worldHeight,
  ),


  // الطبيعة: في الوسط أسفل المعالم والسيارات
  _RelativeRect(
    id: "nature",
    left: 280 / worldWidth,
    top: 820 / worldHeight,
    width: 330 / worldWidth,
    height: 370 / worldHeight,
  ),


  // الحيوانات: بجانب الطبيعة وأسفل المجموعة
  _RelativeRect(
    id: "animals",
    left: 500 / worldWidth,
    top: 820 / worldHeight,
    width: 320 / worldWidth,
    height: 370 / worldHeight,
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

    // تأثير "التنفس" الوحيد للعالم كله: تكبير خفيف جداً + انزياح
    // رأسي بسيط، بالضبط ضمن النطاق المطلوب (Scale 1.00-1.03،
    // Translate عمودي -5..+5)، مطبَّق على Stack واحد يضم الخلفية
    // والغيوم والجزر معاً — لا يوجد أي تحريك منفصل لأي جزيرة.
    worldScale = Tween<double>(
      begin: 1.00,
      end: 1.03,
    ).animate(
      CurvedAnimation(
        parent: worldController,
        curve: Curves.easeInOut,
      ),
    );

    worldTranslateY = Tween<double>(
      begin: -5,
      end: 5,
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

  /// بحث آمن عن جزيرة بمعرّفها. يعيد null بدل تعطّل التطبيق إن كان
  /// أحد المعرّفات في [_islandRects] غير موجود ضمن [PuzzleData.puzzles]
  /// (بدل استخدام firstWhere غير الآمن الذي يرمي استثناءً).
  PuzzleModel? getIsland(String id) {
    for (final item in islands) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff08182b),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double screenWidth = constraints.maxWidth;
          final double screenHeight = constraints.maxHeight;

          // نفس نظام "cover" اليدوي المستخدم في IslandScreen: أكبر
          // Scale من (العرض، الارتفاع) بحيث تغطي لوحة العالم الشاشة
          // بالكامل في الاتجاهين معاً دون أي فراغ أسود ودون أي تشويه
          // (لأن التحجيم موحّد لكلا المحورين).
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
                        // العالم كله (خلفية + غيوم + جزر) هو child واحد
                        // مشترك لهذا الـ AnimatedBuilder، لذلك حركة
                        // "التنفس" تنعكس على كل شيء معاً وبنفس النسبة —
                        // لا توجد أي حركة scale/translate منفصلة لأي جزيرة.
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

    // حماية من معرّف جزيرة غير موجود في بيانات اللعبة — تجاهل رسمها
    // بدل تعطّل الشاشة بالكامل.
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
      // منطقة اللمس هنا مطابقة تماماً لحجم/مكان الصورة المعروضة
      // (نفس width/height/Positioned)، فلا يوجد أي إزاحة بين ما
      // يراه المستخدم وما يستجيب للمس.
      child: GestureDetector(
        onTap: () => openIsland(island),
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