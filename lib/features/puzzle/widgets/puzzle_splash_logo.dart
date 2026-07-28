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
    with SingleTickerProviderStateMixin {


  late AnimationController controller;


  final List<Offset> piecesMove = [

    const Offset(-140, -90),
    const Offset(140, -80),
    const Offset(-130, 100),
    const Offset(130, 100),
    const Offset(0, -160),

  ];



  @override
  void initState() {

    super.initState();


    controller = AnimationController(

      vsync: this,

      duration: const Duration(
        milliseconds: 1800,
      ),

    );


    startAnimation();

  }




  Future<void> startAnimation() async {


    await Future.delayed(

      const Duration(
        milliseconds: 800,
      ),

    );


    // انفجار القطع

    await controller.forward();



    await Future.delayed(

      const Duration(
        milliseconds: 600,
      ),

    );


    // تجميع القطع

    await controller.reverse();



    await Future.delayed(

      const Duration(
        milliseconds: 700,
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

          width: 340,

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


    final movement = Offset.lerp(

      Offset.zero,

      piecesMove[index],

      controller.value,

    )!;



    final rotation =

        (index.isEven ? 1 : -1) *

        math.pi *

        controller.value;



    return Transform.translate(

      offset: movement,


      child: Transform.rotate(

        angle: rotation,


        child: ClipPath(

          clipper: PuzzleClipper(index),


          child: Image.asset(

            "assets/images/ui/puzzle_world_splash.png",

            width: 340,

            height: 180,

            fit: BoxFit.contain,

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







class PuzzleClipper extends CustomClipper<Path> {


  final int index;


  PuzzleClipper(this.index);



  @override
  Path getClip(Size size) {


    final path = Path();


    final halfW = size.width / 2;

    final halfH = size.height / 2;

    const tab = 18.0;



    switch(index) {



      case 0:

        // أعلى يسار

        path.moveTo(0,0);


        path.lineTo(
          halfW - tab,
          0,
        );


        path.quadraticBezierTo(
          halfW,
          0,
          halfW,
          tab,
        );


        path.lineTo(
          halfW,
          halfH - tab,
        );


        path.quadraticBezierTo(
          halfW,
          halfH,
          halfW - tab,
          halfH,
        );


        path.lineTo(
          0,
          halfH,
        );


        path.close();

        break;





      case 1:

        // أعلى يمين

        path.moveTo(
          halfW,
          0,
        );


        path.lineTo(
          size.width,
          0,
        );


        path.lineTo(
          size.width,
          halfH,
        );


        path.lineTo(
          halfW + tab,
          halfH,
        );


        path.quadraticBezierTo(
          halfW,
          halfH,
          halfW,
          halfH - tab,
        );


        path.lineTo(
          halfW,
          tab,
        );


        path.quadraticBezierTo(
          halfW,
          0,
          halfW + tab,
          0,
        );


        path.close();

        break;





      case 2:

        // أسفل يسار

        path.moveTo(
          0,
          halfH,
        );


        path.lineTo(
          halfW - tab,
          halfH,
        );


        path.quadraticBezierTo(
          halfW,
          halfH,
          halfW,
          halfH + tab,
        );


        path.lineTo(
          halfW,
          size.height,
        );


        path.lineTo(
          0,
          size.height,
        );


        path.close();

        break;





      case 3:

        // أسفل يمين

        path.moveTo(
          halfW,
          halfH,
        );


        path.quadraticBezierTo(
          halfW,
          halfH + tab,
          halfW + tab,
          halfH,
        );


        path.lineTo(
          size.width,
          halfH,
        );


        path.lineTo(
          size.width,
          size.height,
        );


        path.lineTo(
          halfW,
          size.height,
        );


        path.close();

        break;





      case 4:

        // القطعة الوسطى

        path.addOval(

          Rect.fromCenter(

            center: Offset(
              size.width / 2,
              size.height / 2,
            ),


            width: 100,

            height: 80,

          ),

        );

        break;

    }


    return path;

  }





  @override
  bool shouldReclip(
      covariant CustomClipper<Path> oldClipper,
  ) {

    return false;

  }

}