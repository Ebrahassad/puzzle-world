import 'dart:math' as math;
import 'package:flutter/material.dart';

class PuzzleSplashLogo extends StatefulWidget {
  const PuzzleSplashLogo({
    super.key,
    required this.onFinished,
  });

  final VoidCallback onFinished;

  @override
  State<PuzzleSplashLogo> createState() =>
      _PuzzleSplashLogoState();
}


class _PuzzleSplashLogoState
    extends State<PuzzleSplashLogo>
    with TickerProviderStateMixin {


  late AnimationController controller;

  bool explode = false;


  final List<Offset> directions = [

    const Offset(-120, -80),
    const Offset(120, -70),
    const Offset(-100, 90),
    const Offset(110, 100),
    const Offset(0, -140),

  ];


  @override
  void initState() {
    super.initState();


    controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 3000,
      ),
    );


    startAnimation();
  }



  Future<void> startAnimation() async {


    // ظهور الشعار
    await Future.delayed(
      const Duration(
        milliseconds: 800,
      ),
    );


    // انفجار القطع
    setState(() {
      explode = true;
    });


    await controller.forward();


    // انتظار رجوع القطع
    await Future.delayed(
      const Duration(
        milliseconds: 500,
      ),
    );


    controller.reverse();


    await Future.delayed(
      const Duration(
        milliseconds: 1200,
      ),
    );


    widget.onFinished();

  }



  @override
  Widget build(BuildContext context) {


    return AnimatedBuilder(
      animation: controller,

      builder: (context, child) {


        return SizedBox(
          width: 330,
          height: 180,

          child: Stack(
            alignment: Alignment.center,

            children: List.generate(
              5,
              (index) {

                return buildPiece(index);

              },
            ),
          ),
        );
      },
    );
  }


Widget buildPiece(int index) {

  final Offset move =
      explode
          ? directions[index] *
              controller.value
          : Offset.zero;


  final double rotate =
      explode
          ? (index.isEven ? 1 : -1) *
              math.pi *
              controller.value
          : 0;


  return Transform.translate(

    offset: move,

    child: Transform.rotate(

      angle: rotate,

      child: ClipPath(

        clipper: PuzzlePieceClipper(
          index,
        ),

        child: Image.asset(

          "assets/images/ui/puzzle_world_splash.png",

          width: 330,

          height: 180,

          fit: BoxFit.contain,

        ),
      ),
    ),
  );
}