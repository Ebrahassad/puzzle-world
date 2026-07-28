import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'features/puzzle/screens/world_map_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
  });

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen>
    with TickerProviderStateMixin {

  late AnimationController logoController;
  late AnimationController fadeController;
  late AnimationController floatController;
  late AnimationController puzzleController;

  late Animation<double> logoScale;
  late Animation<double> logoFloat;
  late Animation<double> fadeAnimation;

  bool explode = false;

  final String title = "Puzzle World";

  final List<Offset> pieceOffsets = [
    const Offset(-80,-40),
    const Offset(-55,-90),
    const Offset(-15,-55),
    const Offset(25,-95),
    const Offset(70,-50),
    const Offset(95,-5),
    const Offset(70,55),
    const Offset(30,90),
    const Offset(-25,80),
    const Offset(-70,45),
    const Offset(-100,0),
    const Offset(105,35),
  ];

  @override
  void initState() {
    super.initState();

    logoController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 2,
      ),
    );

    fadeController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1200,
      ),
    );

    floatController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 3,
      ),
    );

    puzzleController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1400,
      ),
    );

    logoScale = Tween<double>(
      begin: 0.85,
      end: 1.08,
    ).animate(
      CurvedAnimation(
        parent: logoController,
        curve: Curves.elasticOut,
      ),
    );

    logoFloat = Tween<double>(
      begin: -10,
      end: 10,
    ).animate(
      CurvedAnimation(
        parent: floatController,
        curve: Curves.easeInOut,
      ),
    );

    fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: fadeController,
        curve: Curves.easeIn,
      ),
    );

    fadeController.forward();

    logoController.repeat(
      reverse: true,
    );

    floatController.repeat(
      reverse: true,
    );

    startAnimation();
  }

  Future<void> startAnimation() async {
    await Future.delayed(
      const Duration(
        seconds: 3,
      ),
    );

    if (!mounted) return;

    setState(() {
      explode = true;
    });

    await puzzleController.forward();

    await Future.delayed(
      const Duration(
        milliseconds: 500,
      ),
    );

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const WorldMapScreen(),
      ),
    );
  }

  Widget buildLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        logoController,
        floatController,
      ]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            0,
            logoFloat.value,
          ),
          child: Transform.scale(
            scale: logoScale.value,
            child: child,
          ),
        );
      },
      child: Image.asset(
        "assets/images/ui/puzzle_logo.png",
        width: 220,
        height: 220,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget buildPuzzleTitle() {
    return AnimatedBuilder(
      animation: puzzleController,
      builder: (context, child) {
        return Wrap(
          alignment: WrapAlignment.center,
          spacing: 0,
          children: List.generate(
            title.length,
            (index) {
              final letter = title[index];

              if (letter == " ") {
                return const SizedBox(width: 14);
              }

              final Offset target =
                  pieceOffsets[index % pieceOffsets.length];

              final Offset movement = explode
                  ? Offset(
                      target.dx * puzzleController.value,
                      target.dy * puzzleController.value,
                    )
                  : Offset.zero;

              final double rotation = explode
                  ? (index.isEven ? 1 : -1) *
                      math.pi *
                      puzzleController.value
                  : 0;

              return Transform.translate(
                offset: movement,
                child: Transform.rotate(
                  angle: rotation,
                  child: Opacity(
                    opacity: 1 - (0.25 * puzzleController.value),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 1,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 2,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xff2196F3),
                        borderRadius:
                            BorderRadius.circular(6),
                        border: Border.all(
                          color: Colors.white,
                          width: 1.5,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        letter,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          fontFamily: "Cairo",
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [

          // الخلفية
          Image.asset(
            "assets/images/background/home_background.png",
            fit: BoxFit.cover,
          ),

          // طبقة تعتيم خفيفة
          Container(
            color: Colors.black.withOpacity(0.18),
          ),

          // الشعار
          Positioned(
            top: MediaQuery.of(context).size.height * 0.20,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: fadeAnimation,
              child: Center(
                child: buildLogo(),
              ),
            ),
          ),

          // عنوان اللعبة
          Positioned(
            top: MediaQuery.of(context).size.height * 0.56,
            left: 20,
            right: 20,
            child: Center(
              child: buildPuzzleTitle(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    logoController.dispose();
    fadeController.dispose();
    floatController.dispose();
    puzzleController.dispose();

    super.dispose();
  }
}