import 'dart:async';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../managers/reward_manager.dart';
import '../models/reward_result_model.dart';

class PuzzlePieceDataModel {
  final int row;
  final int col;
  final Path path;
  final Rect sourceRect;
  final Offset originalCenter;

  const PuzzlePieceDataModel({
    required this.row,
    required this.col,
    required this.path,
    required this.sourceRect,
    required this.originalCenter,
  });
}

class _PieceAnimData {
  final double moveAngle;
  final double speedFactor;
  final double rotationOffset;

  const _PieceAnimData({
    required this.moveAngle,
    required this.speedFactor,
    required this.rotationOffset,
  });
}

class VictoryCinematicScreen extends StatefulWidget {
  final ImageProvider puzzleImage;
  final int levelNumber;
  final bool isFinalLevel;
  final GlobalKey? starTargetKey;
  final GlobalKey? gemTargetKey;
  final List<PuzzlePieceDataModel>? prebuiltPieces;
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
    required this.isFinalLevel,
    this.starTargetKey,
    this.gemTargetKey,
    this.prebuiltPieces,
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
  late AnimationController _puzzleAssembleController;
  late AnimationController _puzzleShatterController;
  late AnimationController _chestDropController;
  late AnimationController _chestOpenController;
  late AnimationController _chestFlareController;
  late AnimationController _starFlyController;
  late AnimationController _gemFlyController;
  late AnimationController _celebrationController;

  final GlobalKey _chestWidgetKey = GlobalKey();

  bool _isPuzzleShattered = false;
  bool _isChestVisible = false;
  bool _isStarFlying = false;
  bool _isGemFlying = false;
  bool _showCelebrationBanner = false;
  bool _showActionButtons = false;

  bool _isSecondChestPhase = false;
  bool _isSecondChestVisible = false;
  bool _isSecondChestOpen = false;

  bool _starRewardTriggered = false;
  bool _gemRewardTriggered = false;
  bool _sequenceStarted = false;

  Offset _starTargetOffset = Offset.zero;
  Offset _gemTargetOffset = Offset.zero;

  ui.Image? _resolvedPuzzleImage;
  ImageStream? _imageStream;
  ImageStreamListener? _imageStreamListener;

  List<PuzzlePieceDataModel> _cachedPieces = [];
  List<_PieceAnimData> _cachedPieceAnimationData = [];

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
      duration: const Duration(milliseconds: 900),
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

    if (widget.prebuiltPieces != null && widget.prebuiltPieces!.isNotEmpty) {
      _cachedPieces = widget.prebuiltPieces!;
      _initPieceAnimationData();
    }

