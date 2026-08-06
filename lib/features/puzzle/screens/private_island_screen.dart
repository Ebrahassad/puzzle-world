import 'package:flutter/material.dart';

import 'puzzle_game_screen.dart';

class PrivateIslandScreen extends StatefulWidget {
  final String? customImagePath;

  const PrivateIslandScreen({
    super.key,
    this.customImagePath,
  });

  @override
  State<PrivateIslandScreen> createState() =>
      _PrivateIslandScreenState();
}

class _PrivateIslandScreenState
    extends State<PrivateIslandScreen> {

  void openStudio() {
    // هنا سنضع اختيار الصورة من الجهاز
    // وبعد الاختيار نرجع إلى PuzzleGameScreen

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          // خلفية الجزيرة الخاصة
          Positioned.fill(
            child: Image.asset(
              "assets/images/islands/private_island.png",
              fit: BoxFit.cover,
            ),
          ),


          SafeArea(
            child: Column(
              children: [

                const SizedBox(height: 40),

                const Text(
                  "مملكتك الخاصة 👑",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),


                const Spacer(),


                // زر الاستوديو
                GestureDetector(
                  onTap: openStudio,
                  child: Container(
                    width: 180,
                    height: 80,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                      BorderRadius.circular(25),
                    ),
                    child: const Text(
                      "🧩 الاستوديو",
                      style: TextStyle(
                        fontSize: 24,
                      ),
                    ),
                  ),
                ),


                const SizedBox(height: 40),


                // أماكن المستويات
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [

                    levelButton(1),

                    levelButton(2),

                    levelButton(3),

                  ],
                ),


                const Spacer(),

              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget levelButton(int number) {
    return Container(
      margin: const EdgeInsets.all(8),
      width: 80,
      height: 80,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.amber,
        shape: BoxShape.circle,
      ),
      child: Text(
        "$number",
        style: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}