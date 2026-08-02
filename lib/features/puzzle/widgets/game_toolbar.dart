import 'package:flutter/material.dart';

import '../screens/wallet_screen.dart';
import '../managers/reward_manager.dart';
import '../models/reward_result_model.dart';



class GameToolbar extends StatefulWidget {


  final String logo;

  final VoidCallback? onBack;

  final GlobalKey starKey;



  const GameToolbar({

    super.key,

    required this.logo,

    required this.starKey,

    this.onBack,

  });



  @override
  State<GameToolbar> createState() =>
      _GameToolbarState();

}






class _GameToolbarState
    extends State<GameToolbar> {



  RewardResultModel reward =
      const RewardResultModel();




  @override
  void initState(){

    super.initState();

    loadToolbarData();

  }





  Future<void> loadToolbarData() async {


    final data =
        await RewardManager.getReward();



    if(!mounted) return;



    setState((){

      reward = data;

    });


  }





  void refreshReward(){

    loadToolbarData();

  }






  void openWallet(BuildContext context){


    Navigator.push(

      context,

      MaterialPageRoute(

        builder: (_) =>
            const WalletScreen(),

      ),

    ).then((_){

      loadToolbarData();

    });


  }





  void showSettings(BuildContext context){


    showDialog(

      context:context,

      builder:(_){


        return AlertDialog(

          title:
          const Text(
            "⚙️ الإعدادات",
          ),


          content:
          const Column(

            mainAxisSize:
            MainAxisSize.min,


            children:[


              Text(

                "Puzzle World",

                style:
                TextStyle(

                  fontWeight:
                  FontWeight.bold,

                ),

              ),



              SizedBox(height:10),



              Text(
                "الإصدار: 1.0.0",
              ),


            ],

          ),



          actions:[


            TextButton(

              onPressed:(){

                Navigator.pop(context);

              },


              child:
              const Text(
                "حسناً",
              ),

            ),


          ],

        );


      },

    );


  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(

      child: Container(

        margin:
        const EdgeInsets.all(12),


        padding:
        const EdgeInsets.symmetric(

          horizontal:12,

          vertical:8,

        ),



        decoration:BoxDecoration(

          color:
          Colors.black.withOpacity(0.35),


          borderRadius:
          BorderRadius.circular(35),


          border:
          Border.all(

            color:
            Colors.white30,

          ),


        ),



        child:Row(

          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,


          children:[




            // الإعدادات

            GestureDetector(

              onTap:(){

                showSettings(context);

              },


              child:
              const Icon(

                Icons.settings_rounded,

                color:
                Colors.white,

                size:30,

              ),

            ),






            // الشعار

            Image.asset(

              widget.logo,

              height:45,

            ),








            // المكافآت

            Row(

              children:[




                // ⭐ النجوم

                Container(

                  key:
                  widget.starKey,


                  child:
                  AnimatedStarCounter(

                    value:
                    reward.stars,

                  ),


                ),





                const SizedBox(
                  width:8,
                ),





                // 💎 الجواهر

                ImageCounterBox(

                  image:
                  "assets/images/rewards/gem.png",

                  value:
                  reward.gems,

                ),





                const SizedBox(
                  width:8,
                ),






                // 🪙 العملات

                GestureDetector(

                  onTap:(){

                    openWallet(context);

                  },


                  child:
                  CoinCounterBox(

                    value:
                    reward.coins,

                  ),

                ),



              ],

            ),



          ],

        ),


      ),

    );

  }


}

class AnimatedStarCounter extends StatefulWidget {

  final int value;


  const AnimatedStarCounter({

    super.key,

    required this.value,

  });



  @override
  State<AnimatedStarCounter> createState() =>
      _AnimatedStarCounterState();

}





class _AnimatedStarCounterState
    extends State<AnimatedStarCounter>
    with SingleTickerProviderStateMixin {


  late AnimationController controller;

  late Animation<double> scale;



  @override
  void initState(){

    super.initState();


    controller =
        AnimationController(

      vsync:this,

      duration:
      const Duration(

        milliseconds:500,

      ),

    );



    scale =
        Tween<double>(

          begin:1,

          end:1.3,

        ).animate(

          CurvedAnimation(

            parent:
            controller,

            curve:
            Curves.elasticOut,

          ),

        );



    controller.forward();


  }





  @override
  void didUpdateWidget(
      covariant AnimatedStarCounter oldWidget){

    super.didUpdateWidget(oldWidget);



    if(oldWidget.value != widget.value){

      controller.forward(
        from:0,
      );

    }

  }





  @override
  Widget build(BuildContext context){

    return ScaleTransition(

      scale:scale,


      child:Container(

        padding:
        const EdgeInsets.symmetric(

          horizontal:8,

          vertical:5,

        ),


        decoration:BoxDecoration(

          color:
          Colors.white24,


          borderRadius:
          BorderRadius.circular(18),

        ),



        child:Row(

          mainAxisSize:
          MainAxisSize.min,


          children:[


            Image.asset(

              "assets/images/rewards/Star_gold.png",

              width:24,

              height:24,

            ),



            const SizedBox(
              width:4,
            ),



            Text(

              "${widget.value}",


              style:
              const TextStyle(

                color:
                Colors.white,


                fontSize:16,


                fontWeight:
                FontWeight.bold,

              ),

            ),


          ],

        ),

      ),

    );

  }





  @override
  void dispose(){

    controller.dispose();

    super.dispose();

  }

}







class ImageCounterBox extends StatelessWidget {


  final String image;

  final int value;



  const ImageCounterBox({

    super.key,

    required this.image,

    required this.value,

  });



  @override
  Widget build(BuildContext context){

    return Container(

      padding:
      const EdgeInsets.symmetric(

        horizontal:8,

        vertical:5,

      ),


      decoration:
      BoxDecoration(

        color:
        Colors.white24,


        borderRadius:
        BorderRadius.circular(18),

      ),



      child:Row(

        mainAxisSize:
        MainAxisSize.min,


        children:[


          Image.asset(

            image,

            width:24,

            height:24,

          ),



          const SizedBox(
            width:4,
          ),



          Text(

            "$value",

            style:
            const TextStyle(

              color:
              Colors.white,

              fontSize:16,

              fontWeight:
              FontWeight.bold,

            ),

          ),


        ],

      ),

    );

  }

}







class CoinCounterBox extends StatelessWidget {


  final int value;



  const CoinCounterBox({

    super.key,

    required this.value,

  });



  @override
  Widget build(BuildContext context){


    return Container(

      padding:
      const EdgeInsets.symmetric(

        horizontal:8,

        vertical:5,

      ),


      decoration:
      BoxDecoration(

        color:
        Colors.white24,


        borderRadius:
        BorderRadius.circular(18),

      ),



      child:Row(

        mainAxisSize:
        MainAxisSize.min,


        children:[


          const Text(

            "🪙",

            style:
            TextStyle(

              fontSize:22,

            ),

          ),



          const SizedBox(
            width:4,
          ),



          Text(

            "$value",

            style:
            const TextStyle(

              color:
              Colors.white,


              fontSize:16,


              fontWeight:
              FontWeight.bold,

            ),

          ),


        ],

      ),

    );


  }

}