import 'dart:math';
import 'package:flutter/material.dart';

class FloatingRegroupButton extends StatefulWidget {
  final VoidCallback onPressed;

  const FloatingRegroupButton({
    super.key,
    required this.onPressed,
  });

  @override
  State<FloatingRegroupButton> createState() =>
      _FloatingRegroupButtonState();
}

class _FloatingRegroupButtonState
    extends State<FloatingRegroupButton>
    with TickerProviderStateMixin {
  late AnimationController _moveController;
  late AnimationController _fadeController;

  late Animation<double> _rotation;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    // ============================================================
    // 🎈 حركة التجوال والدوران
    //
    // الدوران أصبح أبطأ:
    // 30 ثانية لدورة كاملة
    // ============================================================

    _moveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat(reverse: true);

    _rotation = Tween<double>(
      begin: 0,
      end: pi * 2,
    ).animate(
      CurvedAnimation(
        parent: _moveController,
        curve: Curves.linear,
      ),
    );

    // ============================================================
    // ✨ الظهور والتلاشي
    // ============================================================

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _opacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _moveController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _moveController,
      builder: (context, child) {
        final screenWidth =
            MediaQuery.of(context).size.width;

        // ========================================================
        // 📍 حركة الزر
        //
        // تم رفع الزر قليلاً.
        // ========================================================

        final x =
            _moveController.value *
                (screenWidth - 100) +
            15;

        final y =
            90 +
            sin(
                  _moveController.value *
                      pi *
                      4,
                ) *
                8;

        return Positioned(
          left: x,
          top: y,
          child: child!,
        );
      },

      child: FadeTransition(
        opacity: _opacity,

        child: RotationTransition(
          turns: _rotation,

          child: GestureDetector(
            onTap: widget.onPressed,

            child: SizedBox(
              // ==================================================
              // 🔽 تصغير الزر
              // ==================================================

              width: 70,
              height: 70,

              child: Image.asset(
                "assets/images/ui/regroup_icon.png",
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}