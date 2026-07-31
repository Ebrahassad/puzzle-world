import 'package:flutter/material.dart';

import '../data/puzzle_level_data.dart';
import '../data/island_background_data.dart';

import '../models/puzzle_model.dart';
import '../models/puzzle_level_model.dart';

import '../widgets/level_path_painter.dart';

import 'puzzle_game_screen.dart';



class IslandScreen extends StatefulWidget {
  final PuzzleModel island;

  const IslandScreen({
    super.key,
    required this.island,
  });

  @override
  State<IslandScreen> createState() =>
      _IslandScreenState();
}





class _IslandScreenState
    extends State<IslandScreen>
    with TickerProviderStateMixin {

  //==================================================
  // TOP TOOLBAR KEY
  //==================================================

  

  //==================================================
  // FLOAT ANIMATION
  //==================================================

  late AnimationController floatController;
  late Animation<double> floatAnimation;

  //==================================================
  // BACKGROUND ANIMATION
  //==================================================

  late AnimationController backgroundController;
  late Animation<double> backgroundMove;
  late Animation<double> backgroundScale;

  //==================================================
  // TITLE COLOR
  //==================================================

  Color islandTitleColor() {
    switch (widget.island.id) {
      case "animals":
        return const Color(0xffB87928);

      case "cars":
        return const Color(0xff2196F3);

      case "space":
        return const Color(0xff8E44AD);

      case "nature":
        return const Color(0xff4CAF50);

      case "landmarks":
        return const Color(0xffD4AF37);

      default:
        return Colors.white;
    }
  }

  @override
  void initState() {
    super.initState();

    //==================================================
    // FLOAT ANIMATION
    //==================================================

    floatController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 3,
      ),
    )..repeat(
        reverse: true,
      );

    floatAnimation = Tween<double>(
      begin: -8,
      end: 8,
    ).animate(
      CurvedAnimation(
        parent: floatController,
        curve: Curves.easeInOut,
      ),
    );

    //==================================================
    // BACKGROUND ANIMATION
    //==================================================

    backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 20,
      ),
    )..repeat(
        reverse: true,
      );

    backgroundMove = Tween<double>(
      begin: -10,
      end: 10,
    ).animate(
      CurvedAnimation(
        parent: backgroundController,
        curve: Curves.easeInOut,
      ),
    );

    backgroundScale = Tween<double>(
      begin: 1.0,
      end: 1.01,

    ).animate(
      CurvedAnimation(
        parent: backgroundController,
        curve: Curves.easeInOut,
      ),
    );
  }

  //==================================================
  // OPEN LEVEL
  //==================================================

  void openLevel(int level) {

  final levels = PuzzleLevelData.getLevels(
    widget.island.id,
  );


  final selectedLevel = levels[level - 1];


  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => PuzzleGameScreen(
        puzzle: widget.island,
        level: selectedLevel,
      ),
    ),
  );

}

  //==================================================
  // LEVEL BUTTON
  //==================================================

  Widget levelButton({
  required int level,
  required bool unlocked,
  required bool completed,
}) {
  return GestureDetector(
    onTap: unlocked
        ? () {
            openLevel(level);
          }
        : null,

    child: Stack(
     alignment: const Alignment(0, 0.05),
      children: [

        // قطعة المرحلة
        Image.asset(
  "assets/images/ui/level_piece.png",
  width: 130,
  height: 130,
  fit: BoxFit.contain,
),

        // رقم المرحلة
        Text(
          "$level",
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            shadows: [
              Shadow(
                color: Colors.black54,
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),


        // القفل
        if (!unlocked)
          const Positioned(
            top: 10,
            child: Icon(
              Icons.lock,
              color: Colors.white,
              size: 28,
            ),
          ),


        // النجمة عند الإكمال
        if (completed)
          const Positioned(
            top: -5,
            child: Icon(
              Icons.star,
              color: Colors.amber,
              size: 35,
            ),
          ),

      ],
    ),
  );
}
  //==================================================
  // BUILD
  //==================================================

  @override
  Widget build(BuildContext context) {

final screenHeight = MediaQuery.of(context).size.height;
final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [

          //==================================================
          // خلفية الجزيرة
          //==================================================

          Positioned.fill(
  child: AnimatedBuilder(
    animation: backgroundController,
    builder: (context, child) {
      return Transform.scale(
        scale: backgroundScale.value,
        child: Transform.translate(
          offset: Offset(
            backgroundMove.value,
            0,
          ),
          child: child,
        ),
      );
    },

    child: Opacity(
      opacity: 0.75,
      child: Image.asset(
        IslandBackgroundData.getBackground(
          widget.island.id,
        ),
        fit: BoxFit.fill,
      ),
    ),
  ),
),
          // طبقة دمج خفيفة
          Container(
  color: Colors.white.withOpacity(0.05),
),
          //==================================================
          // الشريط العلوي
          //==================================================

          SafeArea(
  child: Padding(
    padding: const EdgeInsets.symmetric(
      horizontal:16,
      vertical:12,
    ),

    child: Row(
      mainAxisAlignment:
      MainAxisAlignment.spaceBetween,

      children:[

        // الإعدادات يسار
        CircleAvatar(
          radius:28,
          backgroundColor:
          Colors.black54,

          child:IconButton(
            icon:const Icon(
              Icons.settings,
              color:Colors.white,
            ),

            onPressed:(){

            },
          ),
        ),



        // رجوع
        CircleAvatar(
          radius:28,
          backgroundColor:
          Colors.black54,

          child:IconButton(
            icon:const Icon(
              Icons.arrow_back,
              color:Colors.white,
            ),

            onPressed:(){

              Navigator.pop(context);

            },
          ),
        ),

      ],
    ),
  ),
),

          //==================================================
          // صورة الجزيرة
          //==================================================

          Positioned(
  top: screenHeight * 0.10,
  left: 0,
  right: 0,

  child: AnimatedBuilder(
    animation: floatAnimation,

    builder: (context, child) {
      return Transform.translate(
        offset: Offset(
          0,
          floatAnimation.value,
        ),
        child: child,
      );
    },

    child: Opacity(
      opacity: 0.85,

      child: Image.asset(
        widget.island.image,

        height: screenHeight * 0.45,

        fit: BoxFit.contain,

        errorBuilder: (_, __, ___) {
          return const SizedBox();
        },
      ),
    ),
  ),
),
          
          
          //==================================================
// مسار المراحل
//==================================================
CustomPaint(
  size: Size(
    screenWidth,
    screenHeight,
  ),

  painter: LevelPathPainter(),
),


          Positioned(
            top: screenHeight * 0.58,
            left: 0,
            right: 0,
            bottom: screenHeight * 0.02,

            child: Stack(
              children: [

                Positioned(
                  left: screenWidth * 0.15,
                  top: 0,
                  child: levelButton(
                    level: 1,
                    unlocked: true,
                    completed: false,
                  ),
                ),

                Positioned(
                  right: screenWidth * 0.15,
                  top: screenHeight * 0.10,
                  child: levelButton(
                    level: 2,
                    unlocked: true,
                    completed: false,
                  ),
                ),

                Positioned(
                  left: screenWidth * 0.15,
                  top: screenHeight * 0.20,
                  child: levelButton(
                    level: 3,
                    unlocked: true,
                    completed: false,
                  ),
                ),

              ],
            ),
          ),

        ],
      ),
    );
  }


  //==================================================
  // DISPOSE
  //==================================================

  @override
  void dispose() {
    floatController.dispose();
    backgroundController.dispose();
    super.dispose();
  }
}