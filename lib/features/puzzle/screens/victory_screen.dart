import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'island_screen.dart';
import 'world_map_screen.dart';
import '../models/puzzle_model.dart';
import '../managers/reward_manager.dart';
import '../services/reward_ad_service.dart';

// ============================================================================
// victory_screen.dart
//
// Puzzle World cinematic victory sequence.
// Contains:
// - MagicParticles
// - Puzzle fragment shatter effect (image-based, ~100 random fragments)
// - VictoryCinematicScreen
// - VictoryFinalScreen
//
// Pure Flutter, no external packages.
// ============================================================================

// ============================================================================
// SECTION 1 — Magic particles
// ============================================================================

class MagicParticles extends StatelessWidget {
  const MagicParticles({
    super.key,
    required this.origin,
    required this.progress,
    this.count = 26,
    this.spread = 140,
    this.colors = const [
      Color(0xFFFFE9A8),
      Color(0xFFFFD54F),
      Color(0xFFFFFFFF),
      Color(0xFF9BE8FF),
    ],
    this.seed = 1,
    this.minSize = 2.5,
    this.maxSize = 6.5,
  });

  final Offset origin;
  final double progress;
  final int count;
  final double spread;
  final List<Color> colors;
  final int seed;
  final double minSize;
  final double maxSize;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: _ParticlePainter(
          origin: origin,
          progress: progress.clamp(0.0, 1.0),
          count: count,
          spread: spread,
          colors: colors,
          seed: seed,
          minSize: minSize,
          maxSize: maxSize,
        ),
      ),
    );
  }
}

class _Particle {
  _Particle({
    required this.angle,
    required this.distanceFactor,
    required this.size,
    required this.color,
    required this.delay,
    required this.twinklePhase,
  });

  final double angle;
  final double distanceFactor;
  final double size;
  final Color color;
  final double delay;
  final double twinklePhase;
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter({
    required this.origin,
    required this.progress,
    required this.count,
    required this.spread,
    required this.colors,
    required this.seed,
    required this.minSize,
    required this.maxSize,
  }) : particles = _build(count, colors, seed, minSize, maxSize);

  final Offset origin;
  final double progress;
  final int count;
  final double spread;
  final List<Color> colors;
  final int seed;
  final double minSize;
  final double maxSize;

  final List<_Particle> particles;

