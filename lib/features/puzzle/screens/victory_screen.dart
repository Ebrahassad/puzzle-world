import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';


// ============================================================================
// victory_screen.dart
//
// Puzzle World cinematic victory sequence.
// Contains:
// - MagicParticles
// - Puzzle shatter effect
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
  }) : particles =
          _build(
            count,
            colors,
            seed,
            minSize,
            maxSize,
          );


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


    return List.generate(
      count,
      (i) {

        return _Particle(

          angle:
              random.nextDouble() *
              math.pi *
              2,

          distanceFactor:
              0.4 +
              random.nextDouble() *
              0.6,


          size:
              minSize +
              random.nextDouble() *
              (maxSize - minSize),


          color:
              colors[
                random.nextInt(
                  colors.length,
                )
              ],


          delay:
              random.nextDouble() *
              0.35,


          twinklePhase:
              random.nextDouble() *
              math.pi *
              2,

        );

      },
    );
  }



  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {

    for (final particle in particles) {

      var local =
          (progress - particle.delay) /
          (1 - particle.delay);


      if (local <= 0) {
        continue;
      }


      local =
          local.clamp(
            0.0,
            1.0,
          );


      final eased =
          Curves.easeOut.transform(
            local,
          );


      final distance =
          spread *
          particle.distanceFactor *
          eased;


      final position =
          origin +
          Offset(
            math.cos(particle.angle) *
                distance,

            math.sin(particle.angle) *
                distance,
          );


      final opacity =
          (1 - local);


      final paint =
          Paint()
            ..color =
                particle.color.withOpacity(
                  opacity,
                );


      canvas.drawCircle(
        position,
        particle.size,
        paint,
      );

    }
  }



  @override
  bool shouldRepaint(
    covariant _ParticlePainter oldDelegate,
  ) {

    return oldDelegate.progress != progress ||
        oldDelegate.origin != origin;

  }
}

// ============================================================================
// SECTION 1 — Puzzle shatter system
// ============================================================================


class PuzzleShard {

  PuzzleShard({
    required this.srcRect,
    required this.restRect,
    required this.direction,
    required this.travel,
    required this.spin,
    required this.delay,
  });


  final Rect srcRect;
  final Rect restRect;
  final Offset direction;
  final double travel;
  final double spin;
  final double delay;

}



List<PuzzleShard> buildPuzzleShards({

  required Rect frameRect,

  required Size imageSize,

  int cols = 6,

  int rows = 8,

  int seed = 7,

}) {


  final random =
      math.Random(seed);


  final shards =
      <PuzzleShard>[];



  final cellWidth =
      frameRect.width / cols;


  final cellHeight =
      frameRect.height / rows;



  final sourceWidth =
      imageSize.width / cols;


  final sourceHeight =
      imageSize.height / rows;



  final center =
      frameRect.center;



  for (int row = 0; row < rows; row++) {


    for (int col = 0; col < cols; col++) {


      final restRect =
          Rect.fromLTWH(

            frameRect.left +
                col * cellWidth,

            frameRect.top +
                row * cellHeight,

            cellWidth,

            cellHeight,

          );



      final sourceRect =
          Rect.fromLTWH(

            col * sourceWidth,

            row * sourceHeight,

            sourceWidth,

            sourceHeight,

          );



      final outward =
          restRect.center - center;



      final direction =
          outward.distance < 1

              ? Offset(
                  random.nextDouble() * 2 - 1,
                  random.nextDouble() * 2 - 1,
                )

              : outward /
                  outward.distance;



      shards.add(

        PuzzleShard(

          srcRect:
              sourceRect,

          restRect:
              restRect,

          direction:
              direction,

          travel:
              90 +
              random.nextDouble() *
              160,

          spin:
              (random.nextDouble() - 0.5) *
              math.pi *
              2.4,

          delay:
              random.nextDouble() *
              0.3,

        ),

      );

    }

  }


  return shards;

}





class ShatterPainter extends CustomPainter {


  ShatterPainter({

    required this.image,

    required this.shards,

    required this.progress,

  });



  final ui.Image image;

  final List<PuzzleShard> shards;

  final double progress;



  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {


    for (final shard in shards) {


      var local =
          (progress - shard.delay) /
          (1 - shard.delay);



      if (local <= 0) {


        _drawShard(

          canvas,

          shard,

          shard.restRect,

          0,

          1,

        );


        continue;

      }



      local =
          local.clamp(
            0.0,
            1.0,
          );



      final eased =
          Curves.easeIn.transform(
            local,
          );



      final offset =
          shard.direction *
          shard.travel *
          eased;



      final rect =
          shard.restRect.shift(
            offset,
          );



      final rotation =
          shard.spin *
          eased;



      final opacity =
          1 - local;



      if (opacity <= 0.01) {
        continue;
      }



      _drawShard(

        canvas,

        shard,

        rect,

        rotation,

        opacity,

      );

    }

  }