    _loadUiImage();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_sequenceStarted) {
        _sequenceStarted = true;
        _runVictorySequence();
      }
    });
  }

  void _loadUiImage() {
    final provider = widget.puzzleImage;
    _imageStream = provider.resolve(const ImageConfiguration());
    _imageStreamListener = ImageStreamListener((info, _) {
      if (mounted) {
        setState(() {
          _resolvedPuzzleImage = info.image;
          if (_cachedPieces.isEmpty) {
            final sz = MediaQuery.of(context).size;
            final puzzleDim = math.min(sz.width * 0.75, 320.0);
            _generateSharedEdgePuzzlePieces(Size(puzzleDim, puzzleDim), 4, 4);
          }
        });
      }
    });
    _imageStream?.addListener(_imageStreamListener!);
  }

  void _generateSharedEdgePuzzlePieces(Size size, int rows, int cols) {
    final double pieceWidth = size.width / cols;
    final double pieceHeight = size.height / rows;
    
    final List<List<int>> horizontalTabs = List.generate(
      rows, 
      (_) => List.generate(cols - 1, (index) => (index + _) % 2 == 0 ? 1 : -1)
    );
    final List<List<int>> verticalTabs = List.generate(
      rows - 1, 
      (_) => List.generate(cols, (index) => (index + _) % 2 == 0 ? 1 : -1)
    );

    final List<PuzzlePieceDataModel> pieces = [];

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final double x = c * pieceWidth;
        final double y = r * pieceHeight;
        final Path path = Path();

        path.moveTo(x, y);

        if (r == 0) {
          path.lineTo(x + pieceWidth, y);
        } else {
          final int topDir = -verticalTabs[r - 1][c];
          _buildEdge(path, x, y, x + pieceWidth, y, topDir);
        }

        if (c == cols - 1) {
          path.lineTo(x + pieceWidth, y + pieceHeight);
        } else {
          final int rightDir = horizontalTabs[r][c];
          _buildEdge(path, x + pieceWidth, y, x + pieceWidth, y + pieceHeight, rightDir);
        }

        if (r == rows - 1) {
          path.lineTo(x, y + pieceHeight);
        } else {
          final int bottomDir = verticalTabs[r][c];
          _buildEdge(path, x + pieceWidth, y + pieceHeight, x, y + pieceHeight, bottomDir);
        }

        if (c == 0) {
          path.close();
        } else {
          final int leftDir = -horizontalTabs[r][c - 1];
          _buildEdge(path, x, y + pieceHeight, x, y, leftDir);
          path.close();
        }

        pieces.add(PuzzlePieceDataModel(
          row: r,
          col: c,
          path: path,
          sourceRect: Rect.fromLTWH(x, y, pieceWidth, pieceHeight),
          originalCenter: Offset(x + pieceWidth / 2, y + pieceHeight / 2),
        ));
      }
    }

    _cachedPieces = pieces;
    _initPieceAnimationData();
  }

  void _buildEdge(Path path, double x1, double y1, double x2, double y2, int direction) {
    if (direction == 0) {
      path.lineTo(x2, y2);
      return;
    }

    final double dx = x2 - x1;
    final double dy = y2 - y1;
    final double length = math.sqrt(dx * dx + dy * dy);
    final double nx = dx / length;
    final double ny = dy / length;
    final double px = -ny * direction;
    final double py = nx * direction;

    final p1 = Offset(x1 + dx * 0.35, y1 + dy * 0.35);
    final p2 = Offset(x1 + dx * 0.5 + px * length * 0.2, y1 + dy * 0.5 + py * length * 0.2);
    final p3 = Offset(x1 + dx * 0.65, y1 + dy * 0.65);

    path.lineTo(p1.dx, p1.dy);
    path.cubicTo(
      p1.dx + px * length * 0.1, p1.dy + py * length * 0.1,
      p2.dx - nx * length * 0.1, p2.dy - ny * length * 0.1,
      p2.dx, p2.dy,
    );
    path.cubicTo(
      p2.dx + nx * length * 0.1, p2.dy + ny * length * 0.1,
      p3.dx + px * length * 0.1, p3.dy + py * length * 0.1,
      p3.dx, p3.dy,
    );
    path.lineTo(x2, y2);
  }

  void _initPieceAnimationData() {
    final random = math.Random(42);
    _cachedPieceAnimationData = _cachedPieces.map((piece) {
      final double moveAngle = random.nextDouble() * math.pi * 2;
      final double speedFactor = 0.7 + random.nextDouble() * 0.6;
      final double rotationOffset = (random.nextDouble() - 0.5) * 2.0;
      return _PieceAnimData(
        moveAngle: moveAngle,
        speedFactor: speedFactor,
        rotationOffset: rotationOffset,
      );
    }).toList();
  }

  @override
  void dispose() {
    if (_imageStream != null && _imageStreamListener != null) {
      _imageStream!.removeListener(_imageStreamListener!);
    }
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

  void _calculateTargetPositions() {
    final Size screenSize = MediaQuery.of(context).size;

    if (widget.starTargetKey != null) {
      _starTargetOffset = _getOffsetFromKey(widget.starTargetKey!) ??
          Offset(screenSize.width * 0.2, 50);
    } else {
      _starTargetOffset = Offset(screenSize.width * 0.2, 50);
    }
        
    if (widget.gemTargetKey != null) {
      _gemTargetOffset = _getOffsetFromKey(widget.gemTargetKey!) ??
          Offset(screenSize.width * 0.8, 50);
    } else {
      _gemTargetOffset = Offset(screenSize.width * 0.8, 50);
    }
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

  Offset _getChestCenterOffset() {
    final RenderBox? renderBox =
        _chestWidgetKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      final size = renderBox.size;
      return Offset(position.dx + size.width / 2, position.dy + size.height / 2);
    }
    final Size screenSize = MediaQuery.of(context).size;
    return Offset(screenSize.width / 2, screenSize.height / 2);
  }

  Future<void> _runVictorySequence() async {
    await _puzzleAssembleController.forward();
    await Future.delayed(const Duration(milliseconds: 200));

    if (!mounted) return;
    setState(() => _isPuzzleShattered = true);
    await _puzzleShatterController.forward();

    if (!mounted) return;
    setState(() => _isChestVisible = true);
    await _chestDropController.forward();
    
    await _chestOpenController.forward();
    await _chestFlareController.forward();

    _calculateTargetPositions();

    if (!mounted) return;
    setState(() => _isStarFlying = true);
    await _starFlyController.forward();
    
    if (!mounted) return;
    setState(() => _isStarFlying = false);

    if (!_starRewardTriggered) {
      _starRewardTriggered = true;
      widget.onStarEarned?.call();
      RewardManager.addReward(
        const RewardResultModel(
          stars: 1,
        ),
      );
    }

    if (!_effectiveIsFinalLevel) {
      if (mounted) {
        setState(() {
          _showCelebrationBanner = true;
          _showActionButtons = true;
        });
        _celebrationController.repeat(reverse: true);
      }
      widget.onFinished?.call();
    } else {
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;
      setState(() {
        _isSecondChestPhase = true;
        _isChestVisible = false;
        _isSecondChestVisible = true;
        _isSecondChestOpen = false;
      });

      _chestDropController.reset();
      _chestOpenController.reset();
      _chestFlareController.reset();
      _gemFlyController.reset();

      await _chestDropController.forward();
      await _chestOpenController.forward();

      if (!mounted) return;
      setState(() {
        _isSecondChestOpen = true;
      });

      await _chestFlareController.forward();

      _calculateTargetPositions();

      if (!mounted) return;
      setState(() {
        _isGemFlying = true;
      });

      await _gemFlyController.forward();

      if (!mounted) return;
      setState(() {
        _isGemFlying = false;
      });

      if (!_gemRewardTriggered) {
        _gemRewardTriggered = true;
        widget.onGemEarned?.call();
        RewardManager.addReward(
          const RewardResultModel(
            gems: 1,
          ),
        );
      }

      if (!mounted) return;
      setState(() {
        _showCelebrationBanner = true;
        _showActionButtons = true;
      });
      _celebrationController.repeat(reverse: true);

      widget.onFinished?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final puzzleDim = math.min(screenSize.width * 0.75, 320.0);

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.75),
      body: Stack(
        children: [
          if (!_isPuzzleShattered) _buildAssemblingPuzzle(puzzleDim),

          if (_isPuzzleShattered)
            _buildShatteringPuzzle(puzzleDim),

          if (_isChestVisible || _isSecondChestVisible) _buildChestWidget(),

          if (_isStarFlying)
            _buildFlyingItem(
              imagePath: 'assets/images/rewards/Star_gold.png',
              animation: _starFlyController,
              start: _getChestCenterOffset(),
              end: _starTargetOffset,
              glowColor: Colors.amber,
            ),

          if (_isGemFlying)
            _buildFlyingItem(
              imagePath: 'assets/images/rewards/gem.png',
              animation: _gemFlyController,
              start: _getChestCenterOffset(),
              end: _gemTargetOffset,
              glowColor: Colors.cyanAccent,
            ),

          if (_showCelebrationBanner) _buildCelebrationBanner(),

          if (_showActionButtons) _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildAssemblingPuzzle(double puzzleDim) {
    return Center(
      child: ScaleTransition(
        scale: CurvedAnimation(
          parent: _puzzleAssembleController,
          curve: Curves.elasticOut,
        ),
        child: FadeTransition(
          opacity: _puzzleAssembleController,
          child: Container(
            width: puzzleDim,
            height: puzzleDim,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amberAccent, width: 4),
              boxShadow: const [
                BoxShadow(
                  color: Colors.amberAccent,
                  blurRadius: 25,
                  spreadRadius: 5,
                )
              ],
              image: DecorationImage(
                image: widget.puzzleImage,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShatteringPuzzle(double puzzleDim) {
    if (_resolvedPuzzleImage == null || _cachedPieces.isEmpty) {
      return const SizedBox.shrink();
    }
    return AnimatedBuilder(
      animation: _puzzleShatterController,
      builder: (context, child) {
        final progress = _puzzleShatterController.value;
        return Center(
          child: CustomPaint(
            size: Size(puzzleDim, puzzleDim),
            painter: AdvancedShatterPainter(
              image: _resolvedPuzzleImage!,
              progress: progress,
              pieces: _cachedPieces,
              pieceAnimationData: _cachedPieceAnimationData,
            ),
          ),
        );
      },
    );
  }

  Widget _buildChestWidget() {
    return Center(
      child: AnimatedBuilder(
        animation: Listenable.merge(
            [_chestDropController, _chestOpenController, _chestFlareController]),
        builder: (context, child) {
          final dropValue = CurvedAnimation(
            parent: _chestDropController,
            curve: Curves.elasticOut,
          ).value;

          final flareValue = _chestFlareController.value;
          final isOpen = _isSecondChestPhase
              ? (_isSecondChestOpen || _chestOpenController.value > 0.5)
              : (_chestOpenController.value > 0.5);

          double shakeOffset = 0.0;
          if (_chestOpenController.isAnimating || _chestOpenController.value > 0) {
            shakeOffset = math.sin(_chestOpenController.value * math.pi * 8) * 3.0 * (1.0 - _chestOpenController.value);
          }

          return Transform.translate(
            offset: Offset(shakeOffset, (1.0 - dropValue) * -400),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 200 + (flareValue * 140),
                  height: 200 + (flareValue * 140),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        (_isSecondChestPhase ? Colors.cyan : Colors.amber)
                            .withOpacity(0.9 * (0.5 + flareValue / 2)),
                        (_isSecondChestPhase ? Colors.blue : Colors.orange)
                            .withOpacity(0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                if (flareValue > 0)
                  CustomPaint(
                    size: const Size(200, 200),
                    painter: ChestLightBurstPainter(
                      progress: flareValue,
                      color: _isSecondChestPhase ? Colors.cyanAccent : Colors.amberAccent,
                    ),
                  ),
                if (_isSecondChestPhase)
                  CustomPaint(
                    size: const Size(200, 200),
                    painter: ParticleBurstPainter(
                      progress: flareValue,
                      isGem: true,
                    ),
                  )
                else
                  CustomPaint(
                    size: const Size(200, 200),
                    painter: ParticleBurstPainter(
                      progress: flareValue,
                      isGem: false,
                    ),
                  ),
                Image(
                  key: _chestWidgetKey,
                  image: isOpen
                      ? const AssetImage('assets/images/rewards/reward_chest_open.png')
                      : const AssetImage('assets/images/rewards/reward_chest_closed.png'),
                  width: 130,
                  height: 130,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

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
        final t = Curves.easeInOutCubic.transform(animation.value);

        final controlPoint = Offset(
          (start.dx + end.dx) / 2 + (start.dx < end.dx ? -100 : 100),
          math.min(start.dy, end.dy) - 180,
        );

        final currentDx = math.pow(1 - t, 2) * start.dx +
            2 * (1 - t) * t * controlPoint.dx +
            math.pow(t, 2) * end.dx;

        final currentDy = math.pow(1 - t, 2) * start.dy +
            2 * (1 - t) * t * controlPoint.dy +
            math.pow(t, 2) * end.dy;

        final scale = 1.3 - (t * 0.4) + (math.sin(t * math.pi) * 0.2);
        final rotation = t * math.pi * 4;

        return Positioned(
          left: currentDx - 30,
          top: currentDy - 30,
          child: CustomPaint(
            foregroundPainter: RealisticParticleTrailPainter(
              progress: animation.value,
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
                        blurRadius: 25,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: Image(
                    image: AssetImage(imagePath),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCelebrationBanner() {
    return Positioned(
      top: 80,
      left: 0,
      right: 0,
      child: Center(
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
                child: Text(
                  _effectiveIsFinalLevel
                      ? '🏝️ Island Completed! Gem Acquired 💎'
                      : '🎉 Level Completed! Star Acquired ⭐',
                  style: const TextStyle(
                    fontSize: 22,
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
      ),
    );
  }

  Widget _buildActionButtons() {
    return Positioned(
      bottom: 50,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: () => widget.onReplay?.call(),
            icon: const Icon(Icons.replay),
            label: const Text('إعادة اللعب'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          ),
          if (!_effectiveIsFinalLevel) ...[
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () => widget.onNextLevel?.call(),
              icon: const Icon(Icons.skip_next),
              label: const Text('المرحلة التالية'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
          ],
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: () => widget.onGoToMap?.call(),
            icon: const Icon(Icons.map),
            label: const Text('الخريطة'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          ),
        ],
      ),
    );
  }
}

class AdvancedShatterPainter extends CustomPainter {
  final ui.Image image;
  final double progress;
  final List<PuzzlePieceDataModel> pieces;
  final List<_PieceAnimData> pieceAnimationData;

  AdvancedShatterPainter({
    required this.image,
    required this.progress,
    required this.pieces,
    required this.pieceAnimationData,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double widgetWidth = size.width;
    final double widgetHeight = size.height;

    final double scaleX = image.width / widgetWidth;
    final double scaleY = image.height / widgetHeight;

    for (int i = 0; i < pieces.length; i++) {
      final piece = pieces[i];
      final animData = pieceAnimationData[i];

      final double moveAngle = animData.moveAngle;
      final double speedFactor = animData.speedFactor;
      final double rotOffset = animData.rotationOffset;

      final double currentRotation = rotOffset * progress * math.pi * 0.75;
      final double moveDist = 180.0 * progress * speedFactor;
      final double dx = math.cos(moveAngle) * moveDist;
      final double dy = math.sin(moveAngle) * moveDist;

      final Offset center = piece.originalCenter;
      final double scale3D = 1.0 + (progress * 0.15);
      final double opacity = progress > 0.7 ? (1.0 - (progress - 0.7) / 0.3).clamp(0.0, 1.0) : 1.0;

      canvas.save();

      canvas.translate(center.dx + dx, center.dy + dy);
      canvas.scale(scale3D);
      canvas.rotate(currentRotation);
      canvas.translate(-center.dx, -center.dy);

      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.35 * opacity)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0);
      canvas.drawPath(piece.path, shadowPaint);

      canvas.clipPath(piece.path);

      final Rect srcRect = piece.sourceRect;
      final ui.Rect imageSrcRect = ui.Rect.fromLTWH(
        srcRect.left * scaleX,
        srcRect.top * scaleY,
        srcRect.width * scaleX,
        srcRect.height * scaleY,
      );

      canvas.drawImageRect(
        image,
        imageSrcRect,
        srcRect,
        Paint()..color = Colors.white.withOpacity(opacity),
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant AdvancedShatterPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.image != image;
  }
}

class ChestLightBurstPainter extends CustomPainter {
  final double progress;
  final Color color;

  ChestLightBurstPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity((1.0 - progress).clamp(0.0, 1.0))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = progress * 90.0;
    const int rayCount = 10;

    for (int i = 0; i < rayCount; i++) {
      final angle = (i * 2 * math.pi / rayCount) + (progress * 0.5);
      final outerPoint = Offset(
        center.dx + math.cos(angle) * (radius + 25),
        center.dy + math.sin(angle) * (radius + 25),
      );
      final innerPoint = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      canvas.drawLine(innerPoint, outerPoint, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ChestLightBurstPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

class ParticleBurstPainter extends CustomPainter {
  final double progress;
  final bool isGem;

  ParticleBurstPainter({required this.progress, required this.isGem});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isGem ? Colors.cyanAccent : Colors.amberAccent)
          .withOpacity((1.0 - progress).clamp(0.0, 1.0))
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final random = math.Random(77);

    for (int i = 0; i < 14; i++) {
      final angle = random.nextDouble() * math.pi * 2;
      final distance = progress * (60.0 + random.nextDouble() * 50.0);
      final particleRadius = (random.nextDouble() * 4 + 2) * (1.0 - progress * 0.5);

      final p = Offset(
        center.dx + math.cos(angle) * distance,
        center.dy + math.sin(angle) * distance,
      );

      canvas.drawCircle(p, particleRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticleBurstPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.isGem != isGem;
}

class RealisticParticleTrailPainter extends CustomPainter {
  final double progress;
  final Color color;

  RealisticParticleTrailPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity((1.0 - progress).clamp(0.0, 1.0))
      ..style = PaintingStyle.fill;

    final random = math.Random(123);

    for (int i = 0; i < 12; i++) {
      final offsetX = (random.nextDouble() - 0.5) * 70 * progress;
      final offsetY = (random.nextDouble() - 0.5) * 70 * progress;
      final radius = (random.nextDouble() * 5 + 2) * (1.0 - progress);

      canvas.drawCircle(
        Offset(size.width / 2 - offsetX, size.height / 2 - offsetY),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant RealisticParticleTrailPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
