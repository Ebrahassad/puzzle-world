import 'package:flutter/material.dart';

import '../data/puzzle_data.dart';
import '../models/puzzle_model.dart';

import 'island_screen.dart';

import '../managers/puzzle_progress_manager.dart';
import '../widgets/game_toolbar.dart';


class WorldMapScreen extends StatefulWidget {

  const WorldMapScreen({
    super.key,
  });


  @override
  State<WorldMapScreen> createState() =>
      _WorldMapScreenState();

}





class _WorldMapScreenState
    extends State<WorldMapScreen>
    with TickerProviderStateMixin {



  // حركة طفو الجزر

  late AnimationController floatController;

  late Animation<double> floatAnimation;



  // حركة الخلفية

  late AnimationController backgroundController;

  late Animation<double> backgroundMove;

  late Animation<double> backgroundScale;



  String? pressedIsland;
final GlobalKey starKey = GlobalKey();


  final Map<String,String> islandImages = {


    "animals":
    "assets/images/islands/animals_island.png",


    "cars":
    "assets/images/islands/cars_island.png",


    "space":
    "assets/images/islands/space_island.png",


    "landmarks":
    "assets/images/islands/world_landmarks_island.png",


    "nature":
    "assets/images/islands/nature_island.png",


  };





  @override
  void initState() {

    super.initState();




    // حركة الجزر العائمة

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







    // حركة خفيفة للخلفية

    backgroundController = AnimationController(

      vsync: this,

      duration: const Duration(

        seconds: 20,

      ),

    )..repeat(

      reverse: true,

    );




    backgroundMove = Tween<double>(

      begin: -12,

      end: 12,

    ).animate(

      CurvedAnimation(

        parent: backgroundController,

        curve: Curves.easeInOut,

      ),

    );




    backgroundScale = Tween<double>(

      begin: 1.0,

      end: 1.04,

    ).animate(

      CurvedAnimation(

        parent: backgroundController,

        curve: Curves.easeInOut,

      ),

    );


  }


  void openWorld(PuzzleModel world){


    Navigator.push(

      context,


      PageRouteBuilder(


        transitionDuration:

        const Duration(

          milliseconds:700,

        ),



        pageBuilder:

            (_, animation, secondaryAnimation){



          return FadeTransition(


            opacity: animation,


            child: IslandScreen(

              island: world,

            ),


          );


        },


      ),


    );


  }







  void showLockedDialog(PuzzleModel world){



    showDialog(


      context: context,


      builder: (context){



        return AlertDialog(



          backgroundColor:

          const Color(0xff263238),




          shape:

          RoundedRectangleBorder(

            borderRadius:

            BorderRadius.circular(25),

          ),





          title: const Center(


            child: Text(


              "🔒 عالم مغلق",



              style: TextStyle(


                color: Colors.white,


                fontSize: 24,


                fontWeight: FontWeight.bold,


              ),


            ),


          ),





          content: const Text(



            "أكمل العوالم السابقة أو شاهد إعلان لفتح هذا العالم",



            textAlign: TextAlign.center,



            style: TextStyle(


              color: Colors.white70,


              fontSize: 17,


            ),



          ),






          actionsAlignment:

          MainAxisAlignment.center,



          actions: [




            ElevatedButton.icon(



              style:

              ElevatedButton.styleFrom(



                backgroundColor:

                Colors.orange,



                padding:

                const EdgeInsets.symmetric(

                  horizontal:20,

                  vertical:12,

                ),



                shape:

                RoundedRectangleBorder(

                  borderRadius:

                  BorderRadius.circular(20),

                ),


              ),




              icon:

              const Icon(

                Icons.play_circle,

                color: Colors.white,

              ),





              label:

              const Text(



                "شاهد إعلان لفتح",



                style: TextStyle(

                  color: Colors.white,

                  fontWeight: FontWeight.bold,

                ),

              ),





              onPressed: (){



                Navigator.pop(context);



                unlockWithRewardAd(world);



              },


            ),






            TextButton(



              onPressed: (){



                Navigator.pop(context);



              },



              child: const Text(



                "إلغاء",



                style: TextStyle(

                  color: Colors.white70,

                ),

              ),


            ),




          ],



        );


      },


    );

  }









  void unlockWithRewardAd(PuzzleModel world){


    // هنا سيتم ربط Rewarded AdMob لاحقاً


    // عند اكتمال الإعلان:

    // 1- حفظ فتح العالم

    // 2- تحديث الخريطة

    // 3- فتح الجزيرة مباشرة



   PuzzleProgressManager.unlockIsland(
  world.id,
).then((_) {

  setState(() {});

  ScaffoldMessenger.of(context).showSnackBar(

    SnackBar(

      content: Text(
        "تم فتح ${world.title}",
      ),

    ),

  );

});




  }


  Widget islandButton(
  String id,
  double x,
  double y, {
  double size = 150,
}) {
  final world = PuzzleData.getById(id);

  if (world == null) {
    return const SizedBox();
  }

  return FutureBuilder<bool>(
    future: PuzzleProgressManager.isIslandUnlocked(id),
    builder: (context, snapshot) {

      final bool unlocked = snapshot.data ?? false;

      return Positioned(
        left: x - size / 2,
        top: y - size / 2,
        width: size,
        height: size,

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

          child: GestureDetector(

            onTapDown: (_) {
              setState(() {
                pressedIsland = id;
              });
            },


            onTapUp: (_) {

              setState(() {
                pressedIsland = null;
              });


              if (unlocked) {

                openWorld(world);

              } else {

                showLockedDialog(world);

              }

            },


            onTapCancel: () {

              setState(() {
                pressedIsland = null;
              });

            },


            child: AnimatedScale(

              scale: pressedIsland == id
                  ? 1.15
                  : 1.0,

              duration:
              const Duration(
                milliseconds:180,
              ),


              child: Stack(

                alignment: Alignment.center,

                children: [


                  Opacity(

                    opacity: unlocked
                        ? 1.0
                        : 0.45,


                    child: Image.asset(

                      islandImages[id]!,

                      fit: BoxFit.contain,

                    ),

                  ),



                  if (!unlocked)

                    Image.asset(

                      "assets/images/ui/level_lock.png",

                      width: size * 0.35,

                      fit: BoxFit.contain,

                    ),


                ],

              ),

            ),

          ),

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



          // خلفية العالم مع حركة بسيطة

          Positioned.fill(


            child: AnimatedBuilder(



              animation: backgroundController,



              builder: (context, child){



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




              child: Image.asset(



                "assets/images/world/world_map.png",



                fit: BoxFit.cover,



              ),



            ),



          ),







          // طبقة دمج خفيفة

          Container(



            color: Colors.black.withOpacity(0.08),



          ),







          SafeArea(



            child: LayoutBuilder(



              builder: (context, constraints){



                final width =

                constraints.maxWidth;



                final height =

                constraints.maxHeight;





                return Stack(



                  children: [






                    // جزيرة الفضاء - الأعلى في المنتصف

                    islandButton(



                      "space",



                      width * 0.50,



                      height * 0.13,



                      size: 180,



                    ),







                    // جزيرة الحيوانات - مفتوحة

                    islandButton(



                      "animals",



                      width * 0.32,



                      height * 0.48,



                      size: 155,



                    ),







                    // جزيرة المعالم - مقفلة

                    islandButton(



                      "landmarks",



                      width * 0.72,



                      height * 0.50,



                      size: 155,



                    ),







                    // جزيرة السيارات - مقفلة

                    islandButton(



                      "cars",



                      width * 0.25,



                      height * 0.78,



                      size: 155,



                    ),







                    // جزيرة الطبيعة - مقفلة

                    islandButton(



                      "nature",



                      width * 0.72,



                      height * 0.78,



                      size: 155,



                    ),





                  ],



                );



              },



            ),



          ),
Positioned(
  left: 0,
  right: 0,
  bottom: 10,

  child: GameToolbar(

    logo: "assets/images/ui/logo.png",

    stars: 0,

    coins: 0,

    rewards: 0,

    starKey: starKey,

  ),

),


        ],



      ),



    );


  }







  @override
  void dispose(){



    floatController.dispose();



    backgroundController.dispose();



    super.dispose();



  }