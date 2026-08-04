import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'island_screen.dart';
import 'world_map_screen.dart';


class FinalVictoryScreen extends StatefulWidget {
  final dynamic island;

  const FinalVictoryScreen({
    super.key,
    required this.island,
  });

  @override
  State<FinalVictoryScreen> createState() =>
      _FinalVictoryScreenState();
}


class _FinalVictoryScreenState extends State<FinalVictoryScreen>
    with TickerProviderStateMixin {


  late AnimationController _chestController;
  late AnimationController _gemController;
  late AnimationController _flashController;


  late Animation<double> _chestDrop;
  late Animation<double> _chestScale;
  late Animation<double> _shake;


  late Animation<double> _gemMove;
  late Animation<double> _gemScale;
  late Animation<double> _gemRotate;


  bool _opened = false;
  bool _showGem = false;


  @override
  void initState() {
    super.initState();


    _chestController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );


    _gemController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );


    _flashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );


    _chestDrop = Tween<double>(
      begin: -600,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: _chestController,
        curve: Curves.bounceOut,
      ),
    );


    _chestScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.6,
          end: 1.25,
        ),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.25,
          end: 1,
        ),
        weight: 40,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _chestController,
        curve: Curves.easeOut,
      ),
    );


    _shake = Tween<double>(
      begin: -0.08,
      end: 0.08,
    ).animate(
      CurvedAnimation(
        parent: _chestController,
        curve: const Interval(
          0.55,
          0.75,
          curve: Curves.easeInOut,
        ),
      ),
    );


    _gemMove = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _gemController,
        curve: Curves.easeInOutBack,
      ),
    );


    _gemScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.2,
          end: 1.5,
        ),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.5,
          end: 1,
        ),
        weight: 40,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _gemController,
        curve: Curves.elasticOut,
      ),
    );


    _gemRotate = Tween<double>(
      begin: 0,
      end: math.pi * 4,
    ).animate(
      CurvedAnimation(
        parent: _gemController,
        curve: Curves.easeOut,
      ),
    );


    _startAnimation();
  }



  Future<void> _startAnimation() async {

    await Future.delayed(
      const Duration(milliseconds: 500),
    );


    if (!mounted) return;

    _chestController.forward();


    await Future.delayed(
      const Duration(milliseconds: 2300),
    );


    if (!mounted) return;


    setState(() {
      _opened = true;
    });


    _flashController.forward();


    await Future.delayed(
      const Duration(milliseconds: 500),
    );


    if (!mounted) return;


    setState(() {
      _showGem = true;
    });


    _gemController.forward();

  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.black87,


      body: Stack(

        alignment: Alignment.center,

        children: [


          Container(

            decoration: const BoxDecoration(

              gradient: LinearGradient(

                begin: Alignment.topCenter,

                end: Alignment.bottomCenter,

                colors: [

                  Color(0xff081A3A),

                  Color(0xff020611),

                ],

              ),

            ),

          ),



          AnimatedBuilder(

            animation: _chestController,

            builder: (context, child) {


              return Transform.translate(

                offset: Offset(
                  0,
                  _chestDrop.value,
                ),


                child: Transform.scale(

                  scale: _chestScale.value,


                  child: Transform.rotate(

                    angle: _opened
                        ? 0
                        : _shake.value,


                    child: Image.asset(

                      _opened

                          ? "assets/images/rewards/final_chest_open.png"

                          : "assets/images/rewards/final_chest_closed.png",


                      width: 220,

                    ),

                  ),

                ),

              );

            },

          ),




          if (_showGem)

            AnimatedBuilder(

              animation: _gemController,

              builder: (context, child) {


                return Transform.translate(

                  offset: Offset(

                    0,

                    -180 * _gemMove.value,

                  ),


                  child: Transform.rotate(

                    angle: _gemRotate.value,


                    child: Transform.scale(

                      scale: _gemScale.value,


                      child: Image.asset(

                        "assets/images/rewards/gem.png",

                        width: 100,

                      ),

                    ),

                  ),

                );


              },

            ),





          if (_flashController.value > 0)

            Positioned.fill(

              child: AnimatedBuilder(

                animation: _flashController,

                builder: (_, __) {


                  return Container(

                    color: Colors.white.withOpacity(

                      _flashController.value,

                    ),

                  );


                },

              ),

            ),





          Positioned(

            bottom: 100,

            child: AnimatedOpacity(

              opacity: _showGem ? 1 : 0,

              duration: const Duration(milliseconds: 800),


              child: Column(

                children: [


                  const Text(

                    "WORLD COMPLETED",

                    style: TextStyle(

                      color: Colors.white,

                      fontSize: 28,

                      fontWeight: FontWeight.bold,

                    ),

                  ),


                  const SizedBox(height: 25),



                  ElevatedButton(

                    onPressed: () {


                      Navigator.pushAndRemoveUntil(

                        context,

                        MaterialPageRoute(

                          builder: (_) =>
                              const WorldMapScreen(),

                        ),

                        (route) => false,

                      );


                    },

                    child: const Text(

                      "CONTINUE",

                    ),

                  ),


                ],

              ),

            ),

          ),


        ],

      ),

    );

  }




  @override
  void dispose() {

    _chestController.dispose();

    _gemController.dispose();

    _flashController.dispose();

    super.dispose();

  }

}