import 'dart:math' as math;

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
  // لوحة التصميم المرجعية لكل "عالم الجزيرة" (خلفية + جزيرة + مسار
  // المراحل معاً). كل الإحداثيات في هذا الملف مُعرَّفة بوحدات هذه
  // اللوحة، ثم يُحسب Scale حقيقي من حجم الشاشة الفعلي عبر
  // LayoutBuilder بحيث يغطي العالم الشاشة بالكامل على أي جهاز —
  // هاتف صغير، هاتف طويل، أو تابلت — دون فراغ أسود ودون أي تشويه.
  static const double worldWidth = 1080;
  static const double worldHeight = 1920;

  // نسبة ارتفاع منطقة الجزيرة من أعلى اللوحة. الجزيرة تُرسم مركزية
  // أعلى الشاشة وبحجم كبير وواضح، مع ترك مساحة كافية حولها.
  static const double islandAreaTop = worldHeight * 0.00;
  static const double islandAreaHeight = worldHeight * 0.66;

  // شفافية خفيفة لخلفية وصورة الجزيرة فقط، حتى يبرز مسار المراحل
  // بوضوح فوقها دون أن تختفي تفاصيل رسم الجزيرة.
  static const double islandBackgroundOpacity = 0.55;
static const double islandImageOpacity = 0.65;

  late final List<PuzzleLevelModel> levels;

  late final AnimationController worldController;
  late final Animation<double> worldScale;
  late final Animation<double> worldTranslateY;

  // مسار المراحل: من الأسفل إلى الأعلى (المرحلة 1 أسفل اللوحة،
  // آخر مرحلة أعلاها)، بانحناء بسيط يمين/يسار يعطي شكل "رحلة" على
  // خريطة لعبة احترافية، وبإحداثيات طبيعية (0.0-1.0) وليست بكسل
  // ثابت — لذلك يعمل نفس المسار على أي حجم شاشة.
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

    // تأثير "تنفس" واحد لكل العالم (خلفية + جزيرة + مراحل معاً) —
    // تكبير خفيف جداً + انزياح رأسي بسيط، بالضبط ضمن النطاق المطلوب.
    // لا يوجد أي تحريك منفصل لأي زر مرحلة أو للجزيرة وحدها.
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

  /// زر مرحلة واحد. [size] هو الحجم الفعلي بوحدات لوحة العالم
  /// (world units)، يُحسب في [build] بحيث يصبح حجمه على الشاشة
  /// الحقيقية بين 70-90 بكسل منطقي تقريباً مهما اختلف الجهاز.
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
      body: Container(
        color: const Color(0xff020b24),
        child: SafeArea(
          child: Stack(
            children: [
              // العالم الرئيسي: خلفية + جزيرة + مسار المراحل معاً،
              // محجّم عبر LayoutBuilder بدل OverflowBox/AspectRatio
              // القديم (الذي كان يسبب تكبيراً غير متوقع وأزراراً
              // كبيرة جداً على الهواتف).
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double screenWidth = constraints.maxWidth;
                    final double screenHeight = constraints.maxHeight;

                    if (screenWidth <= 0 || screenHeight <= 0) {
                      return const SizedBox.shrink();
                    }

                    // "cover" يدوي: أكبر Scale من (العرض، الارتفاع)
                    // بحيث تغطي لوحة العالم الشاشة بالكامل في
                    // الاتجاهين معاً دون فراغ أسود ودون أي تشويه
                    // (لأن نفس القيمة تُطبَّق على المحورين معاً).
                    final double scale = math.max(
                      screenWidth / worldWidth,
                      screenHeight / worldHeight,
                    );

                    final double scaledWidth = worldWidth * scale;
                    final double scaledHeight = worldHeight * scale;

                    final double dx = (screenWidth - scaledWidth) / 2;
                    final double dy = (screenHeight - scaledHeight) / 2;

                    // حجم زر المرحلة بوحدات لوحة العالم، محسوب
                    // ديناميكياً من scale الفعلي بحيث يبقى حجمه على
                    // الشاشة الحقيقية دائماً قريباً من 70-90 بكسل
                    // منطقي (macro-clamped لتفادي أحجام متطرفة على
                    // الشاشات الصغيرة جداً أو التابلت).
                    final double levelButtonSize =
                        (80 / scale).clamp(150.0, 260.0);

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
                                  // العالم كله (خلفية + جزيرة + مراحل) هو
                                  // child واحد مشترك، فحركة "التنفس"
                                  // تنعكس عليه ككتلة واحدة فقط.
                                  child: SizedBox(
                                    width: worldWidth,
                                    height: worldHeight,
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        // خلفية الجزيرة، بشفافية خفيفة حتى
                                        // يبرز مسار المراحل فوقها بوضوح.
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

                                        // صورة الجزيرة نفسها: مركزية أعلى
                                        // اللوحة، بحجم كبير وواضح، بدون أي
                                        // قص (BoxFit.contain)، وبشفافية
                                        // خفيفة جداً فقط لإبراز المراحل.
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

                                        // مسار المراحل: إحداثيات طبيعية ضمن
                                        // لوحة العالم الكاملة، من الأسفل إلى
                                        // الأعلى، بحجم موحّد ومحسوب ديناميكياً.
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
                    );
                  },
                ),
              ),

              // أزرار التحكم: ثابتة فوق كل شيء، خارج العالم المتحرك
              // تماماً، ولا تتأثر بمقياسه أو بحركة "التنفس".
              Positioned(
                top: 20,
                left: 20,
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.black54,
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

              Positioned(
                top: 20,
                right: 20,
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.black54,
                  child: IconButton(
                    icon: const Icon(
                      Icons.settings,
                      color: Colors.white,
                      size: 32,
                    ),
                    onPressed: () {},
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}