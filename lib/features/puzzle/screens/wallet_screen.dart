import 'package:flutter/material.dart';

import '../managers/puzzle_progress_manager.dart';
import '../managers/reward_manager.dart';
import '../services/reward_ad_service.dart';



class WalletScreen extends StatefulWidget {


  const WalletScreen({

    super.key,

  });



  @override
  State<WalletScreen> createState() =>
      _WalletScreenState();

}







class _WalletScreenState extends State<WalletScreen> {


  int coins = 0;


  int gems = 0;


  int hints = 0;


  bool loading = true;






  @override
  void initState(){

    super.initState();

    loadWallet();

  }








  Future<void> loadWallet() async {



    final c =

    await RewardManager.getCoins();



    final g =

    await RewardManager.getGems();




    final h =

    await PuzzleProgressManager.getHints();





    if(mounted){


      setState((){



        coins = c;


        gems = g;


        hints = h;


        loading = false;



      });



    }



  }









  Future<void> addWallet() async {



    final watched =

    await RewardAdService.showRewardAd();





    if(!watched){

      return;

    }






    final reward =

    await RewardManager.rewardedAdBonus();





    await PuzzleProgressManager.addHints(

      5,

    );






    await loadWallet();






    if(mounted){



      ScaffoldMessenger.of(context)

          .showSnackBar(



        SnackBar(



          content:Text(



            "🎉 +${reward.coins} عملة و +5 تلميحات",

          ),



        ),



      );



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



      body:

      Container(



        decoration:

        const BoxDecoration(



          gradient:

          LinearGradient(



            colors:[



              Color(0xffFFD166),

              Color(0xffFF9F1C),



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

          Column(



            children:[



              const SizedBox(height:30),




              const Text(



                "👜 محفظتي",



                style:

                TextStyle(



                  color:Colors.white,

                  fontSize:38,

                  fontWeight:

                  FontWeight.bold,

                ),



              ),






              const SizedBox(height:40),







              Container(



                width:300,

                height:250,



                decoration:

                BoxDecoration(



                  color:

                  Colors.brown.shade400,



                  borderRadius:

                  BorderRadius.circular(35),



                  boxShadow:[



                    const BoxShadow(



                      color:

                      Colors.black26,



                      blurRadius:20,



                      offset:

                      Offset(0,12),



                    ),



                  ],



                ),





                child:

                Column(



                  mainAxisAlignment:

                  MainAxisAlignment.center,



                  children:[





                    Text(



                      "🪙 $coins",



                      style:

                      const TextStyle(



                        color:Colors.white,

                        fontSize:45,

                        fontWeight:

                        FontWeight.bold,



                      ),



                    ),






                    const SizedBox(height:10),






                    Text(



                      "💎 $gems",



                      style:

                      const TextStyle(



                        color:Colors.white,

                        fontSize:35,

                      ),



                    ),






                    const SizedBox(height:10),






                    Text(



                      "💡 $hints تلميحات",



                      style:

                      const TextStyle(



                        color:Colors.white,

                        fontSize:25,

                      ),



                    ),



                  ],



                ),



              ),







              const SizedBox(height:50),






              ElevatedButton.icon(



                onPressed:addWallet,



                icon:

                const Icon(

                  Icons.play_circle,

                  size:35,

                ),





                label:

                const Text(



                  "🎬 زيادة المحفظة",

                  style:

                  TextStyle(

                    fontSize:22,

                  ),



                ),





                style:

                ElevatedButton.styleFrom(



                  padding:

                  const EdgeInsets.symmetric(



                    horizontal:35,

                    vertical:18,



                  ),



                  shape:

                  RoundedRectangleBorder(



                    borderRadius:

                    BorderRadius.circular(30),



                  ),



                ),



              ),






              const SizedBox(height:20),






              const Text(



                "شاهد إعلان واحصل على عملات وتلميحات إضافية ✨",



                textAlign:

                TextAlign.center,



                style:

                TextStyle(



                  color:Colors.white,

                  fontSize:18,



                ),



              ),



            ],



          ),



        ),



      ),



    );



  }


}