  static List<_Particle> _build(
    int count,
    List<Color> colors,
    int seed,
    double minSize,
    double maxSize,
  ) {
    final random = math.Random(seed);

    return List.generate(count, (i) {
      return _Particle(
        angle: random.nextDouble() * math.pi * 2,
        distanceFactor: 0.4 + random.nextDouble() * 0.6,
        size: minSize + random.nextDouble() * (maxSize - minSize),
        color: colors[random.nextInt(colors.length)],
        delay: random.nextDouble() * 0.35,
        twinklePhase: random.nextDouble() * math.pi * 2,
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      var local = (progress - particle.delay) / (1 - particle.delay);

      if (local <= 0) {
        continue;
      }

      local = local.clamp(0.0, 1.0);

      final eased = Curves.easeOut.transform(local);

      final distance = spread * particle.distanceFactor * eased;

      final position = origin +
          Offset(
            math.cos(particle.angle) * distance,
            math.sin(particle.angle) * distance,
          );

      final twinkle =
          0.65 + 0.35 * math.sin(particle.twinklePhase + progress * 14);

      final opacity = (1 - local) * twinkle;

      final paint = Paint()
        ..color = particle.color.withOpacity(opacity.clamp(0.0, 1.0));

      canvas.drawCircle(position, particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.origin != origin;
  }
}

// ============================================================================
// SECTION 2 — Puzzle fragment shatter system (image-based, no puzzle engine)
// ============================================================================

class PuzzleFragment {
  PuzzleFragment({
    required this.srcRect,
    required this.restRect,
    required this.path,
    required this.direction,
    required this.travel,
    required this.spin,
    required this.delay,
    required this.gravity,
    required this.speedFactor,
  });

  final Rect srcRect;
  final Rect restRect;
  final Path path;
  final Offset direction;
  final double travel;
  final double spin;
  final double delay;
  final double gravity;
  final double speedFactor;
}

/// Builds a set of randomized, puzzle-like fragments cut directly out of
/// [frameRect] / [imageSize]. This intentionally does NOT use the real
/// gameplay puzzle engine (puzzle_generator / puzzle_shape_builder) — the
/// cinematic shatter only needs to look like a shattering puzzle, it does
/// not need to reproduce the exact gameplay piece shapes.
List<PuzzleFragment> buildPuzzleFragments({
  required Rect frameRect,
  required Size imageSize,
  int cols = 10,
  int rows = 10,
  int seed = 7,
}) {
  final random = math.Random(seed);
  final fragments = <PuzzleFragment>[];

  final cellWidth = frameRect.width / cols;
  final cellHeight = frameRect.height / rows;

  final sourceWidth = imageSize.width / cols;
  final sourceHeight = imageSize.height / rows;

  final center = frameRect.center;

  for (int row = 0; row < rows; row++) {
    for (int col = 0; col < cols; col++) {
      final restRect = Rect.fromLTWH(
        frameRect.left + col * cellWidth,
        frameRect.top + row * cellHeight,
        cellWidth,
        cellHeight,
      );

      final sourceRect = Rect.fromLTWH(
        col * sourceWidth,
        row * sourceHeight,
        sourceWidth,
        sourceHeight,
      );

      final outward = restRect.center - center;

      final direction = outward.distance < 1
          ? Offset(
              random.nextDouble() * 2 - 1,
              random.nextDouble() * 2 - 1,
            )
          : outward / outward.distance;

      fragments.add(
        PuzzleFragment(
          srcRect: sourceRect,
          restRect: restRect,
          path: _jaggedFragmentPath(restRect, random),
          direction: direction,
          travel: 110 + random.nextDouble() * 220,
          spin: (random.nextDouble() - 0.5) * math.pi * 3.2,
          delay: random.nextDouble() * 0.55,
          gravity: 40 + random.nextDouble() * 90,
          speedFactor: 0.75 + random.nextDouble() * 0.7,
        ),
      );
    }
  }

  return fragments;
}

/// Produces an irregular quadrilateral inside [rect] by pulling each corner
/// toward the rect's center by a random amount. This keeps every fragment's
/// artwork fully inside its own source cell (so no re-sampling outside the
/// image is required) while still giving every piece a random, jagged,
/// puzzle-like silhouette.
Path _jaggedFragmentPath(Rect rect, math.Random random) {
  final center = rect.center;
  const maxPull = 0.24;

  Offset pull(Offset corner) {
    final factor = random.nextDouble() * maxPull;
    return Offset.lerp(corner, center, factor)!;
  }

  final p1 = pull(rect.topLeft);
  final p2 = pull(rect.topRight);
  final p3 = pull(rect.bottomRight);
  final p4 = pull(rect.bottomLeft);

  // Small extra mid-edge notches to break up the straight edges a bit more,
  // approximating a puzzle-piece silhouette without needing real tabs.
  final midTop = Offset.lerp(p1, p2, 0.5)! +
      Offset(0, (random.nextDouble() - 0.5) * rect.height * 0.1);
  final midRight = Offset.lerp(p2, p3, 0.5)! +
      Offset((random.nextDouble() - 0.5) * rect.width * 0.1, 0);
  final midBottom = Offset.lerp(p3, p4, 0.5)! +
      Offset(0, (random.nextDouble() - 0.5) * rect.height * 0.1);
  final midLeft = Offset.lerp(p4, p1, 0.5)! +
      Offset((random.nextDouble() - 0.5) * rect.width * 0.1, 0);

  return Path()
    ..moveTo(p1.dx, p1.dy)
    ..lineTo(midTop.dx, midTop.dy)
    ..lineTo(p2.dx, p2.dy)
    ..lineTo(midRight.dx, midRight.dy)
    ..lineTo(p3.dx, p3.dy)
    ..lineTo(midBottom.dx, midBottom.dy)
    ..lineTo(p4.dx, p4.dy)
    ..lineTo(midLeft.dx, midLeft.dy)
    ..close();
}

class FragmentShatterPainter extends CustomPainter {
  FragmentShatterPainter({
    required this.image,
    required this.fragments,
    required this.progress,
  });

  final ui.Image image;
  final List<PuzzleFragment> fragments;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    for (final fragment in fragments) {
      var local = (progress - fragment.delay) / (1 - fragment.delay);

      if (local <= 0) {
        _drawFragment(canvas, fragment, Offset.zero, 0, 1);
        continue;
      }

      local = local.clamp(0.0, 1.0);

      final eased = Curves.easeIn.transform(local);

      final outward = fragment.direction *
          fragment.travel *
          fragment.speedFactor *
          eased;

      final fall = fragment.gravity * eased * eased;

      final offset = outward + Offset(0, fall);

      final rotation = fragment.spin * eased;

      final opacity = 1 - local;

      if (opacity <= 0.01) {
        continue;
      }

      _drawFragment(canvas, fragment, offset, rotation, opacity);
    }
  }

  void _drawFragment(
    Canvas canvas,
    PuzzleFragment fragment,
    Offset offset,
    double rotation,
    double opacity,
  ) {
    final center = fragment.restRect.center + offset;

    canvas.save();

    canvas.translate(offset.dx, offset.dy);
    canvas.translate(center.dx - offset.dx, center.dy - offset.dy);
    canvas.rotate(rotation);
    canvas.translate(
      -(center.dx - offset.dx),
      -(center.dy - offset.dy),
    );

    canvas.clipPath(fragment.path);

    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..filterQuality = FilterQuality.high;

    canvas.drawImageRect(
      image,
      fragment.srcRect,
      fragment.restRect,
      paint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant FragmentShatterPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.image != image;
  }
}

// ============================================================================
// SECTION 3 — Victory cinematic
// ============================================================================

class VictoryCinematicScreen extends StatefulWidget {
  const VictoryCinematicScreen({
    super.key,
    required this.puzzleImage,
    required this.levelNumber,
    required this.island,
    required this.onFinished,
    this.isFinalLevel = false,
    this.starTargetKey,
    this.gemTargetKey,
    this.onStarEarned,
    this.onGemEarned,
    this.totalDuration,
  });

  final ImageProvider puzzleImage;
  final int levelNumber;

  /// The island the completed level belongs to — carried through so the
  /// caller can forward it to VictoryFinalScreen once onFinished fires.
  final PuzzleModel island;

  /// True when this is the LAST level of the island — triggers the extended
  /// two-stage chest sequence (star, then a second dramatic opening for the
  /// gem) instead of the normal single star reward.
  final bool isFinalLevel;

  final GlobalKey? starTargetKey;
  final GlobalKey? gemTargetKey;

  final VoidCallback? onStarEarned;
  final VoidCallback? onGemEarned;

  final VoidCallback onFinished;

  /// Optional override. Defaults to 8s for normal levels and 10s for the
  /// final level of an island (to fit the extended chest sequence).
  final Duration? totalDuration;

  @override
  State<VictoryCinematicScreen> createState() =>
      _VictoryCinematicScreenState();
}

class _VictoryCinematicScreenState extends State<VictoryCinematicScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey _stageKey = GlobalKey();

  late final AnimationController _controller;
  late final Duration _effectiveDuration = widget.totalDuration ??
      Duration(seconds: widget.isFinalLevel ? 10 : 8);

  ui.Image? _puzzleImage;
  List<PuzzleFragment>? _fragments;

  Offset? _starTarget;
  Offset? _gemTarget;

  bool _starLanded = false;
  bool _gemLanded = false;

  // ---- Timeline (fractions of total duration) --------------------------
  static const double revealEnd = 0.10;
  static const double admireEnd = 0.27;
  static const double explodeEnd = 0.44;
  static const double chestDropEnd = 0.51;
  static const double chestGlowEnd = 0.57;
  static const double chestOpenEnd = 0.64;

  double get starEnd => widget.isFinalLevel ? 0.78 : 0.90;

  // Second chest cycle — island-final levels only.
  double get chestCloseEnd => 0.84;
  double get chestShakeEnd => 0.90;
  double get chestReopenEnd => 0.94;
  double get gemEnd => 0.985;

  double get fadeStart => widget.isFinalLevel ? 0.99 : 0.95;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: _effectiveDuration,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        widget.onFinished();
      }
    });

