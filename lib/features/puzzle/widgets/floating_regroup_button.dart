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
    with SingleTickerProviderStateMixin {


  late AnimationController controller;

  late Animation<double> rotation;


  @override
  void initState() {
    super.initState();


    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat(reverse: true);


    rotation = Tween<double>(
      begin: 0,
      end: pi * 2,
    ).animate(controller);

  }



  @override
  Widget build(BuildContext context) {

    return AnimatedBuilder(
      animation: controller,

      builder: (context, child) {

        final screenWidth = MediaQuery.of(context).size.width;

        final x = controller.value * (screenWidth + 130) - 80;

        final y = 180 + sin(controller.value * pi * 4) * 80;


        return Positioned(
          left: x,
          top: y,

          child: child!,
        );

      },


      child: RotationTransition(
        turns: rotation,

        child: GestureDetector(

          onTap: widget.onPressed,

          child: Container(

            width: 65,
            height: 65,

            decoration: BoxDecoration(

              shape: BoxShape.circle,

              color: Colors.white,

              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 3,
                ),
              ],

            ),


            child: Padding(

              padding: const EdgeInsets.all(8),

              child: Image.asset(
                "assets/images/ui/regroup_icon.png",
              ),

            ),

          ),

        ),

      ),
    );

  }



  @override
  void dispose() {

    controller.dispose();

    super.dispose();

  }

}
