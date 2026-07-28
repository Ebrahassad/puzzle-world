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









class _PuzzleWinScreenState

    extends State<PuzzleWinScreen>

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

      vsync:this,

      duration:

      const Duration(seconds:1),

    )

      ..repeat(

        reverse:true,

      );







    scaleAnimation = Tween<double>(

      begin:1,

      end:1.08,

    ).animate(

      CurvedAnimation(

        parent:

        animationController,

        curve:

        Curves.easeInOut,

      ),

    );







    initialize();


  }









  Future<void> initialize() async {


    try {


      await PuzzleAudioService.playWinSound();



      await saveCompletion();



      await loadReward();





    }catch(e){



      if(mounted){


        setState((){


          loading = false;


        });


      }


    }


  }









  Future<void> saveCompletion() async {


    try {


      if(saved){

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







      saved = true;





    }catch(_){}



  }

  Future<void> loadReward() async {


    try {


      final key =

      (widget.worldId != null && widget.level != null)

          ? "${widget.worldId}_level_${widget.level}"

          : "default_reward";







      final result =

      await RewardManager.completePuzzle(

        difficulty:

        widget.difficulty,


        rewardKey:

        key,


      );







      if(!mounted){

        return;

      }







      setState((){


        reward = result;


        loading = false;


      });





    }catch(_){


      if(mounted){


        setState((){


          loading = false;


        });


      }


    }


  }









  Future<void> doubleReward() async {


    try {



      if(adUsed || reward == null){


        return;


      }







      final watched =

      await PuzzleRewardAdService

          .watchAdForDoubleReward();







      if(!watched){


        return;


      }







      final oldReward = reward!;







      await RewardManager.addCoins(

        oldReward.coins,

      );







      await RewardManager.addGems(

        oldReward.gems,

      );







      await RewardManager.addStars(

        oldReward.stars,

      );







      await PuzzleEventService.rewardDoubled(

        coins:

        oldReward.coins,


        gems:

        oldReward.gems,


      );







      if(!mounted){


        return;


      }







      setState((){


        reward = oldReward.multiply(2);


        adUsed = true;


      });







    }catch(_){}



  }









  Future<void> nextLevel() async {


    try {


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





    }catch(_){}



  }









  void backWorld(){


    if(widget.onBackToWorld != null){


      widget.onBackToWorld!();


      return;


    }



    Navigator.pop(context);


  }









  void backHome(){


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
  Widget build(BuildContext context){


    return Scaffold(


      backgroundColor:

      Colors.transparent,



      body:

      Stack(


        children:[



          Positioned.fill(


            child:

            Image.asset(

              "assets/images/background/win_background.png",

              fit:

              BoxFit.cover,

            ),

          ),





          Positioned.fill(


            child:

            Container(

              color:

              Colors.black.withOpacity(0.25),

            ),

          ),





          SafeArea(


            child:

            loading


                ? const Center(

              child:

              CircularProgressIndicator(),

            )



                : Column(



              children:[



                const SizedBox(height:70),





                ScaleTransition(


                  scale:

                  scaleAnimation,



                  child:

                  const Text(


                    "أحسنت! أكملت المرحلة 🎉",



                    textAlign:

                    TextAlign.center,



                    style:

                    TextStyle(

                      fontSize:30,

                      fontWeight:

                      FontWeight.bold,

                      color:

                      Colors.black,

                    ),

                  ),

                ),





                const SizedBox(height:25),





                resultCard(),





                const SizedBox(height:15),





                Text(


                  "الحركات: ${widget.result.moves}",


                  style:

                  const TextStyle(

                    fontSize:19,

                    fontWeight:

                    FontWeight.bold,

                    color:

                    Colors.black,

                  ),

                ),





                const SizedBox(height:8),





                Text(


                  "الوقت: ${widget.result.seconds} ثانية",


                  style:

                  const TextStyle(

                    fontSize:19,

                    fontWeight:

                    FontWeight.bold,

                    color:

                    Colors.black,

                  ),

                ),





                const SizedBox(height:15),





                if(reward != null)

                  rewardInfo(),





                const Spacer(),





                // المستوى التالي

                actionButton(

                  "🚀 المستوى التالي",

                  Colors.purple,

                  nextLevel,

                ),





                const SizedBox(height:12),





                if(!adUsed)

                  actionButton(

                    "🎁 مضاعفة المكافأة",

                    Colors.orange,

                    doubleReward,

                  ),





                const SizedBox(height:12),





                Row(


                  mainAxisAlignment:

                  MainAxisAlignment.center,



                  children:[



                    actionButton(

                      "العودة للجزيرة",

                      Colors.green,

                      backWorld,

                    ),





                    const SizedBox(width:10),





                    actionButton(

                      "العودة للعالم",

                      Colors.blue,

                      backHome,

                    ),



                  ],

                ),





                const SizedBox(height:30),



              ],

            ),


          ),



        ],

      ),


    );


  }

  Widget rewardInfo(){


    return Container(


      margin:

      const EdgeInsets.symmetric(

        horizontal:40,

      ),



      padding:

      const EdgeInsets.all(12),



      decoration:

      BoxDecoration(


        color:

        Colors.white.withOpacity(.85),



        borderRadius:

        BorderRadius.circular(20),


      ),





      child:

      Column(



        children:[



          Text(


            "🪙 العملات: ${reward!.coins}",


            style:

            const TextStyle(

              fontSize:18,

              fontWeight:

              FontWeight.bold,

              color:

              Colors.black,

            ),

          ),





          const SizedBox(height:5),





          Text(


            "💎 الجواهر: ${reward!.gems}",


            style:

            const TextStyle(

              fontSize:18,

              fontWeight:

              FontWeight.bold,

              color:

              Colors.black,

            ),

          ),





          const SizedBox(height:5),





          Text(


            "⭐ Golden Star: ${reward!.stars}",


            style:

            const TextStyle(

              fontSize:18,

              fontWeight:

              FontWeight.bold,

              color:

              Colors.black,

            ),

          ),



        ],



      ),


    );


  }









  Widget resultCard(){


    final stars =

    reward?.stars ?? widget.result.stars;





    return Container(


      margin:

      const EdgeInsets.symmetric(

        horizontal:40,

      ),



      padding:

      const EdgeInsets.all(15),



      decoration:

      BoxDecoration(



        color:

        Colors.white.withOpacity(.85),



        borderRadius:

        BorderRadius.circular(22),



        boxShadow:[



          const BoxShadow(

            color:

            Colors.black26,

            blurRadius:12,

            offset:

            Offset(0,6),

          ),



        ],



      ),





      child:

      Column(



        children:[



          Image.asset(



            "assets/images/rewards/Star_gold.png",



            width:55,

            height:55,



            errorBuilder:

                (_,__,___){



              return const Icon(

                Icons.star,

                size:55,

              );


            },



          ),





          const SizedBox(height:5),





          Text(


            "+$stars Golden Star",


            style:

            const TextStyle(

              color:

              Colors.black,

              fontSize:20,

              fontWeight:

              FontWeight.bold,

            ),



          ),



        ],



      ),



    );



  }









  Widget actionButton(


      String text,


      Color color,


      VoidCallback action,


      ){



    return ElevatedButton(



      onPressed:action,



      style:

      ElevatedButton.styleFrom(



        backgroundColor:

        color,



        padding:

        const EdgeInsets.symmetric(


          horizontal:22,


          vertical:12,


        ),



        shape:

        RoundedRectangleBorder(


          borderRadius:

          BorderRadius.circular(25),


        ),



        elevation:5,



      ),



      child:

      Text(


        text,



        style:

        const TextStyle(


          fontSize:16,


          fontWeight:

          FontWeight.bold,


          color:

          Colors.white,


        ),



      ),



    );


  }









  @override
  void dispose(){


    animationController.dispose();


    super.dispose();


  }



}