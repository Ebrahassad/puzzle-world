import 'dart:async';
import 'package:flutter/material.dart';

import 'features/puzzle/screens/puzzle_home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController scaleController;
  late AnimationController fadeController;
  late AnimationController rotateController;

  late Animation<double> scaleAnimation;
  late Animation<double> fadeAnimation;
  late Animation<double> rotateAnimation;

  @override
  void initState() {
    super.initState();

    scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );

    scaleAnimation = Tween<double>(
      begin: 0.90,
      end: 1.08,
    ).animate(
      CurvedAnimation(
        parent: scaleController,
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

    rotateAnimation = Tween<double>(
      begin: -0.02,
      end: 0.02,
    ).animate(
      CurvedAnimation(
        parent: rotateController,
        curve: Curves.easeInOut,
      ),
    );

    fadeController.forward();

    scaleController.repeat(reverse: true);

    rotateController.repeat(reverse: true);

    Timer(
      const Duration(seconds: 4),
      () {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const PuzzleHomeScreen(),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    scaleController.dispose();
    fadeController.dispose();
    rotateController.dispose();
    super.dispose();
  }

  Widget buildStar() {
    return FadeTransition(
      opacity: fadeAnimation,
      child: AnimatedBuilder(
        animation: rotateAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: rotateAnimation.value,
            child: ScaleTransition(
              scale: scaleAnimation,
              child: child,
            ),
          );
        },
        child: Image.asset(
          "assets/icon/app_icon.png",
          width: 230,
          height: 230,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [

          /// الخلفية
          Image.asset(
            "assets/images/background/home_background.png",
            fit: BoxFit.cover,
          ),

          /// طبقة شفافة خفيفة
          Container(
            color: Colors.black.withOpacity(0.15),
          ),

          /// نجوم في الخلفية
          Positioned(
            top: 60,
            left: 40,
            child: Icon(
              Icons.star,
              color: Colors.yellow.withOpacity(0.8),
              size: 22,
            ),
          ),

          Positioned(
            top: 130,
            right: 60,
            child: Icon(
              Icons.star,
              color: Colors.white.withOpacity(0.8),
              size: 18,
            ),
          ),

          Positioned(
            bottom: 180,
            left: 70,
            child: Icon(
              Icons.star,
              color: Colors.orange.withOpacity(0.9),
              size: 20,
            ),
          ),

          Positioned(
            bottom: 100,
            right: 45,
            child: Icon(
              Icons.star,
              color: Colors.yellow.withOpacity(0.7),
              size: 26,
            ),
          ),

          /// الأيقونة في المنتصف
          Center(
            child: buildStar(),
          ),

          /// اسم اللعبة
          const Positioned(
            bottom: 120,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Puzzle World",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// عبارة ترحيب
          const Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Let's Play & Learn",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}