    _loadPuzzleImage();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _resolveTargets();

      _controller.forward();
    });
  }

  Future<void> _loadPuzzleImage() async {
    final completer = Completer<ui.Image>();

    final stream = widget.puzzleImage.resolve(const ImageConfiguration());

    late ImageStreamListener listener;

    listener = ImageStreamListener(
      (info, _) {
        completer.complete(info.image);
        stream.removeListener(listener);
      },
      onError: (error, stack) {
        if (!completer.isCompleted) {
          completer.completeError(error);
        }
        stream.removeListener(listener);
      },
    );

    stream.addListener(listener);

    try {
      final image = await completer.future;

      if (!mounted) return;

      setState(() {
        _puzzleImage = image;
      });
    } catch (_) {}
  }

  void _resolveTargets() {
    _starTarget = _findTarget(widget.starTargetKey);
    _gemTarget = _findTarget(widget.gemTargetKey);
  }

  Offset? _findTarget(GlobalKey? key) {
    if (key == null) {
      return null;
    }

    final stage = _stageKey.currentContext?.findRenderObject() as RenderBox?;

    final target = key.currentContext?.findRenderObject() as RenderBox?;

    if (stage == null || target == null) {
      return null;
    }

    final global = target.localToGlobal(target.size.center(Offset.zero));

    return stage.globalToLocal(global);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _phase(double start, double end, double value) {
    if (end <= start) {
      return value >= start ? 1 : 0;
    }

    return ((value - start) / (end - start)).clamp(0.0, 1.0);
  }

  /// How "open" the chest visual should look at time [t]. For normal levels
  /// this simply ramps from 0 to 1 once and stays there. For island-final
  /// levels it ramps up, closes again, shakes, then ramps up a second time
  /// for the dramatic gem reveal.
  double _chestOpenAmount(double t) {
    final firstOpen = _phase(chestGlowEnd, chestOpenEnd, t);

    if (!widget.isFinalLevel) {
      return firstOpen;
    }

    if (t <= starEnd) {
      return firstOpen;
    }

    final closing = _phase(starEnd, chestCloseEnd, t);
    final afterClose = (1 - closing).clamp(0.0, 1.0);

    if (t <= chestShakeEnd) {
      return afterClose;
    }

    final reopening = _phase(chestShakeEnd, chestReopenEnd, t);
    return reopening.clamp(0.0, 1.0);
  }

  /// Envelope (0..1) describing the "magical energy building" shake/glow
  /// pulse that happens between the two chest openings on island-final
  /// levels.
  double _chestBuildupEnvelope(double t) {
    if (!widget.isFinalLevel) return 0;
    if (t < chestCloseEnd || t > chestShakeEnd) return 0;
    return math.sin(_phase(chestCloseEnd, chestShakeEnd, t) * math.pi);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final shortest = math.min(size.width, size.height);

    final stageSize = shortest.clamp(280.0, 640.0) * 0.60;

    final center = Offset(
      size.width / 2,
      size.height / 2 - stageSize * 0.05,
    );

    return Material(
      color: Colors.transparent,
      child: Container(
        key: _stageKey,
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            radius: 1.1,
            colors: [
              Color(0xff22307a),
              Color(0xff1B2A63),
              Color(0xff05081a),
            ],
          ),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final t = _controller.value;

            return Stack(
              children: [
                _buildAmbientGlow(t),
                _buildPuzzleFrame(t, center, stageSize),
                _buildShatter(t, center, stageSize),
                _buildChestGlow(t, center, stageSize),
                _buildChest(t, center, stageSize),
                _buildStar(t, center),
                if (widget.isFinalLevel) _buildGem(t, center),
                _buildFade(t),
              ],
            );
          },
        ),
      ),
    );
  }

  // ---- Ambient background -----------------------------------------------

  Widget _buildAmbientGlow(double t) {
    final pulse = 0.55 + 0.25 * math.sin(t * math.pi * 6);

    return Positioned.fill(
      child: IgnorePointer(
        child: Opacity(
          opacity: pulse.clamp(0.0, 1.0),
          child: const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                radius: 0.9,
                colors: [
                  Color(0x33FFD54F),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---- Puzzle reveal / admire --------------------------------------------

  Widget _buildPuzzleFrame(double t, Offset center, double size) {
    if (t >= explodeEnd) {
      return const SizedBox.shrink();
    }

    final grow = _phase(0, revealEnd, t);
    final disappear = _phase(admireEnd, explodeEnd, t);

    final scale = 0.35 + Curves.easeOutBack.transform(grow) * 0.65;

    final opacity = disappear > 0 ? 1 - disappear : grow;

    // Gentle floating + glow pulse while the player admires the completed
    // puzzle.
    final admireProgress = _phase(revealEnd, admireEnd, t);
    final float = math.sin(admireProgress * math.pi * 3) * 6;
    final glowPulse = 0.5 + 0.5 * math.sin(admireProgress * math.pi * 4);

    return Positioned(
      left: center.dx - size / 2,
      top: center.dy - size / 2 + float,
      width: size,
      height: size,
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Transform.scale(
          scale: scale,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: const Border.fromBorderSide(
                BorderSide(color: Color(0xffffd54f), width: 4),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xffffd54f)
                      .withOpacity(0.35 + glowPulse * 0.25),
                  blurRadius: 40 + glowPulse * 20,
                  spreadRadius: glowPulse * 4,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: _puzzleImage == null
                  ? Image(image: widget.puzzleImage, fit: BoxFit.cover)
                  : RawImage(image: _puzzleImage, fit: BoxFit.cover),
            ),
          ),
        ),
      ),
    );
  }

  // ---- Explosion ----------------------------------------------------------

  Widget _buildShatter(double t, Offset center, double size) {
    if (_puzzleImage == null || t < admireEnd || t > explodeEnd) {
      return const SizedBox.shrink();
    }

    final progress = _phase(admireEnd, explodeEnd, t);

    _fragments ??= buildPuzzleFragments(
      frameRect: Rect.fromCenter(center: center, width: size, height: size),
      imageSize: Size(
        _puzzleImage!.width.toDouble(),
        _puzzleImage!.height.toDouble(),
      ),
      cols: 6,
      rows: 5,
    );

    return Positioned.fill(
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: FragmentShatterPainter(
                image: _puzzleImage!,
                fragments: _fragments!,
                progress: progress,
              ),
            ),
          ),
          Positioned.fill(
            child: MagicParticles(
              origin: center,
              progress: progress,
              count: 60,
              spread: size * 1.1,
              seed: 3,
            ),
          ),
        ],
      ),
    );
  }

  // ---- Chest ---------------------------------------------------------------

  Widget _buildChestGlow(double t, Offset center, double size) {
    if (t < explodeEnd) {
      return const SizedBox.shrink();
    }

    final open = _phase(chestGlowEnd, chestOpenEnd, t);
    final buildup = _chestBuildupEnvelope(t);

    final fade = 1 - _phase(starEnd, 1, t.clamp(0.0, chestCloseEnd));

    final opacity = (math.max(open, buildup) * fade).clamp(0.0, 1.0);

    return Positioned.fill(
      child: Opacity(
        opacity: opacity,
        child: Center(
          child: Container(
            width: size * (0.9 + buildup * 0.25),
            height: size * (0.9 + buildup * 0.25),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  buildup > 0
                      ? const Color(0xffbfe4ff)
                      : const Color(0xfffff3c4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChest(double t, Offset center, double size) {
    if (t < explodeEnd) {
      return const SizedBox.shrink();
    }

    final drop = _phase(explodeEnd, chestDropEnd, t);
    final open = _chestOpenAmount(t);
    final buildup = _chestBuildupEnvelope(t);

    final chestSize = size * 0.62;

    // Drops in from above with a bounce landing.
    final bounceCurve = Curves.bounceOut.transform(drop);
    final startY = center.dy - chestSize * 1.8;
    final restY = center.dy;
    final posY = ui.lerpDouble(startY, restY, bounceCurve)!;

    // Subtle shake while magical energy is building for the second opening.
    final shake = buildup > 0
        ? math.sin(t * 140) * 4 * buildup
        : 0.0;

    final scale = drop < 1
        ? Curves.easeOutBack.transform(drop).clamp(0.0, 1.2)
        : 1.0;

    return Positioned(
      left: center.dx - chestSize / 2 + shake,
      top: posY - chestSize / 2,
      width: chestSize,
      height: chestSize,
      child: Transform.scale(
        scale: scale <= 0 ? 0.01 : scale,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: (1 - open).clamp(0.0, 1.0),
              child: Image.asset(
                'assets/images/rewards/reward_chest_closed.png',
                fit: BoxFit.contain,
              ),
            ),
            Opacity(
              opacity: open.clamp(0.0, 1.0),
              child: Image.asset(
                'assets/images/rewards/reward_chest_open.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- Star ------------------------------------------------------------

  Offset _arcPosition(Offset from, Offset to, double progress) {
    final eased = Curves.easeInOutCubic.transform(progress);

    return Offset.lerp(from, to, eased)! +
        Offset(0, -math.sin(progress * math.pi) * 90);
  }

  Widget _buildStar(double t, Offset chest) {
    if (t < chestOpenEnd) {
      return const SizedBox.shrink();
    }

    final progress = _phase(chestOpenEnd, starEnd, t);

    if (progress >= 1) {
      if (!_starLanded) {
        _starLanded = true;

        // The star reward is only granted once the flying star has fully
        // reached the toolbar target — never before.
        RewardManager.addStar();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            widget.onStarEarned?.call();
          }
        });
      }

      return const SizedBox.shrink();
    }

    final target = _starTarget ?? chest;
    final position = _arcPosition(chest, target, progress);
    final spin = progress * math.pi * 6;

    return Stack(
      children: [
        MagicParticles(
          origin: position,
          progress: 1 - (1 - progress) * (1 - progress),
          count: 14,
          spread: 46,
          seed: 5,
          colors: const [
            Color(0xFFFFE9A8),
            Color(0xFFFFD54F),
          ],
        ),
        Positioned(
          left: position.dx - 28,
          top: position.dy - 28,
          child: Transform.rotate(
            angle: spin,
            child: Image.asset(
              'assets/images/rewards/Star_gold.png',
              width: 56,
              height: 56,
            ),
          ),
        ),
      ],
    );
  }

  // ---- Gem (island-final levels only) ------------------------------------

  Widget _buildGem(double t, Offset chest) {
    if (t < chestReopenEnd) {
      return const SizedBox.shrink();
    }

    final progress = _phase(chestReopenEnd, gemEnd, t);

    if (progress >= 1) {
      if (!_gemLanded) {
        _gemLanded = true;

        // The gem reward is only granted once the flying gem has fully
        // reached the toolbar target — never before.
        RewardManager.addGem();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            widget.onGemEarned?.call();
          }
        });
      }

      return const SizedBox.shrink();
    }

    final target = _gemTarget ?? chest;
    final position = _arcPosition(chest, target, progress);
    final spin = progress * math.pi * 8;

    return Stack(
      children: [
        MagicParticles(
          origin: position,
          progress: 1 - (1 - progress) * (1 - progress),
          count: 16,
          spread: 50,
          seed: 9,
          colors: const [
            Color(0xFF9BE8FF),
            Color(0xFF5AC8FA),
            Colors.white,
          ],
        ),
        Positioned(
          left: position.dx - 26,
          top: position.dy - 26,
          child: Transform.rotate(
            angle: spin,
            child: Image.asset(
              'assets/images/rewards/gem.png',
              width: 52,
              height: 52,
            ),
          ),
        ),
      ],
    );
  }

  // ---- Fade to final screen ----------------------------------------------

  Widget _buildFade(double t) {
    final value = _phase(fadeStart, 1, t);

    if (value <= 0) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: Container(
        color: Color.fromRGBO(5, 8, 26, value),
      ),
    );
  }
}

// ============================================================================
// SECTION 4 — Final victory screen (Arabic, premium UI)
// ============================================================================

class VictoryFinalScreen extends StatelessWidget {
  const VictoryFinalScreen({
    super.key,
    required this.currentLevel,
    required this.currentIsland,
    required this.starsEarned,
    this.gemEarned = false,
    this.isFinalIsland = false,
  });

  /// The level number just completed (1-based).
  final int currentLevel;

  /// The island the completed level belongs to. Forwarded to
  /// [IslandScreen] / [WorldMapScreen].
  final PuzzleModel currentIsland;

  final int starsEarned;
  final bool gemEarned;

  /// True when [currentIsland] is the last island in the world — decides
  /// whether "متابعة" goes to [IslandScreen] or [WorldMapScreen].
  final bool isFinalIsland;

  Future<void> _handleContinue(BuildContext context) async {
    // Player watches the ad after the reward has already been granted
    // (star/gem are added inside VictoryCinematicScreen when they land on
    // the toolbar), never before it.
    await RewardAdService.showContinueAd();

    if (!context.mounted) return;

    if (isFinalIsland) {
      // Last level of the last island -> straight to the world map.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => WorldMapScreen()),
      );
      return;
    }

    // IslandScreen is responsible for opening the correct next level (or
    // showing the island map if this was the island's last level).
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => IslandScreen(island: currentIsland),
      ),
    );
  }

  void _handleExit() {
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xff070B1F),
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              radius: 1.2,
              colors: [
                Color(0xff1B2A63),
                Color(0xff070B1F),
              ],
            ),
          ),
          child: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 32,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const RadialGradient(
                              colors: [
                                Color(0xffFFE9A8),
                                Color(0xffFFD54F),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xffFFD54F)
                                    .withOpacity(0.55),
                                blurRadius: 46,
                                spreadRadius: 6,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.emoji_events,
                            color: Color(0xff0A1330),
                            size: 64,
                          ),
                        ),
                        const SizedBox(height: 28),
                        const Text(
                          'أحسنت!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'اكتملت المرحلة $currentLevel',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (i) {
                            final filled = i < starsEarned;
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: Icon(
                                filled ? Icons.star : Icons.star_border,
                                color: const Color(0xffFFD54F),
                                size: 48,
                                shadows: filled
                                    ? [
                                        Shadow(
                                          color: const Color(0xffFFD54F)
                                              .withOpacity(0.6),
                                          blurRadius: 18,
                                        ),
                                      ]
                                    : null,
                              ),
                            );
                          }),
                        ),
                        if (gemEarned) ...[
                          const SizedBox(height: 22),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xff5AC8FA).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: const Color(0xff9BE8FF),
                                width: 1.4,
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.diamond,
                                  color: Color(0xff9BE8FF),
                                  size: 22,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'حصلت على جوهرة!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 44),
                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: ElevatedButton(
                            onPressed: () => _handleContinue(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xffFFD54F),
                              foregroundColor: const Color(0xff0A1330),
                              elevation: 8,
                              shadowColor:
                                  const Color(0xffFFD54F).withOpacity(0.6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: const Text(
                              'متابعة',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: _ExitButton(onPressed: _handleExit),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExitButton extends StatelessWidget {
  const _ExitButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.08),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(
            Icons.close_rounded,
            color: Colors.white.withOpacity(0.85),
            size: 22,
          ),
        ),
      ),
    );
  }
}