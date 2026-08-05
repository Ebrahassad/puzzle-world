import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/scheduler.dart';
import 'package:flutter/material.dart';
import 'final_victory_screen.dart';
import '../managers/reward_manager.dart';

/// A single tile of the victory cinematic's own image-splitting system.
///
/// This has NO relationship to the puzzle engine's PuzzlePiece — it is a
/// plain rectangular crop of ui.Image, built and owned entirely by
/// VictoryScreen. This is what makes VictoryScreen self-contained: it only
/// ever needs a ui.Image to do everything it does.
class VictoryPiece {
/// The rectangular region this piece is cropped from in the source image.
final Rect sourceRect;

/// The size this piece is drawn at on screen.
final Size destSize;

/// Current top-left drawing position on screen (starts at the piece's
/// "assembled" position, then drifts during the explosion).
Offset position;

double vx;
double vy;
double gravity;

/// Rotation speed (radians per physics step).
double rotation;

/// Current accumulated rotation angle.
double angle;

double opacity;
double scale;

VictoryPiece({
required this.sourceRect,
required this.destSize,
required this.position,
this.vx = 0,
this.vy = 0,
this.gravity = 0.35,
this.rotation = 0,
this.angle = 0,
this.opacity = 1,
this.scale = 1,
});
}

/// Decorative sparkle particle for the chest-opening celebration burst.
/// Purely cosmetic — kept private to this file.
class _ConfettiSpark {
double x;
double y;
double vx;
double vy;
double rotation;
double rotationSpeed;
double opacity;
double size;
final Color color;

_ConfettiSpark({
required this.x,
required this.y,
required this.vx,
required this.vy,
required this.rotation,
required this.rotationSpeed,
required this.opacity,
required this.size,
required this.color,
});
}

/// Cinematic victory sequence.
///
/// VictoryScreen is fully self-contained: it depends on nothing from the
/// puzzle engine (no PuzzlePiece, no piece.path, no boardRect/rows/cols
/// coming from a controller). The only visual input it needs is
/// [puzzleImage] — VictoryScreen splits it into its own [VictoryPiece]
/// grid and animates that independently.
///
/// Timeline (mirrors assets/audio/puzzle_win.mp3, ~15s total):
///
///   0s  -  2s : the full completed image is shown (fade + scale in).
///   2s  -  5s : the image is torn into pieces which explode outward,
///               fading from opacity 1 -> 0 slowly and linearly across
///               the whole 3 seconds (not a fast/abrupt fade).
///   5s  - 10s : a chest falls in, bounces, shakes, then opens with a
///               flash + sparkle celebration.
///   10s - 12s : the star appears, pauses ~0.5s, then flies into the
///               real GameToolbar star slot via widget.starTargetKey.
///   12s - 15s : persistent navigation buttons fade + float in (Next /
///               Map / Replay) — they never auto-hide.
///
/// NOTE ON AUDIO: no audio manager was supplied to this file, so playback
/// of puzzle_win.mp3 must be started by the caller at the same moment it
/// pushes this route, to stay in sync with the schedule above.
///
/// NOTE ON TRANSPARENCY: this widget stays fully transparent so
/// PuzzleGameScreen remains visible behind it. Push it with a non-opaque
/// route (PageRouteBuilder(opaque: false, barrierColor: Colors.transparent)).
class VictoryScreen extends StatefulWidget {
/// The one and only visual dependency of this screen.
final ui.Image puzzleImage;

final dynamic island;
final int levelNumber;
final bool isFinalLevel;

final GlobalKey? starTargetKey;

final VoidCallback onFinished;

/// Optional dedicated handlers for the end-of-scene buttons. Each falls
/// back to [onFinished] when not provided.
final VoidCallback? onNext;
final VoidCallback? onMap;
final VoidCallback? onReplay;

const VictoryScreen({
super.key,
required this.puzzleImage,
required this.island,
required this.levelNumber,
this.isFinalLevel = false,
this.starTargetKey,
required this.onFinished,
this.onNext,
this.onMap,
this.onReplay,
});

@override
State<VictoryScreen> createState() => _VictoryScreenState();
}

