import 'package:flutter/material.dart';

import '../models/game_result_model.dart';
import '../models/reward_result_model.dart';

import '../managers/reward_manager.dart';
import '../managers/puzzle_progress_manager.dart';

import '../services/reward_ad_service.dart';



class PuzzleWinScreen extends StatefulWidget {


  final GameResultModel result;


  final int difficulty;


  final String? worldId;


  final int? level;



  const PuzzleWinScreen({

    super.key,

    required this.result,

    this.difficulty = 1,

    this.worldId,

    this.level,

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

      end:1.15,

    ).animate(

      CurvedAnimation(

        parent:animationController,

        curve:Curves.easeInOut,

      ),

    );



    completeLevel();

  }









  Future<void> completeLevel() async {



    RewardResultModel rewardResult =

    RewardResultModel(

      coins:0,

      gems:0,

    );





    if(widget.level != null){



      final levelId =

      "${widget.worldId}_level_${widget.level}";





      final completed =

      await PuzzleProgressManager

          .isCompleted(

        levelId,

      );






      if(!completed){



        await PuzzleProgressManager

            .completeLevel(

          levelId,

        );





        await PuzzleProgressManager

            .unlockNextLevel(

          levelId,

        );





        await PuzzleProgressManager

            .addStars(

          widget.result.stars,

        );





      }






      final claimed =

      await PuzzleProgressManager

          .isRewardClaimed(

        levelId,

      );





      if(!claimed){



        rewardResult =

        await RewardManager.completePuzzle(

          difficulty:

          widget.difficulty,

        );





        await PuzzleProgressManager

            .markRewardClaimed(

          levelId,

        );



      }



    }else{



      rewardResult =

      await RewardManager.completePuzzle(

        difficulty:

        widget.difficulty,

      );



    }








    if(mounted){



      setState((){



        reward = rewardResult;


        loading=false;



      });



    }



  }









  Future<void> doubleReward() async {



    if(adUsed || reward == null){

      return;

    }






    final watched =

    await RewardAdService

        .showRewardAd();





    if(!watched){

      return;

    }






    final extraCoins = reward!.coins;


    final extraGems = reward!.gems;






    await RewardManager.addCoins(

      extraCoins,

    );





    if(extraGems > 0){



      await RewardManager.addGems(

        extraGems,

      );

    }






    setState((){



      reward = reward!.multiply(2);



      adUsed=true;



    });



  }









  @override
  void dispose(){



    animationController.dispose();



    super.dispose();



  }









  @override
  Widget build(BuildContext context){



    if(loading){



      return const Scaffold(



        body:Center(



          child:CircularProgressIndicator(),



        ),



      );



    }








    return Scaffold(



      body:Container(



        decoration:

        const BoxDecoration(



          gradient:

          LinearGradient(



            colors:[



              Color(0xffffd166),


              Color(0xffff9f1c),



            ],



            begin:

            Alignment.topCenter,



            end:

            Alignment.bottomCenter,



          ),



        ),





        child:SafeArea(



          child:Center(



            child:Column(



              mainAxisAlignment:

              MainAxisAlignment.center,



              children:[





                ScaleTransition(



                  scale:

                  scaleAnimation,



                  child:

                  const Text(



                    "🏆",



                    style:

                    TextStyle(



                      fontSize:90,



                    ),



                  ),



                ),






                const SizedBox(height:20),






                const Text(



                  "أحسنت! 🎉",



                  style:

                  TextStyle(



                    color:Colors.white,



                    fontSize:45,



                    fontWeight:

                    FontWeight.bold,



                  ),



                ),






                const SizedBox(height:30),






                rewardBox(),






                const SizedBox(height:30),





                if(!adUsed)



                  ElevatedButton.icon(



                    onPressed:

                    doubleReward,



                    icon:

                    const Icon(

                      Icons.play_circle,

                    ),



                    label:

                    const Text(

                      "🎬 مضاعفة المكافأة ×2",

                    ),



                  ),






                const SizedBox(height:20),






                ElevatedButton(



                  onPressed:(){



                    Navigator.pop(

                      context,

                      true,

                    );



                  },



                  child:

                  const Text(

                    "متابعة 🧩",

                  ),



                ),



              ],



            ),



          ),



        ),



      ),



    );



  }









  Widget rewardBox(){



    return Container(



      padding:

      const EdgeInsets.all(25),



      margin:

      const EdgeInsets.symmetric(

        horizontal:30,

      ),




      decoration:

      BoxDecoration(



        color:

        Colors.white,



        borderRadius:

        BorderRadius.circular(30),



        boxShadow:[



          BoxShadow(



            color:

            Colors.black26,



            blurRadius:15,



            offset:

            const Offset(0,8),



          ),



        ],



      ),




      child:

      Column(



        children:[





          Text(



            "⭐ +${widget.result.stars}",



            style:

            const TextStyle(

              fontSize:32,

            ),



          ),






          Text(



            "🪙 +${reward!.coins}",



            style:

            const TextStyle(

              fontSize:32,

            ),



          ),






          if(reward!.gems > 0)



            Text(



              "💎 +${reward!.gems}",



              style:

              const TextStyle(

                fontSize:30,

              ),



            ),



        ],



      ),



    );



  }



}