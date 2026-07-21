import 'package:flutter/material.dart';

import '../models/game_result_model.dart';
import '../models/reward_result_model.dart';

import '../managers/reward_manager.dart';
import '../services/reward_ad_service.dart';



class PuzzleWinScreen extends StatefulWidget {


  final GameResultModel result;

  final int difficulty;



  const PuzzleWinScreen({

    super.key,

    required this.result,

    this.difficulty = 1,

  });



  @override
  State<PuzzleWinScreen> createState() =>
      _PuzzleWinScreenState();

}





class _PuzzleWinScreenState
    extends State<PuzzleWinScreen> {


  RewardResultModel? reward;


  bool loading = true;


  bool adUsed = false;





  @override
  void initState() {


    super.initState();


    getReward();


  }






  Future<void> getReward() async {


    final result =

    await RewardManager.completePuzzle(


      difficulty: widget.difficulty,


    );



    setState((){


      reward = result;


      loading = false;


    });


  }







  Future<void> doubleReward() async {



    if(adUsed) return;



    final watched =

    await RewardAdService.showRewardAd();




    if(watched){



      await RewardManager.addCoins(

        reward!.coins,

      );



      if(reward!.gems > 0){


        await RewardManager.addGems(

          reward!.gems,

        );


      }



      setState((){


        reward = RewardResultModel(


          coins: reward!.coins * 2,


          gems: reward!.gems * 2,


        );



        adUsed = true;



      });



    }



  }








  @override
  Widget build(BuildContext context) {


    if(loading){


      return const Scaffold(


        body:Center(


          child:CircularProgressIndicator(),


        ),

      );


    }



    return Scaffold(


      body:Container(


        decoration:const BoxDecoration(


          gradient:LinearGradient(


            colors:[

              Color(0xffFFD166),

              Color(0xffFF9F1C),

            ],


          ),

        ),



        child:SafeArea(


          child:Center(


            child:Column(


              mainAxisAlignment:

              MainAxisAlignment.center,



              children:[



                const Text(


                  '🎉 أحسنت!',


                  style:TextStyle(


                    fontSize:45,

                    color:Colors.white,

                    fontWeight:FontWeight.bold,

                  ),

                ),




                const SizedBox(height:30),




                Text(


                  '🪙 +${reward!.coins}',


                  style:const TextStyle(


                    fontSize:35,

                    color:Colors.white,

                  ),

                ),




                if(reward!.gems > 0)

                  Text(


                    '💎 +${reward!.gems}',


                    style:const TextStyle(


                      fontSize:30,

                      color:Colors.white,

                    ),

                  ),





                const SizedBox(height:40),





                if(!adUsed)

                  ElevatedButton.icon(



                    onPressed:doubleReward,



                    icon:const Icon(

                      Icons.play_circle,

                    ),



                    label:const Text(


                      '🎬 مضاعفة المكافأة ×2',


                      style:TextStyle(

                        fontSize:18,

                      ),

                    ),



                  ),






                const SizedBox(height:20),




                ElevatedButton(



                  onPressed:(){


                    Navigator.pop(context);


                  },



                  child:const Text(


                    'متابعة 🧩',


                    style:TextStyle(

                      fontSize:20,

                    ),

                  ),


                ),



              ],


            ),


          ),

        ),

      ),

    );


  }

}