class _VictoryScreenState extends State<VictoryScreen>
with TickerProviderStateMixin {

//==============================
// Master timing schedule (ms)
//==============================

static const int kImagePhaseMs = 2000;
static const int kExplosionPhaseMs = 3000;
static const int kChestPhaseMs = 5000;

//==============================
// Own image-splitting grid (independent of the puzzle engine)
//==============================

static const int _gridCols = 5;
static const int _gridRows = 4;

bool _layoutReady = false;
Rect _boardRect = Rect.zero;
List<VictoryPiece> _pieces = [];

//==============================
// Intro (completed image reveal)
//==============================

bool _introVisible = false;
bool _showPieces = true;

//==============================
// Explosion physics
//==============================

late Ticker _physicsTicker;
double _lastElapsedMs = 0;

//==============================
// Chest
//==============================

late AnimationController _chestController;

late Animation<double> _chestFall;
late Animation<double> _chestScale;
late Animation<double> _chestShake;

bool _showChest = false;
bool _chestOpened = false;

double _flash = 0;

final GlobalKey _chestKey = GlobalKey();

//==============================
// Chest-open celebration (glow + sparkles + star preview)
//==============================

late AnimationController _glowController;

late Ticker _sparkleTicker;
final List<_ConfettiSpark> _sparkles = [];
bool _sparklesActive = false;

late AnimationController _starPreviewController;
bool _showStarPreview = false;

//==============================
// Reward flight (star -> GameToolbar)
//==============================

late AnimationController _rewardController;

bool _showReward = false;
bool _rewardSent = false;

Offset _rewardStart = Offset.zero;
Offset _rewardEnd = Offset.zero;

//==============================
// End-of-scene navigation buttons
//==============================

bool _showButtons = false;
late AnimationController _buttonsFloatController;

@override
void initState() {
super.initState();

_rewardSent = false;  

_physicsTicker = createTicker(_updateExplosion);  
_sparkleTicker = createTicker(_updateSparkles);  

_setupChestAnimation();  

_glowController = AnimationController(  
  vsync: this,  
  duration: const Duration(milliseconds: 1500),  
);  

_starPreviewController = AnimationController(  
  vsync: this,  
  duration: const Duration(milliseconds: 900),  
)..repeat(reverse: true);  

_rewardController = AnimationController(  
  vsync: this,  
  duration: const Duration(milliseconds: 1300),  
);  

_buttonsFloatController = AnimationController(  
  vsync: this,  
  duration: const Duration(milliseconds: 1800),  
)..repeat();  

WidgetsBinding.instance.addPostFrameCallback((_) {  
  if (!mounted) return;  
  _prepareLayout();  
  _runSequence();  
});

}

//==============================
// Stage 3: split the image into a fixed grid
//==============================

void _prepareLayout() {
final screenSize = MediaQuery.of(context).size;
_boardRect = _computeBoardRect(screenSize);
_pieces = _buildPieces(_boardRect);

setState(() {  
  _layoutReady = true;  
});

}

Rect _computeBoardRect(Size screenSize) {
final imgW = widget.puzzleImage.width.toDouble();
final imgH = widget.puzzleImage.height.toDouble();
final aspect = imgW <= 0 || imgH <= 0 ? 1.0 : imgW / imgH;

final maxWidth = screenSize.width * 0.82;  
final maxHeight = screenSize.height * 0.5;  

double width = maxWidth;  
double height = width / aspect;  

if (height > maxHeight) {  
  height = maxHeight;  
  width = height * aspect;  
}  

final left = (screenSize.width - width) / 2;  
final top = (screenSize.height - height) / 2 - 30;  

return Rect.fromLTWH(left, top, width, height);

}

List<VictoryPiece> _buildPieces(Rect board) {
final image = widget.puzzleImage;

final srcPieceW = image.width / _gridCols;  
final srcPieceH = image.height / _gridRows;  

final destPieceW = board.width / _gridCols;  
final destPieceH = board.height / _gridRows;  

final list = <VictoryPiece>[];  

for (var row = 0; row < _gridRows; row++) {  
  for (var col = 0; col < _gridCols; col++) {  
    final sourceRect = Rect.fromLTWH(  
      col * srcPieceW,  
      row * srcPieceH,  
      srcPieceW,  
      srcPieceH,  
    );  

    final restPosition = Offset(  
      board.left + col * destPieceW,  
      board.top + row * destPieceH,  
    );  

    list.add(  
      VictoryPiece(  
        sourceRect: sourceRect,  
        destSize: Size(destPieceW, destPieceH),  
        position: restPosition,  
      ),  
    );  
  }  
}  

return list;

}

//==============================
// Stage 6 + 7: explosion + slow linear fade (opacity 1 -> 0 over 3s)
//==============================

void _startExplosion() {
final random = Random();

for (final piece in _pieces) {  
  piece.vx = (random.nextDouble() - 0.5) * 14;  
  piece.vy = -6.0 - random.nextDouble() * 12.0;  
  piece.gravity = 0.28 + random.nextDouble() * 0.35;  
  piece.rotation = (random.nextDouble() - 0.5) * 0.06;  
  piece.angle = 0;  
  piece.opacity = 1;  
  piece.scale = 1;  
}  

_lastElapsedMs = 0;  
_physicsTicker.start();

}

/// Frame-rate independent physics. Opacity fades linearly and slowly
/// from 1 to 0 across the entire 3-second window (stage 7), instead of
/// dropping quickly — this is what "ببطء" (slowly) means here.
void _updateExplosion(Duration elapsed) {
final elapsedMs = elapsed.inMilliseconds.toDouble();
final dt = ((elapsedMs - _lastElapsedMs) / (1000 / 60)).clamp(0.2, 3.0);
_lastElapsedMs = elapsedMs;

final fadeT = (elapsedMs / kExplosionPhaseMs).clamp(0.0, 1.0);  
final targetOpacity = (1.0 - fadeT).clamp(0.0, 1.0);  

final floorY = _boardRect.top + 260;  

for (final piece in _pieces) {  
  piece.position += Offset(piece.vx * dt, piece.vy * dt);  
  piece.vy += piece.gravity * dt;  

  if (piece.position.dy > floorY) {  
    piece.position = Offset(piece.position.dx, floorY);  
    piece.vy *= -0.45;  
    piece.vx *= 0.8;  
  }  

  final damping = pow(0.985, dt).toDouble();  
  piece.vx *= damping;  
  piece.vy *= damping;  

  piece.angle += piece.rotation * dt;  
  piece.opacity = targetOpacity;  
  piece.scale = max(0.82, piece.scale - 0.0006 * dt);  
}  

if (mounted) {  
  setState(() {});  
}

}

//==============================
// Chest animation setup (stage 8)
//==============================

void _setupChestAnimation() {
_chestController = AnimationController(
vsync: this,
duration: const Duration(milliseconds: 3200),
);

_chestFall = TweenSequence<double>([  
  TweenSequenceItem(  
    tween: Tween(begin: -650.0, end: 0.0).chain(  
      CurveTween(curve: Curves.easeInCubic),  
    ),  
    weight: 55,  
  ),  
  TweenSequenceItem(  
    tween: Tween(begin: 0.0, end: -70.0).chain(  
      CurveTween(curve: Curves.easeOut),  
    ),  
    weight: 15,  
  ),  
  TweenSequenceItem(  
    tween: Tween(begin: -70.0, end: 0.0).chain(  
      CurveTween(curve: Curves.bounceOut),  
    ),  
    weight: 30,  
  ),  
]).animate(_chestController);  

_chestScale = TweenSequence<double>([  
  TweenSequenceItem(  
    tween: Tween(begin: 0.75, end: 1.2).chain(  
      CurveTween(curve: Curves.easeOutBack),  
    ),  
    weight: 55,  
  ),  
  TweenSequenceItem(  
    tween: Tween(begin: 1.2, end: 1.0),  
    weight: 45,  
  ),  
]).animate(_chestController);  

_chestShake = Tween<double>(  
  begin: -0.09,  
  end: 0.09,  
).animate(  
  CurvedAnimation(  
    parent: _chestController,  
    curve: const Interval(0.62, 0.82, curve: Curves.easeInOut),  
  ),  
);  

_chestController.addStatusListener((status) {  
  if (status == AnimationStatus.completed) {  
    if (!mounted) return;  

    setState(() {  
      _chestOpened = true;  
      _flash = 1;  
      _showStarPreview = true;  
    });  

    _glowController.repeat(reverse: true);  
    _spawnSparkles();  

    Future.delayed(  
      const Duration(milliseconds: 300),  
      () {  
        if (mounted) {  
          setState(() {  
            _flash = 0;  
          });  
        }  
      },  
    );  
  }  
});

}

//==============================
// Chest-open sparkle burst
//==============================

void _spawnSparkles() {
if (!mounted) return;

final size = MediaQuery.of(context).size;  
final origin = Offset(size.width / 2, size.height / 2);  
final random = Random();  

const colors = [  
  Color(0xFFFFD54F),  
  Color(0xFFFFFFFF),  
  Color(0xFFFFE082),  
  Color(0xFF64B5F6),  
];  

_sparkles.clear();  

for (var i = 0; i < 45; i++) {  
  final angle = random.nextDouble() * pi * 2;  
  final speed = 3 + random.nextDouble() * 7;  

  _sparkles.add(  
    _ConfettiSpark(  
      x: origin.dx,  
      y: origin.dy,  
      vx: cos(angle) * speed,  
      vy: sin(angle) * speed - 3,  
      rotation: random.nextDouble() * pi,  
      rotationSpeed: (random.nextDouble() - 0.5) * 0.3,  
      opacity: 1,  
      size: 5 + random.nextDouble() * 7,  
      color: colors[random.nextInt(colors.length)],  
    ),  
  );  
}  

_sparklesActive = true;  
_sparkleTicker.start();

}

void _updateSparkles(Duration elapsed) {
bool active = false;

for (final s in _sparkles) {  
  if (s.opacity <= 0) continue;  

  active = true;  

  s.x += s.vx;  
  s.y += s.vy;  
  s.vy += 0.16;  
  s.vx *= 0.985;  
  s.rotation += s.rotationSpeed;  
  s.opacity -= 0.014;  
}  

if (mounted) {  
  setState(() {});  
}  

if (!active) {  
  _sparkleTicker.stop();  
  _sparklesActive = false;  
}

}

//==============================
// Stage 9: star reveal, pause, then flight to GameToolbar
//==============================

Future<void> _startRewardFlight() async {
// Guard: never let the reward be granted / flown more than once.
if (_rewardSent) return;
_rewardSent = true;

if (!mounted) return;  

final size = MediaQuery.of(context).size;  

if (_chestKey.currentContext != null) {  
  final box = _chestKey.currentContext!.findRenderObject() as RenderBox;  
  _rewardStart = box.localToGlobal(box.size.center(Offset.zero));  
} else {  
  _rewardStart = Offset(size.width / 2, size.height / 2);  
}  

final targetKey = widget.starTargetKey;  

// Preferred path: fly straight into the real GameToolbar star slot via  
// the provided GlobalKey — no duplicate toolbar is ever created here.  
if (targetKey != null && targetKey.currentContext != null) {  
  final box = targetKey.currentContext!.findRenderObject() as RenderBox;  
  _rewardEnd = box.localToGlobal(box.size.center(Offset.zero));  
} else {  
  // Fallback only: if the toolbar key isn't measurable yet, land the  
  // star in the same corner the real toolbar's star lives in.  
  _rewardEnd = Offset(size.width - 50, 40);  
}  

setState(() {  
  _showStarPreview = false;  
  _showReward = true;  
});  

_rewardController.reset();  
await _rewardController.forward();  
if (!mounted) return;  

// Grant the reward exactly once, right as it lands.  
RewardManager.addStars(1);  

setState(() {  
  _showReward = false;  
});

}

//==============================
// Master sequence
//==============================

Future<void> _runSequence() async {
// Stage 4 (0s - 2s): show the full assembled image, no explosion yet.
setState(() => _introVisible = true);

await Future.delayed(const Duration(milliseconds: kImagePhaseMs));  
if (!mounted) return;  

// Stage 5 + 6 + 7 (2s - 5s): tear into pieces, explode, fade slowly.  
_startExplosion();  
await Future.delayed(const Duration(milliseconds: kExplosionPhaseMs));  
if (!mounted) return;  

_physicsTicker.stop();  
setState(() {  
  _showPieces = false;  
  _showChest = true;  
});  

// Stage 8 (5s - 10s): chest falls, shakes, opens, celebrates.  
_chestController.forward();  
await Future.delayed(const Duration(milliseconds: kChestPhaseMs));  
if (!mounted) return;  

// Stage 9 (10s - 12s): star pauses ~0.5s, then flies to the toolbar.  
await Future.delayed(const Duration(milliseconds: 500));  
if (!mounted) return;  

await _startRewardFlight();  
if (!mounted) return;  

if (widget.isFinalLevel) {  
  Navigator.pushReplacement(  
    context,  
    MaterialPageRoute(  
      builder: (_) => FinalVictoryScreen(  
        island: widget.island,  
      ),  
    ),  
  );  
  return;  
}  

// Stage 10 (12s - 15s): navigation buttons fade + float in, and stay.  
await Future.delayed(const Duration(milliseconds: 300));  
if (!mounted) return;  

setState(() {  
  _showButtons = true;  
});

}

@override
Widget build(BuildContext context) {
// Fully transparent root: the underlying PuzzleGameScreen stays
// visible behind this whole cinematic. No opaque Scaffold background.
return Material(
type: MaterialType.transparency,
child: Stack(
children: [
if (_showPieces && _layoutReady)
Positioned.fill(
child: IgnorePointer(
child: AnimatedOpacity(
duration: const Duration(milliseconds: 500),
opacity: _introVisible ? 1 : 0,
child: AnimatedScale(
duration: const Duration(milliseconds: 500),
curve: Curves.easeOutBack,
scale: _introVisible ? 1 : 0.9,
child: CustomPaint(
painter: VictoryPiecePainter(
image: widget.puzzleImage,
pieces: _pieces,
),
),
),
),
),
),

if (_showChest && _chestOpened)  
        IgnorePointer(  
          child: Center(  
            child: AnimatedBuilder(  
              animation: _glowController,  
              builder: (context, child) {  
                final glow = 0.18 + (_glowController.value * 0.22);  
                return Container(  
                  width: 460,  
                  height: 460,  
                  decoration: BoxDecoration(  
                    shape: BoxShape.circle,  
                    gradient: RadialGradient(  
                      colors: [  
                        Colors.amber.withOpacity(glow),  
                        Colors.transparent,  
                      ],  
                    ),  
                  ),  
                );  
              },  
            ),  
          ),  
        ),  

      if (_sparklesActive || _sparkles.isNotEmpty)  
        Positioned.fill(  
          child: IgnorePointer(  
            child: CustomPaint(  
              painter: _ConfettiSparkPainter(List.of(_sparkles)),  
            ),  
          ),  
        ),  

      if (_showChest)  
        Center(  
          child: AnimatedBuilder(  
            animation: _chestController,  
            builder: (context, child) {  
              return Transform.translate(  
                offset: Offset(0, _chestFall.value),  
                child: Transform.scale(  
                  scale: _chestScale.value,  
                  child: Transform.rotate(  
                    angle: _chestShake.value,  
                    child: Container(  
                      key: _chestKey,  
                      child: Image.asset(  
                        _chestOpened  
                            ? 'assets/images/rewards/reward_chest_open.png'  
                            : 'assets/images/rewards/reward_chest_closed.png',  
                        width: 250,  
                      ),  
                    ),  
                  ),  
                ),  
              );  
            },  
          ),  
        ),  

      if (_showStarPreview)  
        IgnorePointer(  
          child: Center(  
            child: AnimatedBuilder(  
              animation: _starPreviewController,  
              builder: (context, child) {  
                final t = _starPreviewController.value;  
                final scale = 0.9 + (t * 0.2);  
                return Transform.translate(  
                  offset: const Offset(0, -110),  
                  child: Opacity(  
                    opacity: 0.85 + (t * 0.15),  
                    child: Transform.scale(  
                      scale: scale,  
                      child: Image.asset(  
                        'assets/images/rewards/Star_gold.png',  
                        width: 60,  
                      ),  
                    ),  
                  ),  
                );  
              },  
            ),  
          ),  
        ),  

      if (_showReward)  
        AnimatedBuilder(  
          animation: _rewardController,  
          builder: (context, child) {  
            final t = Curves.easeInOutCubic.transform(_rewardController.value);  

            final x = _rewardStart.dx + (_rewardEnd.dx - _rewardStart.dx) * t;  
            final y = _rewardStart.dy + (_rewardEnd.dy - _rewardStart.dy) * t;  
            final currentScale = 1.0 - (_rewardController.value * 0.35);  

            return Positioned(  
              left: x - 35,  
              top: y - 35,  
              child: Transform.scale(  
                scale: currentScale.clamp(0.65, 1.0),  
                child: Image.asset(  
                  'assets/images/rewards/Star_gold.png',  
                  width: 70,  
                ),  
              ),  
            );  
          },  
        ),  

      if (_flash > 0)  
        Positioned.fill(  
          child: IgnorePointer(  
            child: Opacity(  
              opacity: _flash,  
              child: Container(  
                color: Colors.white,  
              ),  
            ),  
          ),  
        ),  

      if (_showButtons)  
        Positioned(  
          left: 0,  
          right: 0,  
          bottom: 56,  
          child: TweenAnimationBuilder<double>(  
            tween: Tween(begin: 0, end: 1),  
            duration: const Duration(milliseconds: 500),  
            curve: Curves.easeOut,  
            builder: (context, fadeT, child) {  
              return Opacity(  
                opacity: fadeT,  
                child: Transform.translate(  
                  offset: Offset(0, (1 - fadeT) * 20),  
                  child: child,  
                ),  
              );  
            },  
            child: AnimatedBuilder(  
              animation: _buttonsFloatController,  
              builder: (context, child) {  
                final bob = sin(_buttonsFloatController.value * 2 * pi) * 6;  
                return Transform.translate(  
                  offset: Offset(0, bob),  
                  child: child,  
                );  
              },  
              child: Row(  
                mainAxisAlignment: MainAxisAlignment.center,  
                children: [  
                  _VictoryActionButton(  
                    icon: Icons.replay_rounded,  
                    label: 'إعادة اللعب',  
                    onTap: widget.onReplay ?? widget.onFinished,  
                  ),  
                  const SizedBox(width: 14),  
                  _VictoryActionButton(  
                    icon: Icons.map_rounded,  
                    label: 'الخريطة',  
                    onTap: widget.onMap ?? widget.onFinished,  
                  ),  
                  const SizedBox(width: 14),  
                  _VictoryActionButton(  
                    icon: Icons.arrow_forward_rounded,  
                    label: 'التالي',  
                    filled: true,  
                    onTap: widget.onNext ?? widget.onFinished,  
                  ),  
                ],  
              ),  
            ),  
          ),  
        ),  
    ],  
  ),  
);

}

@override
void dispose() {
_physicsTicker.dispose();
_sparkleTicker.dispose();
_chestController.dispose();
_glowController.dispose();
_starPreviewController.dispose();
_rewardController.dispose();
_buttonsFloatController.dispose();
super.dispose();
}
}

