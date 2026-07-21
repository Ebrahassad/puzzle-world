import 'package:flutter/material.dart';

import '../managers/reward_manager.dart';
import '../managers/hint_manager.dart';
import '../services/reward_ad_service.dart';



class WalletScreen extends StatefulWidget {


  const WalletScreen({super.key});



  @override
  State<WalletScreen> createState() =>
      _WalletScreenState();

}





class _WalletScreenState
    extends State<WalletScreen> {


  int coins = 0;

  int gems = 0;

  int hints = 0;


  bool loading = true;





  @override
  void initState(){


    super.initState();


    loadData();


  }






  Future<void> loadData() async {


    final c =
    await RewardManager.getCoins();


    final g =
    await RewardManager.getGems();


    final h =
    await HintManager.getHints();




    setState((){


      coins = c;

      gems = g;

      hints = h;

      loading = false;


    });


  }







  Future<void> watchAd() async {


    final result =

    await RewardAdService.showRewardAd();



    if(result){



      await RewardManager.addCoins(100);


      await HintManager.addHints(1);



      loadData();



      ScaffoldMessenger.of(context)

          .showSnackBar(


        const SnackBar(


          content:Text(

            '🎉 حصلت على 100 عملة + تلميح',

          ),


        ),


      );


    }


  }







  @override
  Widget build(BuildContext context) {


    if(loading){


      return const Scaffold(


        body:

        Center(

          child:CircularProgressIndicator(),

        ),


      );


    }




    return Scaffold(



      body:Container(



        decoration:const BoxDecoration(



          gradient:LinearGradient(



            colors:[


              Color(0xff89F7FE),


              Color(0xff66A6FF),



            ],



            begin:Alignment.topCenter,


            end:Alignment.bottomCenter,



          ),



        ),






        child:SafeArea(



          child:Column(



            children:[



              const SizedBox(height:20),




              const Text(



                '👜 محفظتي',



                style:TextStyle(



                  color:Colors.white,


                  fontSize:40,


                  fontWeight:FontWeight.bold,



                ),



              ),





              const SizedBox(height:30),





              Expanded(



                child:SingleChildScrollView(



                  child:Column(



                    children:[



                      buildCard(


                        '🪙',


                        'العملات',


                        coins.toString(),


                      ),




                      buildCard(


                        '💎',


                        'الجواهر',


                        gems.toString(),


                      ),





                      buildCard(


                        '💡',


                        'التلميحات',


                        hints.toString(),


                      ),




                      const SizedBox(height:30),




                      ElevatedButton.icon(



                        onPressed:watchAd,



                        icon:const Icon(

                          Icons.play_circle_fill,

                          size:35,

                        ),



                        label:const Text(



                          'زيادة المحفظة 🎬',



                          style:TextStyle(



                            fontSize:22,


                            fontWeight:FontWeight.bold,



                          ),



                        ),



                        style:

                        ElevatedButton.styleFrom(



                          padding:

                          const EdgeInsets.symmetric(



                            horizontal:45,


                            vertical:18,



                          ),



                          shape:

                          RoundedRectangleBorder(



                            borderRadius:

                            BorderRadius.circular(40),



                          ),



                        ),



                      ),



                    ],



                  ),



                ),



              ),



            ],



          ),



        ),



      ),



    );


  }







  Widget buildCard(

      String icon,

      String title,

      String value,

      ){



    return Container(


      margin:

      const EdgeInsets.symmetric(

        horizontal:25,

        vertical:10,

      ),




      padding:

      const EdgeInsets.all(20),





      decoration:BoxDecoration(



        color:Colors.white.withOpacity(.9),



        borderRadius:

        BorderRadius.circular(30),




        boxShadow:[



          BoxShadow(



            color:Colors.black.withOpacity(.2),



            blurRadius:15,


            offset:

            const Offset(0,8),



          ),



        ],



      ),





      child:Row(



        children:[



          Container(



            padding:

            const EdgeInsets.all(15),



            decoration:

            BoxDecoration(



              color:

              Colors.blue.shade100,



              shape:

              BoxShape.circle,



            ),



            child:Text(



              icon,



              style:

              const TextStyle(



                fontSize:45,



              ),



            ),



          ),





          const SizedBox(width:25),





          Column(



            crossAxisAlignment:

            CrossAxisAlignment.start,



            children:[



              Text(



                title,



                style:const TextStyle(



                  fontSize:22,


                  fontWeight:FontWeight.bold,



                ),



              ),




              Text(



                value,



                style:const TextStyle(



                  fontSize:35,


                  color:Colors.blue,


                  fontWeight:FontWeight.bold,



                ),



              ),



            ],



          ),



        ],



      ),



    );



  }



}