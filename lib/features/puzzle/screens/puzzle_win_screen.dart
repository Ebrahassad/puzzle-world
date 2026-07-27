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
      ..repeat(reverse:true);






    scaleAnimation = Tween<double>(

      begin:1,

      end:1.08,

    ).animate(

      CurvedAnimation(

        parent:animationController,

        curve:Curves.easeInOut,

      ),

    );





    initialize();


  }








  Future<void> initialize() async {


    await PuzzleAudioService.playWinSound();


    await saveCompletion();


    await loadReward();


  }








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



      backgroundColor:Colors.transparent,



      body:Stack(



        children:[





          // الخلفية الأصلية مع شفافية

          Positioned.fill(



            child:Image.asset(



              "assets/images/background/win_background.png",



              fit:BoxFit.cover,



            ),



          ),







          // طبقة شفافة لتحسين وضوح النص

          Positioned.fill(



            child:Container(



              color:Colors.black.withOpacity(0.25),



            ),



          ),







          SafeArea(



            child:loading



                ?



            const Center(



              child:CircularProgressIndicator(),



            )





                :



            Column(



              children:[







                const SizedBox(height:70),







                // رسالة الفوز بدون لوقو

                ScaleTransition(



                  scale:scaleAnimation,



                  child:const Text(



                    "أحسنت! أكملت المرحلة",



                    textAlign:TextAlign.center,



                    style:TextStyle(



                      fontSize:30,


                      fontWeight:FontWeight.bold,


                      color:Colors.black,



                    ),



                  ),



                ),







                const SizedBox(height:25),







                // النجوم

                resultCard(),







                const SizedBox(height:15),







                // المعلومات على الخلفية

                Text(



                  "الحركات: ${widget.result.moves}",



                  style:const TextStyle(



                    fontSize:19,


                    fontWeight:FontWeight.bold,


                    color:Colors.black,



                  ),



                ),






                const SizedBox(height:8),






                Text(



                  "الوقت: ${widget.result.seconds} ثانية",



                  style:const TextStyle(



                    fontSize:19,


                    fontWeight:FontWeight.bold,


                    color:Colors.black,



                  ),



                ),







                const Spacer(),







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


  Widget resultCard(){


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



          BoxShadow(



            color:

            Colors.black26,



            blurRadius:12,



            offset:

            const Offset(0,6),



          ),



        ],



      ),






      child:Column(



        children:[





          Image.asset(



            "assets/images/rewards/Star_gold.png",



            width:55,



            height:55,



          ),







          const SizedBox(height:5),







          Text(



            "+${widget.result.stars} Golden Star",



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









  Future<void> backWorld() async {



    if(widget.onBackToWorld != null){


      widget.onBackToWorld!();


      return;


    }






    Navigator.pop(context);



  }









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









  Widget actionButton(



      String text,



      Color color,



      VoidCallback onTap,



      ){





    return SizedBox(



      width:145,



      height:45,



      child:

      ElevatedButton(



        onPressed:onTap,



        style:

        ElevatedButton.styleFrom(



          backgroundColor:color,



          foregroundColor:Colors.white,



          elevation:6,



          padding:

          EdgeInsets.zero,



          shape:

          RoundedRectangleBorder(



            borderRadius:

            BorderRadius.circular(22),



          ),



        ),




        child:

        Text(



          text,



          textAlign:

          TextAlign.center,



          style:

          const TextStyle(



            fontSize:15,



            fontWeight:

            FontWeight.bold,



          ),



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