//======================================
// End-of-scene action button
//======================================

class _VictoryActionButton extends StatelessWidget {
final IconData icon;
final String label;
final VoidCallback onTap;
final bool filled;

const _VictoryActionButton({
required this.icon,
required this.label,
required this.onTap,
this.filled = false,
});

@override
Widget build(BuildContext context) {
return Material(
color: filled
? Colors.amber
: Colors.black.withOpacity(0.55),
borderRadius: BorderRadius.circular(24),
child: InkWell(
borderRadius: BorderRadius.circular(24),
onTap: onTap,
child: Padding(
padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
child: Row(
mainAxisSize: MainAxisSize.min,
children: [
Icon(
icon,
color: filled ? Colors.black : Colors.white,
size: 20,
),
const SizedBox(width: 6),
Text(
label,
style: TextStyle(
color: filled ? Colors.black : Colors.white,
fontWeight: FontWeight.bold,
fontSize: 14,
),
),
],
),
),
),
);
}
}

//======================================
// Victory Piece Painter — independent of the puzzle engine.
// Plain rectangular crop-and-draw, no jigsaw path/clip logic at all.
//======================================

class VictoryPiecePainter extends CustomPainter {
final ui.Image image;
final List<VictoryPiece> pieces;

VictoryPiecePainter({
required this.image,
required this.pieces,
});

static final Paint _paint = Paint()..filterQuality = FilterQuality.high;

@override
void paint(Canvas canvas, Size size) {
for (final piece in pieces) {
if (piece.opacity <= 0) continue;

canvas.save();  

  final center = Offset(  
    piece.position.dx + piece.destSize.width / 2,  
    piece.position.dy + piece.destSize.height / 2,  
  );  

  canvas.translate(center.dx, center.dy);  
  canvas.rotate(piece.angle);  
  canvas.scale(piece.scale);  
  canvas.translate(-piece.destSize.width / 2, -piece.destSize.height / 2);  

  _paint.color = Colors.white.withOpacity(piece.opacity.clamp(0, 1));  

  canvas.drawImageRect(  
    image,  
    piece.sourceRect,  
    Rect.fromLTWH(0, 0, piece.destSize.width, piece.destSize.height),  
    _paint,  
  );  

  // Soft shadow while exploding, for a bit of depth.  
  final shadowPaint = Paint()  
    ..color = Colors.black.withOpacity(piece.opacity * 0.2)  
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);  

  canvas.drawRect(  
    Rect.fromLTWH(0, 0, piece.destSize.width, piece.destSize.height),  
    shadowPaint,  
  );  

  canvas.restore();  
}

}

@override
bool shouldRepaint(covariant VictoryPiecePainter oldDelegate) => true;
}

//======================================
// Sparkle burst painter (chest-open celebration)
//======================================

class _ConfettiSparkPainter extends CustomPainter {
final List<_ConfettiSpark> sparks;

_ConfettiSparkPainter(this.sparks);

@override
void paint(Canvas canvas, Size size) {
final paint = Paint();

for (final s in sparks) {  
  if (s.opacity <= 0) continue;  

  paint.color = s.color.withOpacity(s.opacity.clamp(0, 1));  

  canvas.save();  
  canvas.translate(s.x, s.y);  
  canvas.rotate(s.rotation);  
  canvas.drawRect(  
    Rect.fromCenter(center: Offset.zero, width: s.size, height: s.size * 0.5),  
    paint,  
  );  
  canvas.restore();  
}

}

@override
bool shouldRepaint(covariant _ConfettiSparkPainter oldDelegate) => true;
}