  void _drawShard(

    Canvas canvas,

    PuzzleShard shard,

    Rect rect,

    double rotation,

    double opacity,

  ) {


    canvas.save();



    canvas.translate(
      rect.center.dx,
      rect.center.dy,
    );



    canvas.rotate(
      rotation,
    );



    canvas.translate(
      -rect.center.dx,
      -rect.center.dy,
    );



    final paint =
        Paint()
          ..color =
              Colors.white.withOpacity(
                opacity,
              );



    canvas.drawImageRect(

      image,

      shard.srcRect,

      rect,

      paint,

    );



    canvas.restore();

  }





  @override
  bool shouldRepaint(
    covariant ShatterPainter oldDelegate,
  ) {

    return oldDelegate.progress != progress ||
        oldDelegate.image != image;

  }

}

class VictoryCinematicScreen extends StatefulWidget {

  const VictoryCinematicScreen({

    super.key,

    required this.puzzleImage,

    required this.levelNumber,

    required this.onFinished,

    this.isFinalLevel = false,

    this.starTargetKey,

    this.gemTargetKey,

    this.onStarEarned,

    this.onGemEarned,

    this.totalDuration =
        const Duration(seconds: 5),

  });



  final ImageProvider puzzleImage;

  final int levelNumber;

  final bool isFinalLevel;


  final GlobalKey? starTargetKey;

  final GlobalKey? gemTargetKey;


  final VoidCallback? onStarEarned;

  final VoidCallback? onGemEarned;


  final VoidCallback onFinished;


  final Duration totalDuration;



  @override
  State<VictoryCinematicScreen> createState() =>
      _VictoryCinematicScreenState();

}




