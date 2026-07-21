import 'package:flutter/material.dart';

import '../models/game_result_model.dart';
import '../models/reward_result_model.dart';

import '../managers/reward_manager.dart';



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



  @override
  void initState(){


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






  @override
  Widget build(BuildContext context) {


    return Scaffold(



      body:Container(



        decoration:const BoxDecoration(



          gradient:LinearGradient(



            colors:[

              Color(0xffFFD166),

              Color(0xffFF9F1C),

            ],



            begin:Alignment.topCenter,


            end:Alignment.bottomCenter,



          ),



        ),





        child:SafeArea(



          child:Center(



            child:loading



                ? const CircularProgressIndicator()



                :Column(



              mainAxisAlignment:

              MainAxisAlignment.center,



              children:[



                const Text(



                  '🎉 أحسنت!',



                  style:TextStyle(



                    color:Colors.white,


                    fontSize:45,


                    fontWeight:FontWeight.bold,



                  ),



                ),





                const SizedBox(height:25),





                Row(



                  mainAxisAlignment:

                  MainAxisAlignment.center,



                  children:



                  List.generate(



                    widget.result.stars,



                        (index)=>const Icon(



                      Icons.star,


                      color:Colors.yellow,


                      size:55,



                    ),



                  ),



                ),





                const SizedBox(height:35),





                Container(



                  padding:

                  const EdgeInsets.all(20),



                  decoration:BoxDecoration(



                    color:Colors.white24,



                    borderRadius:

                    BorderRadius.circular(25),



                  ),



                  child:Column(



                    children:[



                      Text(



                        '+ ${reward!.coins} 🪙',



                        style:const TextStyle(



                          color:Colors.white,


                          fontSize:28,


                          fontWeight:

                          FontWeight.bold,



                        ),



                      ),




                      if(reward!.gems > 0)

                        Text(



                          '+ ${reward!.gems} 💎',



                          style:const TextStyle(



                            color:Colors.white,


                            fontSize:28,



                          ),



                        ),



                    ],



                  ),



                ),





                const SizedBox(height:40),





                ElevatedButton(



                  style:

                  ElevatedButton.styleFrom(



                    padding:

                    const EdgeInsets.symmetric(



                      horizontal:50,


                      vertical:18,



                    ),



                    shape:

                    RoundedRectangleBorder(



                      borderRadius:

                      BorderRadius.circular(30),



                    ),



                  ),




                  onPressed:(){



                    Navigator.pop(context);



                  },



                  child:const Text(



                    'متابعة 🧩',



                    style:

                    TextStyle(



                      fontSize:22,



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