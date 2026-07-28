import 'package:flutter/material.dart';

import '../screens/wallet_screen.dart';
import '../managers/reward_manager.dart';



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






class _GameToolbarState extends State<GameToolbar>{



  int stars = 0;

  int coins = 0;

  int gems = 0;



  @override
  void initState(){

    super.initState();

    loadToolbarData();

  }





  Future<void> loadToolbarData() async {


    final totalStars =
    await RewardManager.getStars();



    final totalCoins =
    await RewardManager.getCoins();



    final totalGems =
    await RewardManager.getGems();



    if(!mounted) return;



    setState((){


      stars = totalStars;

      coins = totalCoins;

      gems = totalGems;


    });


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

      context: context,

      builder:(_){


        return AlertDialog(


          title: const Text(
            "⚙️ الإعدادات",
          ),



          content: const Column(

            mainAxisSize:
            MainAxisSize.min,

            children:[


              Text(

                "Puzzle World",

                style: TextStyle(

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


              child: const Text(

                "حسناً",

              ),

            ),


          ],


        );


      },

    );


  }








  @override
  Widget build(BuildContext context){


    return SafeArea(


      child: Container(


        margin:
        const EdgeInsets.all(12),



        padding:
        const EdgeInsets.symmetric(

          horizontal:12,

          vertical:8,

        ),




        decoration: BoxDecoration(


          color:
          Colors.black.withOpacity(0.35),



          borderRadius:
          BorderRadius.circular(35),



          border: Border.all(

            color:
            Colors.white30,

          ),


        ),





        child: Row(


          mainAxisAlignment:
          MainAxisAlignment.spaceBetween,



          children:[





            GestureDetector(


              onTap:(){

                showSettings(context);

              },



              child: const Icon(


                Icons.settings_rounded,


                color:Colors.white,


                size:30,


              ),


            ),







            Image.asset(

              widget.logo,

              height:45,

            ),







            Row(


              children:[





                Container(

                  key:widget.starKey,


                  child:_imageCounterBox(

                    image:

                    "assets/images/rewards/Star_gold.png",


                    value:stars,

                  ),


                ),






                const SizedBox(width:8),






                _imageCounterBox(

                  image:

                  "assets/images/rewards/reward_box.png",


                  value:gems,

                ),






                const SizedBox(width:8),






                GestureDetector(


                  onTap:(){

                    openWallet(context);

                  },


                  child:_coinBox(coins),


                ),



              ],



            ),



          ],



        ),



      ),



    );

  }









  Widget _imageCounterBox({

    required String image,

    required int value,

  }){


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



          const SizedBox(width:4),



          Text(

            "$value",

            style:const TextStyle(

              color:Colors.white,

              fontSize:16,

              fontWeight:FontWeight.bold,

            ),

          ),



        ],



      ),



    );


  }







  Widget _coinBox(int value){


    return Container(


      padding:

      const EdgeInsets.symmetric(

        horizontal:8,

        vertical:5,

      ),



      decoration:

      BoxDecoration(

        color:Colors.white24,


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



          const SizedBox(width:4),



          Text(

            "$value",

            style:const TextStyle(

              color:Colors.white,

              fontSize:16,

              fontWeight:FontWeight.bold,

            ),

          ),



        ],



      ),



    );


  }





  @override
  void dispose(){

    super.dispose();

  }


}