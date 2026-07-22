import 'package:flutter/material.dart';

import '../models/game_result_model.dart';
import '../models/reward_result_model.dart';

import '../managers/reward_manager.dart';
import '../managers/puzzle_progress_manager.dart';

import '../services/puzzle_world_service.dart';
import '../services/puzzle_navigation_service.dart';
import '../services/puzzle_reward_ad_service.dart';
import '../services/puzzle_audio_service.dart';
import '../services/puzzle_event_service.dart';
import '../services/puzzle_statistics_service.dart';
import '../services/puzzle_achievement_service.dart';
import '../services/puzzle_cloud_service.dart';
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







class _PuzzleWinScreenState
    extends State<PuzzleWinScreen>
    with SingleTickerProviderStateMixin {



  RewardResultModel? reward;


  bool loading = true;


  bool adUsed = false;


  bool completedSaved = false;




  late AnimationController animationController;


  late Animation<double> scaleAnimation;







  @override
  void initState(){


    super.initState();



    animationController =

    AnimationController(

      vsync: this,

      duration:

      const Duration(seconds:1),

    )
      ..repeat(reverse:true);





    scaleAnimation =

    Tween<double>(

      begin:1,

      end:1.15,

    ).animate(


      CurvedAnimation(

        parent: animationController,

        curve: Curves.easeInOut,

      ),


    );





    initialize();



  }







  Future<void> initialize() async {



    await PuzzleAudioService.playWinSound();



    await saveCompletion();



    await loadReward();



  }







  //==================================================
  // حفظ نتيجة المرحلة مرة واحدة
  //==================================================


  Future<void> saveCompletion() async {



    if(completedSaved){

      return;

    }



    if(widget.worldId == null ||

        widget.level == null){


      return;


    }







    await PuzzleWorldService.completeLevel(


      worldId:

      widget.worldId!,



      level:

      widget.level!,



      stars:

      widget.result.stars,



    );








    await PuzzleStatisticsService.addCompletedPuzzle(


      stars:

      widget.result.stars,



      moves:

      widget.result.moves,



      seconds:

      widget.result.seconds,



    );







    await PuzzleSaveService.saveLastPlayed(


      worldId:

      widget.worldId!,



      levelId:

      "level_${widget.level}",



    );







    await PuzzleAchievementService.checkPuzzleAchievements(


      worldId:

      widget.worldId,



      level:

      widget.level,



      result:

      widget.result,



    );







    await PuzzleEventService.levelCompleted(


      worldId:

      widget.worldId,



      level:

      widget.level,



      stars:

      widget.result.stars,



      moves:

      widget.result.moves,



      seconds:

      widget.result.seconds,



    );







    await PuzzleCloudService.sync();






    completedSaved = true;



  }







  //==================================================
  // تحميل المكافأة
  //==================================================


  Future<void> loadReward() async {



    final result =

    await RewardManager.completePuzzle(


      difficulty:

      widget.difficulty,


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
  // 🎬 مضاعفة المكافأة بالإعلان
  //==================================================

  Future<void> doubleReward() async {


    if(adUsed || reward == null){

      return;

    }




    final watched =

    await PuzzleRewardAdService
        .watchAdForDoubleReward();




    if(!watched){

      return;

    }




    await PuzzleEventService.rewardDoubled(

      worldId: widget.worldId,

      level: widget.level,

      coins: reward!.coins,

      gems: reward!.gems,

    );






    await RewardManager.addCoins(

      reward!.coins,

    );





    if(reward!.gems > 0){

      await RewardManager.addGems(

        reward!.gems,

      );

    }





    if(!mounted){

      return;

    }





    setState((){


      reward = reward!.multiply(2);


      adUsed = true;


    });



  }






  //==================================================
  // الانتقال للمرحلة التالية
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


        worldId:

        widget.worldId!,



        currentLevel:

        widget.level!,



      );



    }


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







  @override
  void dispose(){


    animationController.dispose();


    super.dispose();


  }







  @override
  Widget build(BuildContext context){



    return Scaffold(



      body:

      Container(



        width:

        double.infinity,



        height:

        double.infinity,



        decoration:

        const BoxDecoration(



          gradient:

          LinearGradient(



            colors:[


              Color(0xff74EBD5),


              Color(0xffACB6E5),


            ],



            begin:

            Alignment.topCenter,



            end:

            Alignment.bottomCenter,



          ),



        ),





        child:

        SafeArea(



          child:

          loading



              ?

          const Center(



            child:

            CircularProgressIndicator(),



          )



              :

          SingleChildScrollView(



            child:

            Column(



              children:[



                const SizedBox(height:30),






                ScaleTransition(



                  scale:

                  scaleAnimation,



                  child:

                  const Text(



                    "⭐",



                    style:

                    TextStyle(



                      fontSize:100,


                    ),



                  ),



                ),






                const SizedBox(height:15),






                const Text(



                  "🎉 أحسنت! 🎉",



                  style:

                  TextStyle(



                    fontSize:36,


                    fontWeight:

                    FontWeight.bold,


                    color:

                    Colors.white,


                  ),



                ),






                const SizedBox(height:10),






                const Text(



                  "أكملت المرحلة بنجاح",



                  style:

                  TextStyle(



                    fontSize:22,


                    color:

                    Colors.white,


                  ),



                ),






                const SizedBox(height:25),






                resultCard(),





                const SizedBox(height:20),






                if(reward != null)

                  rewardCard(),






                const SizedBox(height:25),





                if(reward != null && !adUsed)

                  actionButton(


                    "🎬 مضاعفة المكافأة",


                    Colors.orange,


                    doubleReward,


                  ),





                const SizedBox(height:15),





                actionButton(


                  "➡️ المرحلة التالية",


                  Colors.green,


                  nextLevel,


                ),





                const SizedBox(height:15),





                actionButton(


                  "🧩 العودة للعالم",


                  Colors.blue,


                  backWorld,


                ),





                const SizedBox(height:15),





                actionButton(


                  "🏠 الرئيسية",


                  Colors.purple,


                  backHome,


                ),






                const SizedBox(height:40),



              ],



            ),



          ),



        ),



      ),



    );


  }

  //==================================================
  // بطاقة النتيجة
  //==================================================

  Widget resultCard(){


    return Container(


      margin:

      const EdgeInsets.symmetric(

        horizontal:25,

      ),


      padding:

      const EdgeInsets.all(20),


      decoration:

      BoxDecoration(


        color:

        Colors.white,


        borderRadius:

        BorderRadius.circular(25),


        boxShadow:[


          BoxShadow(


            color:

            Colors.black.withOpacity(.15),


            blurRadius:

            15,


            offset:

            const Offset(0,8),


          ),


        ],


      ),



      child:

      Column(


        children:[



          Text(


            "⭐ النجوم: ${widget.result.stars}",


            style:

            const TextStyle(


              fontSize:24,


              fontWeight:

              FontWeight.bold,


            ),


          ),





          const SizedBox(height:12),





          Text(


            "🧩 الحركات: ${widget.result.moves}",


            style:

            const TextStyle(


              fontSize:18,


            ),


          ),





          const SizedBox(height:8),





          Text(


            "⏱ الوقت: ${widget.result.seconds} ثانية",


            style:

            const TextStyle(


              fontSize:18,


            ),


          ),



        ],


      ),


    );


  }







  //==================================================
  // بطاقة المكافأة
  //==================================================

  Widget rewardCard(){


    return Container(


      margin:

      const EdgeInsets.symmetric(

        horizontal:25,

      ),


      padding:

      const EdgeInsets.all(20),



      decoration:

      BoxDecoration(


        color:

        Colors.white,


        borderRadius:

        BorderRadius.circular(25),


        boxShadow:[


          BoxShadow(


            color:

            Colors.black.withOpacity(.15),


            blurRadius:

            15,


            offset:

            const Offset(0,8),


          ),


        ],


      ),




      child:

      Row(


        mainAxisAlignment:

        MainAxisAlignment.spaceAround,



        children:[



          Column(


            children:[



              const Text(


                "🪙",


                style:

                TextStyle(


                  fontSize:40,


                ),


              ),





              Text(


                "${reward!.coins}",


                style:

                const TextStyle(


                  fontSize:24,


                  fontWeight:

                  FontWeight.bold,


                ),


              ),



            ],


          ),





          Column(


            children:[



              const Text(


                "💎",


                style:

                TextStyle(


                  fontSize:40,


                ),


              ),





              Text(


                "${reward!.gems}",


                style:

                const TextStyle(


                  fontSize:24,


                  fontWeight:

                  FontWeight.bold,


                ),


              ),



            ],


          ),



        ],


      ),


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


      padding:

      const EdgeInsets.symmetric(

        horizontal:35,

      ),



      child:

      SizedBox(



        width:

        double.infinity,



        height:

        55,



        child:

        ElevatedButton(



          onPressed:

          onTap,



          style:

          ElevatedButton.styleFrom(



            backgroundColor:

            color,



            foregroundColor:

            Colors.white,



            elevation:

            8,



            shadowColor:

            Colors.black38,



            shape:

            RoundedRectangleBorder(



              borderRadius:

              BorderRadius.circular(30),



            ),



          ),



          child:

          Text(



            text,



            style:

            const TextStyle(



              fontSize:20,


              fontWeight:

              FontWeight.bold,


            ),



          ),



        ),



      ),


    );


  }


}