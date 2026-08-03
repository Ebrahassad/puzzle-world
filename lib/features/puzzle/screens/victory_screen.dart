import 'dart:async';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'world_map_screen.dart';

/// مدير المكافآت للتوافق مع المشروع
class RewardManager {
  static void addStar() {
    // تنفيذ إضافة النجمة في النظام الخاص بك
  }

  static void addGem() {
    // تنفيذ إضافة الجوهرة في النظام الخاص بك
  }
}

class VictoryCinematicScreen extends StatefulWidget {
  final String puzzleImage;
  final int levelNumber;
  final dynamic island;
  final bool isFinalLevel;
  final GlobalKey starTargetKey;
  final GlobalKey gemTargetKey;
  final VoidCallback? onFinished;
  final VoidCallback? onStarEarned;
  final VoidCallback? onGemEarned;
  final VoidCallback? onNextLevel;
  final VoidCallback? onReplay;
  final VoidCallback? onGoToMap;

  const VictoryCinematicScreen({
    Key? key,
    required this.puzzleImage,
    required this.levelNumber,
    this.island,
    this.isFinalLevel = false,
    required this.starTargetKey,
    required this.gemTargetKey,
    this.onFinished,
    this.onStarEarned,
    this.onGemEarned,
    this.onNextLevel,
    this.onReplay,
    this.onGoToMap,
  }) : super(key: key);

  @override
  State<VictoryCinematicScreen> createState() => _VictoryCinematicScreenState();
}