class _VictoryCinematicScreenState
    extends State<VictoryCinematicScreen>
    with SingleTickerProviderStateMixin {


  final GlobalKey _stageKey =
      GlobalKey();



  late AnimationController _controller;



  ui.Image? _puzzleImage;



  List<PuzzleShard>? _shards;



  Offset? _starTarget;

  Offset? _gemTarget;



  bool _starLanded = false;

  bool _gemLanded = false;



  static const double revealEnd = 0.20;

  static const double holdEnd = 0.32;

  static const double shatterEnd = 0.50;

  static const double chestInEnd = 0.60;

  static const double chestOpenEnd = 0.68;

  static const double fadeStart = 0.94;



  double get starEnd =>
      widget.isFinalLevel
          ? 0.80
          : 0.92;



  double get gemEnd =>
      0.96;




  @override
  void initState() {

    super.initState();



    _controller =
        AnimationController(
          vsync: this,
          duration: widget.totalDuration,
        );



    _controller.addStatusListener(
      (status) {

        if (status ==
                AnimationStatus.completed &&
            mounted) {

          widget.onFinished();

        }

      },
    );



    _loadPuzzleImage();



    WidgetsBinding.instance
        .addPostFrameCallback(
      (_) {

        if (!mounted) return;


        _resolveTargets();


        _controller.forward();

      },
    );

  }





  Future<void> _loadPuzzleImage() async {


    final completer =
        Completer<ui.Image>();



    final stream =
        widget.puzzleImage.resolve(
          const ImageConfiguration(),
        );



    late ImageStreamListener listener;



    listener =
        ImageStreamListener(
      (info, _) {

        completer.complete(
          info.image,
        );


        stream.removeListener(
          listener,
        );

      },

      onError: (error, stack) {

        if (!completer.isCompleted) {

          completer.completeError(
            error,
          );

        }


        stream.removeListener(
          listener,
        );

      },

    );



    stream.addListener(
      listener,
    );



    try {


      final image =
          await completer.future;



      if (!mounted) return;



      setState(() {

        _puzzleImage =
            image;

      });



    } catch (_) {}

  }





  void _resolveTargets() {

    _starTarget =
        _findTarget(
          widget.starTargetKey,
        );

    _gemTarget =
        _findTarget(
          widget.gemTargetKey,
        );

  }





  Offset? _findTarget(
    GlobalKey? key,
  ) {


    if (key == null) {
      return null;
    }



    final stage =
        _stageKey.currentContext
            ?.findRenderObject()
        as RenderBox?;



    final target =
        key.currentContext
            ?.findRenderObject()
        as RenderBox?;



    if (stage == null ||
        target == null) {

      return null;

    }



    final global =
        target.localToGlobal(
          target.size.center(
            Offset.zero,
          ),
        );



    return stage.globalToLocal(
      global,
    );

  }





  @override
  void dispose() {

    _controller.dispose();

    super.dispose();

  }

  double _phase(
    double start,
    double end,
    double value,
  ) {

    if (end <= start) {

      return value >= start
          ? 1
          : 0;

    }


    return (
      (value - start) /
      (end - start)

    ).clamp(
      0.0,
      1.0,
    );

  }





  @override
  Widget build(BuildContext context) {


    final size =
        MediaQuery.of(context).size;


    final shortest =
        math.min(
          size.width,
          size.height,
        );



    final stageSize =
        shortest
            .clamp(
              280.0,
              640.0,
            ) *
        0.60;



    final center =
        Offset(
          size.width / 2,
          size.height / 2 -
              stageSize * 0.05,
        );



    return Material(

      color:
          Colors.transparent,


      child: Container(

        key:
            _stageKey,


        width:
            double.infinity,


        height:
            double.infinity,



        decoration:
            const BoxDecoration(

          gradient:
              RadialGradient(

            colors: [

              Color(0xff1B2A63),

              Color(0xff060B1F),

            ],

          ),

        ),



        child:
            AnimatedBuilder(

          animation:
              _controller,


          builder:
              (context, child) {


            final t =
                _controller.value;



            return Stack(

              children: [


                _buildPuzzleFrame(
                  t,
                  center,
                  stageSize,
                ),



                _buildShatter(
                  t,
                  center,
                  stageSize,
                ),



                _buildChestGlow(
                  t,
                  center,
                  stageSize,
                ),



                _buildChest(
                  t,
                  center,
                  stageSize,
                ),



                _buildStar(
                  t,
                  center,
                ),



                if (widget.isFinalLevel)

                  _buildGem(
                    t,
                    center,
                  ),



                _buildFade(
                  t,
                ),


              ],

            );

          },

        ),

      ),

    );

  }





  Widget _buildPuzzleFrame(
    double t,
    Offset center,
    double size,
  ) {


    if (t >= shatterEnd) {

      return const SizedBox.shrink();

    }



    final grow =
        _phase(
          0,
          revealEnd,
          t,
        );



    final disappear =
        _phase(
          holdEnd,
          shatterEnd,
          t,
        );



    final scale =
        0.35 +
        Curves.easeOutBack.transform(
          grow,
        ) *
        0.65;



    final opacity =
        disappear > 0

            ? 1 - disappear

            : grow;



    return Positioned(

      left:
          center.dx -
          size / 2,


      top:
          center.dy -
          size / 2,


      width:
          size,


      height:
          size,



      child:
          Opacity(

        opacity:
            opacity.clamp(
              0.0,
              1.0,
            ),



        child:
            Transform.scale(

          scale:
              scale,



          child:
              DecoratedBox(

            decoration:
                BoxDecoration(

              borderRadius:
                  BorderRadius.circular(
                    28,
                  ),


              border:
                  Border.all(

                color:
                    const Color(
                      0xffffd54f,
                    ),


                width:
                    4,

              ),


              boxShadow: [

                BoxShadow(

                  color:
                      const Color(
                        0xffffd54f,
                      ).withOpacity(
                        0.4,
                      ),

                  blurRadius:
                      40,

                ),

              ],

            ),



            child:
                ClipRRect(

              borderRadius:
                  BorderRadius.circular(
                    24,
                  ),



              child:

                  _puzzleImage == null

                      ? Image(
                          image:
                              widget.puzzleImage,

                          fit:
                              BoxFit.cover,
                        )


                      : RawImage(

                          image:
                              _puzzleImage,

                          fit:
                              BoxFit.cover,

                        ),

            ),

          ),

        ),

      ),

    );

  }

  Widget _buildShatter(
    double t,
    Offset center,
    double size,
  ) {

    if (_puzzleImage == null ||
        t < holdEnd ||
        t > shatterEnd) {

      return const SizedBox.shrink();

    }



    final progress =
        _phase(
          holdEnd,
          shatterEnd,
          t,
        );



    _shards ??=
        buildPuzzleShards(

          frameRect:
              Rect.fromCenter(

            center:
                center,

            width:
                size,

            height:
                size,

          ),


          imageSize:

              Size(

            _puzzleImage!.width
                .toDouble(),

            _puzzleImage!.height
                .toDouble(),

          ),

        );



    return Positioned.fill(

      child:
          Stack(

        children: [


          Positioned.fill(

            child:
                CustomPaint(

              painter:
                  ShatterPainter(

                image:
                    _puzzleImage!,

                shards:
                    _shards!,

                progress:
                    progress,

              ),

            ),

          ),



          Positioned.fill(

            child:
                MagicParticles(

              origin:
                  center,

              progress:
                  progress,

              count:
                  40,

              spread:
                  size * 0.9,

              seed:
                  3,

            ),

          ),

        ],

      ),

    );

  }






  Widget _buildChestGlow(
    double t,
    Offset center,
    double size,
  ) {


    if (t < chestInEnd) {

      return const SizedBox.shrink();

    }



    final open =
        _phase(
          chestInEnd,
          chestOpenEnd,
          t,
        );



    final opacity =
        open *
        (1 -
            _phase(
              starEnd,
              1,
              t,
            ));



    return Positioned.fill(

      child:
          Opacity(

        opacity:
            opacity.clamp(
              0.0,
              1.0,
            ),



        child:
            Center(

          child:
              Container(

            width:
                size * 0.9,

            height:
                size * 0.9,



            decoration:
                const BoxDecoration(

              shape:
                  BoxShape.circle,


              gradient:
                  RadialGradient(

                colors: [

                  Color(
                    0xfffff3c4,
                  ),

                  Colors.transparent,

                ],

              ),

            ),

          ),

        ),

      ),

    );

  }






  Widget _buildChest(
    double t,
    Offset center,
    double size,
  ) {


    if (t < shatterEnd) {

      return const SizedBox.shrink();

    }



    final appear =
        _phase(
          shatterEnd,
          chestInEnd,
          t,
        );



    final open =
        _phase(
          chestInEnd,
          chestOpenEnd,
          t,
        );



    final chestSize =
        size * 0.62;



    return Positioned(

      left:
          center.dx -
          chestSize / 2,


      top:
          center.dy -
          chestSize / 2,


      width:
          chestSize,


      height:
          chestSize,



      child:
          Transform.scale(

        scale:
            Curves.easeOutBack.transform(
              appear,
            ),



        child:
            Stack(

          alignment:
              Alignment.center,



          children: [


            Opacity(

              opacity:
                  1 - open,



              child:
                  Image.asset(

                'assets/images/rewards/reward_chest_closed.png',

                fit:
                    BoxFit.contain,

              ),

            ),



            Opacity(

              opacity:
                  open,



              child:
                  Image.asset(

                'assets/images/rewards/reward_chest_open.png',

                fit:
                    BoxFit.contain,

              ),

            ),


          ],

        ),

      ),

    );

  }

  Widget _buildStar(
    double t,
    Offset chest,
  ) {


    if (t < chestOpenEnd) {

      return const SizedBox.shrink();

    }



    final progress =
        _phase(
          chestOpenEnd,
          starEnd,
          t,
        );



    if (progress >= 1) {


      if (!_starLanded) {

        _starLanded = true;


        WidgetsBinding.instance
            .addPostFrameCallback(
          (_) {

            if (mounted) {

              widget.onStarEarned?.call();

            }

          },
        );

      }


      return const SizedBox.shrink();

    }



    final target =
        _starTarget ??
        chest;



    final eased =
        Curves.easeInOutCubic
            .transform(
              progress,
            );



    final position =
        Offset.lerp(
          chest,
          target,
          eased,
        )! +
        Offset(
          0,
          -math.sin(
                progress *
                    math.pi,
              ) *
              90,
        );



    return Positioned(

      left:
          position.dx -
          28,


      top:
          position.dy -
          28,



      child:
          Image.asset(

        'assets/images/rewards/Star_gold.png',

        width:
            56,

        height:
            56,

      ),

    );

  }





  Widget _buildGem(
    double t,
    Offset chest,
  ) {


    if (t < starEnd) {

      return const SizedBox.shrink();

    }



    final progress =
        _phase(
          starEnd,
          gemEnd,
          t,
        );



    if (progress >= 1) {


      if (!_gemLanded) {

        _gemLanded = true;


        WidgetsBinding.instance
            .addPostFrameCallback(
          (_) {

            if (mounted) {

              widget.onGemEarned?.call();

            }

          },
        );

      }


      return const SizedBox.shrink();

    }



    final target =
        _gemTarget ??
        chest;



    final eased =
        Curves.easeInOutCubic
            .transform(
              progress,
            );



    final position =
        Offset.lerp(
          chest,
          target,
          eased,
        )! +
        Offset(
          0,
          -math.sin(
                progress *
                    math.pi,
              ) *
              90,
        );



    return Positioned(

      left:
          position.dx -
          26,


      top:
          position.dy -
          26,



      child:
          Image.asset(

        'assets/images/rewards/gem.png',

        width:
            52,

        height:
            52,

      ),

    );

  }






  Widget _buildFade(
    double t,
  ) {


    final value =
        _phase(
          fadeStart,
          1,
          t,
        );


    if (value <= 0) {

      return const SizedBox.shrink();

    }



    return Positioned.fill(

      child:
          Container(

        color:
            Color.fromRGBO(
              6,
              11,
              31,
              value,
            ),

      ),

    );

  }


}