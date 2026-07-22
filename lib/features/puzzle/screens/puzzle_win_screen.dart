import 'package:flutter/material.dart';

import '../models/game_result_model.dart';
import '../models/reward_result_model.dart';


// Managers
import '../managers/puzzle_progress_manager.dart';
import '../managers/reward_manager.dart';


// Services
import '../services/puzzle_audio_service.dart';
import '../services/puzzle_event_service.dart';
import '../services/puzzle_cloud_service.dart';
import '../services/puzzle_navigation_service.dart';
import '../services/puzzle_reward_ad_service.dart';

import '../services/puzzle_world_service.dart';
import '../services/puzzle_save_service.dart';
import '../services/puzzle_statistics_service.dart';
import '../services/puzzle_achievement_service.dart';



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



  late AnimationController animationController;


  late Animation<double> scaleAnimation;







  String? get levelKey {


    if(widget.worldId == null ||
        widget.level == null){

      return null;

    }



    return "${widget.worldId}_level_${widget.level}";


  }







  @override
  void initState(){

    super.initState();



    animationController =
        AnimationController(

      vsync:this,

      duration:
      const Duration(seconds:1),

    )
          ..repeat(
              reverse:true);



    scaleAnimation =
        Tween<double>(

          begin:1,

          end:1.15,

        ).animate(

          CurvedAnimation(

            parent:
            animationController,

            curve:
            Curves.easeInOut,

          ),

        );




    enterScreen();


    completeLevel();


  }







  Future<void> enterScreen() async {


    await PuzzleAudioService.playWinSound();



    await PuzzleEventService.levelScreenOpened(

      worldId: widget.worldId,

      level: widget.level,

    );


  }







  Future<void> completeLevel() async {


    RewardResultModel result =
    const RewardResultModel(

      coins:0,

      gems:0,

    );



    final id = levelKey;



    if(id != null){


      final completed =

      await PuzzleProgressManager
          .isCompleted(id);



      if(!completed){



        await PuzzleProgressManager
            .completeLevel(id);



        await PuzzleProgressManager
            .unlockNextLevel(id);



        


        await afterCompleted();



      }






      final claimed =

      await PuzzleProgressManager
          .isRewardClaimed(id);



      if(!claimed){



        result =
        await RewardManager.completePuzzle(

          difficulty:
          widget.difficulty,

        );



        await PuzzleProgressManager
            .markRewardClaimed(id);



      }




    }else{


      result =
      await RewardManager.completePuzzle(

        difficulty:
        widget.difficulty,

      );


    }





    if(!mounted) return;



    setState((){


      reward = result;


      loading = false;



    });



  }


  //==================================================
  // بعد إكمال المرحلة
  // استخدام الخدمات الحديثة
  //==================================================

  Future<void> afterCompleted() async {


    await PuzzleStatisticsService.addCompletedPuzzle(

      stars: widget.result.stars,

      moves: widget.result.moves,

      seconds: widget.result.seconds,

    );




    if(widget.worldId != null &&
        widget.level != null){


      await PuzzleWorldService.completeLevel(

        worldId: widget.worldId!,

        level: widget.level!,

        stars: widget.result.stars,

      );



      await PuzzleSaveService.autoSavePuzzle(

        worldId: widget.worldId!,

        level: widget.level!,

      );




      await PuzzleAchievementService.checkPuzzleAchievements(

        worldId: widget.worldId,

        level: widget.level,

        result: widget.result,

      );



      await PuzzleCloudService.sync();



      await PuzzleEventService.levelCompleted(

        worldId: widget.worldId,

        level: widget.level,

        stars: widget.result.stars,

        moves: widget.result.moves,

        seconds: widget.result.seconds,

      );


    }



  }








  //==================================================
  // مضاعفة المكافأة بالإعلان
  //==================================================

  Future<void> doubleReward() async {



    if(adUsed ||
        reward == null){

      return;

    }





    final watched =
    await PuzzleRewardAdService.watchAdForDoubleReward();



    if(!watched){

      return;

    }





    final coins =
        reward!.coins;



    final gems =
        reward!.gems;






    await RewardManager.addCoins(

      coins,

    );





    if(gems > 0){


      await RewardManager.addGems(

        gems,

      );


    }






    if(!mounted) return;





    setState((){


      reward =
          reward!.multiply(2);



      adUsed = true;



    });





  }








  //==================================================
  // الانتقال للمرحلة التالية
  //==================================================

  Future<void> goNextLevel() async {



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



              Color(0xff7ED6FF),


              Color(0xffB8F2FF),



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



              ? const Center(



            child:

            CircularProgressIndicator(),



          )



              :

          SingleChildScrollView(



            child:

            Column(



              mainAxisAlignment:

              MainAxisAlignment.center,



              children:[







                const SizedBox(

                  height:30,

                ),







                // نجمة الفوز المتحركة

                ScaleTransition(



                  scale:

                  scaleAnimation,



                  child:

                  Container(



                    padding:

                    const EdgeInsets.all(20),



                    decoration:

                    BoxDecoration(



                      shape:

                      BoxShape.circle,



                      color:

                      Colors.white.withOpacity(.8),



                      boxShadow:[



                        BoxShadow(



                          color:

                          Colors.black.withOpacity(.15),



                          blurRadius:

                          20,



                          offset:

                          const Offset(0,8),



                        )



                      ],



                    ),



                    child:

                    const Icon(



                      Icons.star,



                      size:

                      90,



                      color:

                      Colors.amber,



                    ),



                  ),



                ),






                const SizedBox(

                  height:25,

                ),






                const Text(



                  "🎉 أحسنت! 🎉",



                  style:

                  TextStyle(



                    fontSize:

                    36,



                    fontWeight:

                    FontWeight.bold,



                    color:

                    Colors.white,



                  ),



                ),







                const SizedBox(

                  height:10,

                ),






                Text(



                  "لقد أكملت المرحلة بنجاح",



                  style:

                  TextStyle(



                    fontSize:

                    20,



                    color:

                    Colors.white.withOpacity(.9),



                  ),



                ),







                const SizedBox(

                  height:30,

                ),






                // بطاقة النتيجة

                Container(



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



                      )



                    ],



                  ),



                  child:

                  Column(



                    children:[



                      Text(



                        "⭐ النجوم: ${widget.result.stars}",



                        style:

                        const TextStyle(



                          fontSize:

                          24,



                          fontWeight:

                          FontWeight.bold,



                        ),



                      ),





                      const SizedBox(

                        height:12,

                      ),





                      Text(



                        "🚶 الحركات: ${widget.result.moves}",



                        style:

                        const TextStyle(



                          fontSize:

                          18,



                        ),



                      ),





                      const SizedBox(

                        height:8,

                      ),





                      Text(



                        "⏱ الوقت: ${widget.result.seconds} ثانية",



                        style:

                        const TextStyle(



                          fontSize:

                          18,



                        ),



                      ),



                    ],



                  ),



                ),







                const SizedBox(

                  height:20,

                ),






                if(reward != null)

                  rewardCard(),

                const SizedBox(

                  height:25,

                ),



                // زر مضاعفة المكافأة

                if(reward != null && !adUsed)

                  _actionButton(

                    text:

                    "🎬 مضاعفة المكافأة",

                    color:

                    Colors.orange,

                    onTap:

                    doubleReward,

                  ),






                const SizedBox(

                  height:15,

                ),






                // المرحلة التالية

                _actionButton(

                  text:

                  "➡️ المرحلة التالية",

                  color:

                  Colors.green,

                  onTap:

                  goNextLevel,

                ),






                const SizedBox(

                  height:15,

                ),





                // العودة للعالم

                _actionButton(

                  text:

                  "🧩 العودة للعالم",

                  color:

                  Colors.blue,

                  onTap:

                  backWorld,

                ),






                const SizedBox(

                  height:15,

                ),





                // الرئيسية

                _actionButton(

                  text:

                  "🏠 الرئيسية",

                  color:

                  Colors.purple,

                  onTap:

                  backHome,

                ),






                const SizedBox(

                  height:40,

                ),



              ],



            ),



          ),



        ),



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

            12,

          )



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

                  fontSize:35,

                ),

              ),


              Text(

                "${reward!.coins}",

                style:

                const TextStyle(

                  fontSize:22,

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

                  fontSize:35,

                ),

              ),



              Text(

                "${reward!.gems}",

                style:

                const TextStyle(

                  fontSize:22,

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

  Widget _actionButton({

    required String text,

    required Color color,

    required VoidCallback onTap,

  }){



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