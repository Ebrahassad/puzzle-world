import 'package:flutter/material.dart';

import '../data/puzzle_level_data.dart';
import '../data/island_background_data.dart';

import '../models/puzzle_model.dart';
import '../models/puzzle_level_model.dart';



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
      end: 1.03,
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

  Widget levelButton(int level) {
    return GestureDetector(
      onTap: () {
        openLevel(level);
      },
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.25),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: Text(
            "$level",
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
      ),
    );
  }

  //==================================================
  // BUILD
  //==================================================

  @override
  Widget build(BuildContext context) {
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
                opacity: 0.40,
                child: Image.asset(
                  IslandBackgroundData.getBackground(
                    widget.island.id,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          // طبقة دمج خفيفة
          Container(
            color: Colors.white.withOpacity(0.15),
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
            top: 85,
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
              child: Image.asset(
                widget.island.image,
                height: 340,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) {
                  return const SizedBox();
                },
              ),
            ),
          ),

          //==================================================
          // اسم الجزيرة
          //==================================================

          Positioned(
            top: 360,
            left: 20,
            right: 20,
            child: Text(
              widget.island.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: islandTitleColor(),
                fontSize: 30,
                fontWeight: FontWeight.w900,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
            ),
          ),

          //==================================================
          // شبكة المراحل
          //==================================================

          Positioned(
            top: 470,
            left: 20,
            right: 20,
            bottom: 20,
            child: GridView.builder(
              padding: const EdgeInsets.only(
                top: 20,
                bottom: 20,
              ),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 22,
                mainAxisSpacing: 22,
              ),
              itemCount: widget.island.totalLevels,
              itemBuilder: (context, index) {
                return levelButton(
                  index + 1,
                );
              },
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