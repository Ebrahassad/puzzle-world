import 'package:flutter/material.dart';

import '../models/game_result_model.dart';
import '../models/reward_result_model.dart';

import '../managers/reward_manager.dart';

import '../services/puzzle_world_service.dart';
import '../services/puzzle_navigation_service.dart';
import '../services/puzzle_reward_ad_service.dart';
import '../services/puzzle_audio_service.dart';
import '../services/puzzle_event_service.dart';
import '../services/puzzle_statistics_service.dart';
import '../services/puzzle_achievement_service.dart';
import '../services/puzzle_save_service.dart';



class PuzzleWinScreen extends StatefulWidget {


  final GameResultModel result;

  final int difficulty;

  final String? worldId;

  final int? level;

  final VoidCallback? onNextLevel;

  final VoidCallback? onBackToWorld;

  final VoidCallback? onBackToHome;



  const PuzzleWinScreen({

    super.key,

    required this.result,

    this.difficulty = 1,

    this.worldId,

    this.level,

    this.onNextLevel,

    this.onBackToWorld,

    this.onBackToHome,

  });



  @override
  State<PuzzleWinScreen> createState() =>
      _PuzzleWinScreenState();


}






class _PuzzleWinScreenState extends State<PuzzleWinScreen>
    with SingleTickerProviderStateMixin {


  RewardResultModel? reward;


  bool loading = true;

  bool adUsed = false;

  bool saved = false;



  late AnimationController animationController;

  late Animation<double> scaleAnimation;



  @override
  void initState(){


    super.initState();



    animationController = AnimationController(

      vsync: this,

      duration: const Duration(seconds:1),

    )
      ..repeat(reverse:true);




    scaleAnimation = Tween<double>(

      begin:1,

      end:1.12,

    ).animate(

      CurvedAnimation(

        parent:animationController,

        curve:Curves.easeInOut,

      ),

    );



    initialize();


  }

 id="pws2"
  Future<void> initialize() async {


    await PuzzleAudioService.playWinSound();


    await saveCompletion();


    await loadReward();


  }







  //==================================================
  // حفظ إكمال المرحلة
  //==================================================

  Future<void> saveCompletion() async {



    if(saved){

      return;

    }





    if(widget.worldId == null ||
        widget.level == null){

      return;

    }






    await PuzzleWorldService.completeLevel(


      worldId: widget.worldId!,


      level: widget.level!,


      stars: widget.result.stars,


    );







    await PuzzleStatisticsService.addCompletedPuzzle(


      stars: widget.result.stars,


      moves: widget.result.moves,


      seconds: widget.result.seconds,


    );








    await PuzzleSaveService.saveLastPlayed(


      worldId: widget.worldId!,


      levelId: "level_${widget.level}",


    );








    await PuzzleAchievementService.checkPuzzleAchievements(


      worldId: widget.worldId,


      level: widget.level,


      result: widget.result,


    );








    await PuzzleEventService.levelCompleted(


      worldId: widget.worldId,


      level: widget.level,


      stars: widget.result.stars,


      moves: widget.result.moves,


      seconds: widget.result.seconds,


    );






    saved = true;



  }








  //==================================================
  // تحميل مكافأة المستوى
  //==================================================

  Future<void> loadReward() async {



    final result = await RewardManager.completePuzzle(


      difficulty: widget.difficulty,


      rewardKey:
      "${widget.worldId}_level_${widget.level}",


    );





    if(!mounted){

      return;

    }






    setState((){


      reward = result;


      loading = false;



    });



  }








  //==================================================
  // مضاعفة المكافأة بالإعلان
  //==================================================

  Future<void> doubleReward() async {



    if(adUsed || reward == null){

      return;

    }





    final watched = await PuzzleRewardAdService

        .watchAdForDoubleReward();






    if(!watched){

      return;

    }






    await PuzzleEventService.rewardDoubled(


      coins: reward!.coins,


      gems: reward!.gems,


    );







    if(!mounted){

      return;

    }







    setState((){


      reward = reward!.multiply(2);


      adUsed = true;



    });



  }








  //==================================================
  // المرحلة التالية
  //==================================================

  Future<void> nextLevel() async {



    if(widget.onNextLevel != null){


      widget.onNextLevel!();


      return;


    }







    if(widget.worldId != null &&
        widget.level != null){



      await PuzzleNavigationService.openNextLevel(


        context,


        worldId: widget.worldId!,


        currentLevel: widget.level!,


      );


    }



  }

  @override
  Widget build(BuildContext context){



    return Scaffold(



      body: Stack(



        children:[





          // خلفية شاشة الفوز

          Positioned.fill(


            child: Image.asset(


              "assets/images/background/win_background.png",


              fit: BoxFit.cover,


            ),


          ),








          SafeArea(



            child: loading



                ?



            const Center(


              child:CircularProgressIndicator(),


            )





                :



            Column(



              mainAxisAlignment:

              MainAxisAlignment.spaceBetween,



              children:[





                // الجزء العلوي

                Column(



                  children:[



                    const SizedBox(height:20),






                    ScaleTransition(



                      scale:scaleAnimation,



                      child:Image.asset(



                        "assets/images/ui/puzzle_logo.png",



                        width:90,



                        height:90,



                      ),



                    ),






                    const SizedBox(height:10),






                    const Text(



                      "🎉 أحسنت! 🎉",



                      style:TextStyle(



                        fontSize:34,



                        fontWeight:FontWeight.bold,



                        color:Colors.white,



                      ),



                    ),






                    const SizedBox(height:5),






                    const Text(



                      "أكملت المرحلة بنجاح",



                      style:TextStyle(



                        fontSize:20,



                        color:Colors.white,



                      ),



                    ),



                  ],



                ),











                // معلومات الفوز

                resultCard(),







                // الأزرار

                Column(



                  children:[





                    actionButton(


                      "➡️ المرحلة التالية",


                      Colors.green,


                      nextLevel,


                    ),






                    const SizedBox(height:10),







                    actionButton(


                      "🌍 العودة للعالم",


                      Colors.blue,


                      backWorld,


                    ),







                    const SizedBox(height:10),







                    actionButton(


                      "🏠 الرئيسية",


                      Colors.purple,


                      backHome,


                    ),







                    const SizedBox(height:15),





                  ],



                ),





              ],



            ),



          ),



        ],



      ),



    );



  }

//==================================================
// بطاقة النتيجة
//==================================================

Widget resultCard(){


  return Container(


    margin: const EdgeInsets.symmetric(
      horizontal:25,
    ),


    padding: const EdgeInsets.all(18),



    decoration: BoxDecoration(


      color:Colors.white.withOpacity(.90),


      borderRadius:BorderRadius.circular(25),



      boxShadow:[


        BoxShadow(


          color:Colors.black.withOpacity(.20),


          blurRadius:15,


          offset:const Offset(0,8),


        ),


      ],


    ),





    child:Column(


      children:[




        if(reward != null)


          Column(


            children:[



              Image.asset(


                "assets/images/rewards/Star_gold.png",


                width:65,


                height:65,


              ),





              Text(


                "+${widget.result.stars} Golden Star",


                style:const TextStyle(


                  fontSize:22,


                  fontWeight:FontWeight.bold,


                ),


              ),



              const SizedBox(height:12),


            ],


          ),






        Text(


          "🧩 الحركات: ${widget.result.moves}",


          style:const TextStyle(


            fontSize:18,


            fontWeight:FontWeight.bold,


          ),


        ),





        const SizedBox(height:8),





        Text(


          "⏱ الوقت: ${widget.result.seconds} ثانية",


          style:const TextStyle(


            fontSize:18,


          ),


        ),



      ],


    ),


  );


}









//==================================================
// العودة للعالم
//==================================================

Future<void> backWorld() async {



  if(widget.onBackToWorld != null){


    widget.onBackToWorld!();


    return;


  }




  Navigator.pop(context);


}









//==================================================
// العودة للرئيسية
//==================================================

Future<void> backHome() async {



  if(widget.onBackToHome != null){


    widget.onBackToHome!();


    return;


  }




  Navigator.popUntil(


    context,


    (route)=>route.isFirst,


  );


}









//==================================================
// زر موحد
//==================================================

Widget actionButton(

    String text,

    Color color,

    VoidCallback onTap,

    ){



  return Padding(


    padding:const EdgeInsets.symmetric(

      horizontal:35,

    ),




    child:SizedBox(


      width:double.infinity,


      height:52,




      child:ElevatedButton(



        onPressed:onTap,



        style:ElevatedButton.styleFrom(



          backgroundColor:color,



          foregroundColor:Colors.white,



          elevation:8,



          shape:RoundedRectangleBorder(



            borderRadius:

            BorderRadius.circular(30),



          ),



        ),




        child:Text(



          text,



          style:const TextStyle(



            fontSize:19,


            fontWeight:FontWeight.bold,


          ),



        ),



      ),


    ),


  );


}