class _VictoryCinematicScreenState extends State<VictoryCinematicScreen>
    with TickerProviderStateMixin {
  // أجهزة التحكم بالحركة (Animation Controllers)
  late AnimationController _puzzleAssembleController;
  late AnimationController _puzzleShatterController;
  late AnimationController _chestDropController;
  late AnimationController _chestOpenController;
  late AnimationController _chestFlareController;
  late AnimationController _starFlyController;
  late AnimationController _gemFlyController;
  late AnimationController _celebrationController;

  // الحالات المرئية
  bool _isPuzzleShattered = false;
  bool _isChestVisible = false;
  bool _isStarFlying = false;
  bool _isGemFlying = false;
  bool _showActionButtons = false;
  bool _showCelebrationBanner = false;

  // إحداثيات الحركة الطائرة
  Offset _chestCenterOffset = Offset.zero;
  Offset _starTargetOffset = Offset.zero;
  Offset _gemTargetOffset = Offset.zero;

  // تحقق هل المرحلة الحالية هي المرحلة 10 أو نهاية الجزيرة
  bool get _effectiveIsFinalLevel =>
      widget.isFinalLevel || widget.levelNumber == 10;

  @override
  void initState() {
    super.initState();

    _puzzleAssembleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _puzzleShatterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _chestDropController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _chestOpenController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _chestFlareController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _starFlyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _gemFlyController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // بدء التسلسل السينمائي بعد بناء أول إطار
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateTargetPositions();
      _runVictorySequence();
    });
  }

  @override
  void dispose() {
    _puzzleAssembleController.dispose();
    _puzzleShatterController.dispose();
    _chestDropController.dispose();
    _chestOpenController.dispose();
    _chestFlareController.dispose();
    _starFlyController.dispose();
    _gemFlyController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  /// حساب إحداثيات الأهداف (Toolbar keys & Chest)
  void _calculateTargetPositions() {
    final Size screenSize = MediaQuery.of(context).size;
    _chestCenterOffset = Offset(screenSize.width / 2, screenSize.height / 2);

    _starTargetOffset = _getOffsetFromKey(widget.starTargetKey) ??
        Offset(screenSize.width * 0.2, 50);
    _gemTargetOffset = _getOffsetFromKey(widget.gemTargetKey) ??
        Offset(screenSize.width * 0.8, 50);
  }

  Offset? _getOffsetFromKey(GlobalKey key) {
    final RenderBox? renderBox =
        key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;
      return Offset(
          position.dx + size.width / 2, position.dy + size.height / 2);
    }
    return null;
  }

  /// التسلسل الرئيس للسينما والتفاعلات
  Future<void> _runVictorySequence() async {
    // 1. تجميع تركيب الصورة
    await _puzzleAssembleController.forward();
    await Future.delayed(const Duration(milliseconds: 200));

    // 2. تفتيت الصورة
    setState(() => _isPuzzleShattered = true);
    await _puzzleShatterController.forward();

    // 3. سقوط فتح صندوق المكافأة
    setState(() => _isChestVisible = true);
    await _chestDropController.forward();
    await _chestOpenController.forward();

    // 4. خروج النجمة وطيرانها
    setState(() => _isStarFlying = true);
    await _starFlyController.forward();
    setState(() => _isStarFlying = false);

    // عند وصول النجمة
    RewardManager.addStar();
    widget.onStarEarned?.call();

    // المسار الشرطي للمراحل العادية vs المرحلة 10 (نهاية الجزيرة)
    if (widget.levelNumber < 10) {

  // المراحل 1 - 9
  setState(() {
    _showActionButtons = true;
  });

  widget.onFinished?.call();

} else {

  // المرحلة 10 فقط
      // المرحلة 10: انتظر 700ms ثم أكمل للجوهرة والاحتفال
      await Future.delayed(const Duration(milliseconds: 700));

      // 5. فتح الصندوق مرة ثانية بإضاءة قوية
      await _chestFlareController.forward();

      // 6. خروج الجوهرة وطيرانها إلى Toolbar
setState(() {
  _isGemFlying = true;
});

// إعادة حساب هدف الجوهرة قبل الطيران
_gemTargetOffset = _getOffsetFromKey(widget.gemTargetKey) ??
    Offset(
      MediaQuery.of(context).size.width * 0.8,
      50,
    );

await _gemFlyController.forward();

setState(() {
  _isGemFlying = false;
});

      // عند وصول الجوهرة
      RewardManager.addGem();
      widget.onGemEarned?.call();

      // 7. احتفال وتأثيرات الجوهرة
      setState(() => _showCelebrationBanner = true);
      _celebrationController.repeat(reverse: true);

      // 8. الانتظار والانتقال التلقائي
   await Future.delayed(
  const Duration(milliseconds: 1500),
);

widget.onFinished?.call();

if (mounted) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(
      builder: (_) => const WorldMapScreen(),
    ),
    (route) => false,
  );
}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.85),
      body: Stack(
        children: [
          // 1. عرض التركيب والتفتيت للصورة
          if (!_isPuzzleShattered) _buildAssemblingPuzzle(),

          if (_isPuzzleShattered && _puzzleShatterController.isAnimating)
            _buildShatteringPuzzle(),

          // 2. صندوق المكافآت central chest
          if (_isChestVisible) _buildChestWidget(),

          // 3. طيران النجمة ⭐
          if (_isStarFlying)
            _buildFlyingItem(
              imagePath: 'assets/images/rewards/Star_gold.png',
              animation: _starFlyController,
              start: _chestCenterOffset,
              end: _starTargetOffset,
              glowColor: Colors.amber,
            ),

          // 4. طيران الجوهرة 💎
          if (_isGemFlying)
            _buildFlyingItem(
              imagePath: 'assets/images/rewards/gem.png',
              animation: _gemFlyController,
              start: _chestCenterOffset,
              end: _gemTargetOffset,
              glowColor: Colors.cyanAccent,
            ),

          // 5. بنر احتفال مكتمل الجزيرة
          if (_showCelebrationBanner) _buildCelebrationBanner(),

          // 6. أزرار التحكم (تظهر فقط في المراحل العادية)
          if (_showActionButtons && !_effectiveIsFinalLevel)
            _buildActionButtons(),
        ],
      ),
    );
  }

  /// ويدجت تجميع الصورة
  Widget _buildAssemblingPuzzle() {
    return Center(
      child: ScaleTransition(
        scale: CurvedAnimation(
          parent: _puzzleAssembleController,
          curve: Curves.elasticOut,
        ),
        child: FadeTransition(
          opacity: _puzzleAssembleController,
          child: Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.amberAccent,
                  blurRadius: 25,
                  spreadRadius: 5,
                )
              ],
              image: DecorationImage(
                image: AssetImage(widget.puzzleImage),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ويدجت تفتت الصورة
  Widget _buildShatteringPuzzle() {
    return AnimatedBuilder(
      animation: _puzzleShatterController,
      builder: (context, child) {
        final progress = _puzzleShatterController.value;
        return Center(
          child: Transform.scale(
            scale: 1.0 + (progress * 0.3),
            child: Opacity(
              opacity: (1.0 - progress).clamp(0.0, 1.0),
              child: CustomPaint(
                size: const Size(280, 280),
                painter: _ShatterPainter(
                  imageProvider: AssetImage(widget.puzzleImage),
                  progress: progress,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// ويدجت الصندوق مع تأثير الفتح والإضاءة
  Widget _buildChestWidget() {
    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge(
            [_chestDropController, _chestOpenController, _chestFlareController]),
        builder: (context, child) {
          final dropValue = CurvedAnimation(
            parent: _chestDropController,
            curve: Curves.bounceOut,
          ).value;

          final flareValue = _chestFlareController.value;
          final isOpen = _chestOpenController.value > 0.5;

          return Transform.translate(
            offset: Offset(0, (1 - dropValue) * -400),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // إضاءة خلفية قوية (Glow)
                Container(
                  width: 200 + (flareValue * 100),
                  height: 200 + (flareValue * 100),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.amber.withOpacity(0.8 * (0.5 + flareValue / 2)),
                        Colors.orange.withOpacity(0.4),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                // أيقونة الصندوق المغلق/المفتوح
                Icon(
                  isOpen ? Icons.inventory_2_outlined : Icons.inventory_2,
                  size: 130,
                  color: flareValue > 0.1 ? Colors.yellowLight : Colors.amber,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// حركية طيران العنصر (نجمة / جوهرة) بمسار قوسي + دوران + Glow + Trail
  Widget _buildFlyingItem({
    required String imagePath,
    required AnimationController animation,
    required Offset start,
    required Offset end,
    required Color glowColor,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = animation.value;

        // حساب المسار المنحني (Quadratic Bezier)
        final controlPoint = Offset(
          (start.dx + end.dx) / 2 + (start.dx < end.dx ? -80 : 80),
          math.min(start.dy, end.dy) - 150,
        );

        final currentDx = math.pow(1 - t, 2) * start.dx +
            2 * (1 - t) * t * controlPoint.dx +
            math.pow(t, 2) * end.dx;

        final currentDy = math.pow(1 - t, 2) * start.dy +
            2 * (1 - t) * t * controlPoint.dy +
            math.pow(t, 2) * end.dy;

        final scale = 1.2 - (t * 0.5); // الحجم يصغر تدريجياً باتجاه التولبار
        final rotation = t * math.pi * 4; // دوران حول النفس

        return Positioned(
          left: currentDx - 30,
          top: currentDy - 30,
          child: CustomPaint(
            foregroundPainter: _ParticleTrailPainter(
              progress: t,
              color: glowColor,
            ),
            child: Transform.rotate(
              angle: rotation,
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: glowColor.withOpacity(0.9),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Image.asset(imagePath, fit: BoxFit.contain),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// بنر احتفال نهاية الجزيرة
  Widget _buildCelebrationBanner() {
    return Center(
      child: AnimatedBuilder(
        animation: _celebrationController,
        builder: (context, child) {
          final pulse = 1.0 + (_celebrationController.value * 0.08);
          return Transform.scale(
            scale: pulse,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.purple, Colors.deepOrange],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.8),
                    blurRadius: 35,
                    spreadRadius: 8,
                  ),
                ],
              ),
              child: const Text(
               '🏝️ اكتملت الجزيرة! حصلت على الجوهرة 💎',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black45,
                      offset: Offset(2, 2),
                      blurRadius: 4,
                    )
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        },
      ),
    );
  }

  /// أزرار التحكم في المراحل العادية فقط (1-9)
  Widget _buildActionButtons() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 40),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton.icon(
              onPressed: widget.onReplay,
              icon: const Icon(Icons.replay),
              label: const Text('Replay'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
            ElevatedButton.icon(
              onPressed: widget.onGoToMap,
              icon: const Icon(Icons.map),
              label: const Text('Map'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
            ElevatedButton.icon(
              onPressed: widget.onNextLevel,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Continue'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
        ),
      ),
    );
  }
}

/// رسام تأثير تفتيت الصورة (Shatter Painter)
class _ShatterPainter extends CustomPainter {
  final ImageProvider imageProvider;
  final double progress;

  _ShatterPainter({required this.imageProvider, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.amber.withOpacity((1 - progress).clamp(0.0, 1.0))
      ..style = PaintingStyle.fill;

    final random = math.Random(42);
    const int count = 16;
    final pieceWidth = size.width / 4;
    final pieceHeight = size.height / 4;

    for (int i = 0; i < count; i++) {
      final x = (i % 4) * pieceWidth;
      final y = (i ~/ 4) * pieceHeight;

      final dx = (random.nextDouble() - 0.5) * 200 * progress;
      final dy = (random.nextDouble() - 0.5) * 200 * progress;

      canvas.drawImageRect(
  imageProvider as dynamic,
  Rect.fromLTWH(
    x,
    y,
    pieceWidth,
    pieceHeight,
  ),
  Rect.fromLTWH(
    x + dx,
    y + dy,
    pieceWidth,
    pieceHeight,
  ),
  paint,
);
    }
  }

  @override
  bool shouldRepaint(covariant _ShatterPainter oldDelegate) => true;
}

/// رسام ذيل الجسيمات للجواهر والنجوم الطائرة (Particle Trail)
class _ParticleTrailPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ParticleTrailPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    final random = math.Random(12);

    for (int i = 0; i < 8; i++) {
      final offsetX = (random.nextDouble() - 0.5) * 40;
      final offsetY = (random.nextDouble() - 0.5) * 40;
      final radius = random.nextDouble() * 4 + 2;

      canvas.drawCircle(
        Offset(size.width / 2 + offsetX, size.height / 2 + offsetY),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticleTrailPainter oldDelegate) => true;
}