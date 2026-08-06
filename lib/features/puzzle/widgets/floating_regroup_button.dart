import 'dart:math';
import 'package:flutter/material.dart';

class FloatingRegroupButton extends StatefulWidget {
  final VoidCallback onPressed;

  const FloatingRegroupButton({
    super.key,
    required this.onPressed,
  });

  @override
  State<FloatingRegroupButton> createState() => _FloatingRegroupButtonState();
}

class _FloatingRegroupButtonState extends State<FloatingRegroupButton>
    with TickerProviderStateMixin {
  late AnimationController _moveController;
  late AnimationController _fadeController;
  late Animation<double> _rotation;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();

    // 1. متحكم حركة التجوال والدوران المستمرة طوال فترة ظهور الزر
    _moveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);

    _rotation = Tween<double>(
      begin: 0,
      end: pi * 2,
    ).animate(_moveController);

    // 2. متحكم الظهور والتلاشي عند إظهار وإخفاء الزر من الشاشة الرئيسية
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward(); // يبدأ بالظهور فور إنشائه

    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
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
        final screenWidth = MediaQuery.of(context).size.width;
        
        // حركة التجوال في الأعلى (تحت شريط الأدوات مباشرة وفوق لوحة البازل)
        final x = _moveController.value * (screenWidth - 100) + 20;
        final y = 110 + sin(_moveController.value * pi * 4) * 10;

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
              width: 55,
              height: 55,
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
