import 'package:flutter/material.dart';

import '../screens/wallet_screen.dart';
import '../managers/puzzle_progress_manager.dart';


class GameToolbar extends StatefulWidget {

  final String logo;

  final VoidCallback? onBack;


  const GameToolbar({

    super.key,

    required this.logo,

    this.onBack,

  });


  @override
  State<GameToolbar> createState() =>
      _GameToolbarState();

}





class _GameToolbarState extends State<GameToolbar>{


  int coins = 0;

  bool loading = true;



  @override
  void initState(){

    super.initState();

    loadToolbarData();

  }





  Future<void> loadToolbarData() async {


    final totalCoins =
    await PuzzleProgressManager.getCoins();



    if(!mounted) return;


    setState((){

      coins = totalCoins;

      loading = false;

    });


  }







  void openWallet(BuildContext context){


    Navigator.push(

      context,

      MaterialPageRoute(

        builder:(_)=> const WalletScreen(),

      ),

    ).then((_){

      loadToolbarData();

    });


  }






  void closeGame(BuildContext context){


    Navigator.of(context).popUntil(

      (route)=>route.isFirst,

    );


  }







  void showSettings(BuildContext context){


    showDialog(

      context: context,

      builder:(_){


        return AlertDialog(

          title: const Text(
            "⚙️ الإعدادات",
          ),


          content: Column(

            mainAxisSize:
            MainAxisSize.min,


            children:[


              const Text(

                "Puzzle World",

                style: TextStyle(

                  fontWeight:
                  FontWeight.bold,

                ),

              ),


              const SizedBox(height:10),


              const Text(
                "الإصدار: 1.0.0",
              ),


              const SizedBox(height:20),



              ElevatedButton.icon(

                onPressed:(){


                  Navigator.pop(context);


                  closeGame(context);


                },


                icon:

                const Icon(

                  Icons.exit_to_app,

                ),


                label:

                const Text(

                  "إغلاق اللعبة",

                ),

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




        decoration:

        BoxDecoration(


          color:

          Colors.black.withOpacity(0.35),



          borderRadius:

          BorderRadius.circular(35),



          border:

          Border.all(

            color:

            Colors.white30,

          ),



          boxShadow:[


            BoxShadow(

              color:

              Colors.black.withOpacity(0.25),

              blurRadius:10,

              offset:

              const Offset(0,4),

            ),

          ],

        ),






        child: Row(


          mainAxisAlignment:

          MainAxisAlignment.spaceBetween,



          children:[



            GestureDetector(

              onTap:(){

                showSettings(context);

              },


              child:

              const Icon(

                Icons.settings_rounded,

                color:Colors.white,

                size:30,

              ),

            ),





            Image.asset(

              widget.logo,

              height:45,

              fit:

              BoxFit.contain,

            ),





            GestureDetector(

              onTap:(){

                openWallet(context);

              },


              child:

              _coinBox(coins),

            ),



          ],


        ),


      ),


    );


  }








  Widget _coinBox(int value){


    return Container(


      padding:

      const EdgeInsets.symmetric(

        horizontal:10,

        vertical:6,

      ),



      decoration:

      BoxDecoration(


        color:

        Colors.white24,


        borderRadius:

        BorderRadius.circular(18),


      ),



      child:

      Row(


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



          const SizedBox(width:5),



          Text(

            "$value",


            style:

            const TextStyle(

              color:Colors.white,

              fontSize:16,

              fontWeight:

              FontWeight.bold,

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