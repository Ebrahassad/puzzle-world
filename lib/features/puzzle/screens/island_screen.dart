import 'package:flutter/material.dart';

import '../data/island_background_data.dart';
import '../data/puzzle_level_data.dart';

import '../models/puzzle_model.dart';
import '../models/puzzle_level_model.dart';

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
  // لوحة إحداثيات مرجعية ثابتة لكل "عالم الجزيرة".
  // كل شيء (خلفية + جزيرة + أزرار) يُوضع بإحداثيات ضمن هذه اللوحة،
  // ثم FittedBox هو من يتكفل بتحجيمها لتناسب أي شاشة دون أي قص.
  static const double worldWidth = 1080;
  static const double worldHeight = 1920;

  // نسبة المساحة العلوية المخصصة لصورة الجزيرة (نفس القيمة القديمة 0.36).
  static const double islandAreaHeightFraction = 0.36;

  final List<Offset> levelPositions = const [
    Offset(0.15, 0.00),
    Offset(0.65, 0.08),
    Offset(0.25, 0.16),
    Offset(0.70, 0.24),
    Offset(0.30, 0.32),
    Offset(0.65, 0.40),
    Offset(0.25, 0.48),
    Offset(0.70, 0.56),
    Offset(0.35, 0.64),
    Offset(0.60, 0.72),
  ];

  final List<int> levelOrder = const [
    0, // 1
    9, // 10
    1, // 2
    8, // 9
    2, // 3
    7, // 8
    3, // 4
    6, // 7
    4, // 5
    5, // 6
  ];

  // متحكم حركة واحد فقط لكل العالم (خلفية + جزيرة + أزرار معاً).
  late final AnimationController worldController;
  late final Animation<double> worldScale;
  late final Animation<double> worldTranslate;

  late List<PuzzleLevelModel> levels;

  @override
  void initState() {
    super.initState();

    levels = PuzzleLevelData.getLevels(
      widget.island.id,
    );

    worldController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);

    // نفس تأثير "التنفس" البطيء الموجود سابقاً، لكنه الآن يُطبَّق
    // على العالم كاملاً (خلفية + جزيرة + أزرار) بدل الخلفية وحدها.
    worldScale = Tween<double>(
      begin: 1.0,
      end: 1.02,
    ).animate(
      CurvedAnimation(
        parent: worldController,
        curve: Curves.easeInOut,
      ),
    );

    worldTranslate = Tween<double>(
      begin: -8,
      end: 8,
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
        ),
      ),
    );
  }

  Widget levelButton(
    PuzzleLevelModel level,
  ) {
    return GestureDetector(
      onTap: () {
        openLevel(level);
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            "assets/images/ui/level_piece.png",
            width: 95,
            height: 95,
            fit: BoxFit.contain,
          ),
          Text(
            "${level.levelNumber}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // طبقة العالم الواحدة: خلفية + جزيرة + أزرار المراحل معاً.
          // FittedBox(contain) يعرض اللوحة كاملة بدون أي قص وبنفس
          // نسبة أبعادها على الهواتف الصغيرة والكبيرة والتابلت،
          // ويتوسط تلقائياً داخل الشاشة.
          Positioned.fill(
            child: FittedBox(
              fit: BoxFit.contain,
              alignment: Alignment.center,
              child: SizedBox(
                width: worldWidth,
                height: worldHeight,
                child: AnimatedBuilder(
                  animation: worldController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: worldScale.value,
                      alignment: Alignment.center,
                      child: Transform.translate(
                        offset: Offset(worldTranslate.value, 0),
                        child: child,
                      ),
                    );
                  },
                  // كل العناصر التالية هي child واحد مشترك، لذلك أي
                  // scale/translate على العالم ينعكس عليها معاً وبنفس
                  // النسبة، دون أي حركة مستقلة لأي عنصر بمفرده.
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // خلفية الجزيرة: تملأ لوحة العالم بالكامل دون
                      // أي قص وبنفس نسبة أبعادها الأصلية.
                      Positioned.fill(
                        child: Image.asset(
                          IslandBackgroundData.getBackground(
                            widget.island.id,
                          ),
                          fit: BoxFit.contain,
                          alignment: Alignment.center,
                        ),
                      ),

                      // صورة الجزيرة: مثبتة فوق الخلفية بإحداثيات
                      // ثابتة داخل لوحة العالم (وليست عائمة بحركة
                      // مستقلة عن العالم).
                      Positioned(
                        left: 0,
                        top: 0,
                        width: worldWidth,
                        height: worldHeight * islandAreaHeightFraction,
                        child: Image.asset(
                          widget.island.image,
                          fit: BoxFit.contain,
                        ),
                      ),

                      // أزرار المراحل: إحداثيات نسبية ضمن مساحة
                      // الجزيرة (world/island coordinates)، وليست
                      // نسبة من حجم الشاشة مباشرة. بهذا تبقى كل
                      // مرحلة فوق نفس نقطتها على الجزيرة مهما تغيّر
                      // حجم الهاتف.
                      ...List.generate(
                        levels.length,
                        (index) {
                          final pos = levelPositions[index];

                          final double areaTop =
                              worldHeight * islandAreaHeightFraction;
                          final double areaHeight =
                              worldHeight * (1 - islandAreaHeightFraction);

                          return Positioned(
                            left: worldWidth * pos.dx,
                            top: areaTop + (areaHeight * pos.dy),
                            child: levelButton(
                              levels[levelOrder[index]],
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

          // طبقة تظليل خفيفة ثابتة فوق العالم (ليست جزءاً من حركته).
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.05),
            ),
          ),

          // واجهة الأزرار العلوية (رجوع/إعدادات): عناصر UI ثابتة
          // فوق كل شيء، لا تتحرك مع العالم.
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: const Icon(
                        Icons.settings,
                        color: Colors.white,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}