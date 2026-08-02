import 'package:flutter/material.dart';

import '../screens/wallet_screen.dart';
import '../managers/reward_manager.dart';
import '../models/reward_result_model.dart';



class GameToolbar extends StatefulWidget {


  final String logo =
      "assets/images/ui/puzzle_logo.png";


  final VoidCallback? onBack;


  final GlobalKey starKey;
  final GlobalKey coinKey;


  final VoidCallback? onSave;
  final VoidCallback? onRestart;
  final VoidCallback? onExit;


  final bool soundEnabled;
  final ValueChanged<bool>? onSoundChanged;



  const GameToolbar({

    super.key,

    required this.starKey,

    required this.coinKey,

    this.onBack,

    this.onSave,

    this.onRestart,

    this.onExit,

    this.soundEnabled = true,

    this.onSoundChanged,

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
  void initState() {

    super.initState();


    RewardManager.rewardNotifier
        .addListener(
          refreshReward,
        );


    loadToolbarData();

  }




  Future<void> loadToolbarData() async {


    final data =
        await RewardManager.getReward();



    if(!mounted) return;



    setState(() {

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

    ).then((_) {

      loadToolbarData();

    });


  }





  void showSettings(BuildContext context){



    bool sound =
        widget.soundEnabled;




    showDialog(


      context: context,


      builder: (context){


        return StatefulBuilder(


          builder:
          (context,setDialogState){



            return AlertDialog(



              shape:
              RoundedRectangleBorder(

                borderRadius:
                BorderRadius.circular(25),

              ),




              title: const Row(

                children: [

                  Icon(
                    Icons.settings_rounded,
                  ),


                  SizedBox(
                    width: 8,
                  ),


                  Text(
                    "الإعدادات",
                  ),

                ],

              ),




              content: Column(


                mainAxisSize:
                MainAxisSize.min,



                children: [





                  SwitchListTile(


                    title:
                    const Text(
                      "الصوت",
                    ),



                    secondary:
                    Icon(

                      sound
                      ? Icons.volume_up
                      : Icons.volume_off,

                    ),



                    value:
                    sound,



                    onChanged:
                    (value){


                      setDialogState((){

                        sound =
                            value;

                      });



                      widget.onSoundChanged
                          ?.call(value);



                    },


                  ),





                  const Divider(),





                  ListTile(


                    leading:
                    const Icon(
                      Icons.save_rounded,
                    ),



                    title:
                    const Text(
                      "حفظ اللعبة",
                    ),



                    onTap: (){


                      Navigator.pop(
                        context,
                      );


                      widget.onSave
                          ?.call();


                    },


                  ),






                  ListTile(


                    leading:
                    const Icon(
                      Icons.restart_alt_rounded,
                    ),



                    title:
                    const Text(
                      "إعادة اللعبة",
                    ),



                    onTap: (){


                      Navigator.pop(
                        context,
                      );


                      widget.onRestart
                          ?.call();


                    },


                  ),





                  ListTile(


                    leading:
                    const Icon(
                      Icons.exit_to_app_rounded,
                    ),



                    title:
                    const Text(
                      "خروج",
                    ),



                    onTap: (){


                      Navigator.pop(
                        context,
                      );


                      widget.onExit
                          ?.call();


                    },


                  ),





                  const Divider(),





                  const Text(


                    "Puzzle World\nالإصدار 1.0.0",


                    textAlign:
                    TextAlign.center,


                  ),



                ],


              ),


            );


          },


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

        horizontal: 12,

        vertical: 8,

      ),




      decoration: BoxDecoration(


        color:
        Colors.black.withOpacity(0.35),



        borderRadius:
        BorderRadius.circular(35),




        border:
        Border.all(

          color:
          Colors.white30,

        ),




        boxShadow: [


          BoxShadow(

            color:
            Colors.black.withOpacity(0.3),

            blurRadius:
            12,

            offset:
            const Offset(0,4),

          ),


        ],


      ),




      child: Row(


        mainAxisAlignment:
        MainAxisAlignment.spaceBetween,



        children: [





          // زر الإعدادات

          GestureDetector(


            onTap: (){


              showSettings(context);


            },



            child: Container(


              width:
              46,


              height:
              46,



              decoration:
              BoxDecoration(


                shape:
                BoxShape.circle,



                color:
                Colors.white24,



                border:
                Border.all(

                  color:
                  Colors.white38,

                ),



                boxShadow: [


                  BoxShadow(

                    color:
                    Colors.black.withOpacity(0.3),

                    blurRadius:
                    8,

                    offset:
                    const Offset(0,4),

                  ),


                ],


              ),




              child:
              const Icon(


                Icons.settings_rounded,


                color:
                Colors.white,


                size:
                28,


              ),


            ),


          ),






          // شعار اللعبة

          Image.asset(


            widget.logo,


            height:
            45,


          ),







          Row(



            children: [





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

                width:
                8,

              ),





              ImageCounterBox(



                image:
                "assets/images/rewards/gem.png",



                value:
                reward.gems,



              ),





              const SizedBox(

                width:
                8,

              ),






              GestureDetector(



                onTap: (){


                  openWallet(context);


                },



                child: Container(



                  key:
                  widget.coinKey,



                  child:
                  CoinCounterBox(


                    value:
                    reward.coins,


                  ),



                ),



              ),




            ],


          ),




        ],


      ),


    ),


  );


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
  void initState() {


    super.initState();



    controller =
        AnimationController(


          vsync: this,


          duration:
          const Duration(

            milliseconds: 500,

          ),


        );




    scale =
        Tween<double>(


          begin:
          1.0,


          end:
          1.25,


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
      covariant AnimatedStarCounter oldWidget) {


    super.didUpdateWidget(oldWidget);



    if(oldWidget.value != widget.value){


      controller.forward(
        from: 0,
      );


    }


  }







  @override
  Widget build(BuildContext context) {



    return ScaleTransition(



      scale:
      scale,



      child:
      Container(



        padding:
        const EdgeInsets.symmetric(

          horizontal:
          12,

          vertical:
          7,

        ),





        decoration:
        BoxDecoration(



          color:
          Colors.white24,



          borderRadius:
          BorderRadius.circular(22),





          border:
          Border.all(

            color:
            Colors.white38,

          ),




          boxShadow: [



            BoxShadow(

              color:
              Colors.black.withOpacity(0.25),

              blurRadius:
              10,

              offset:
              const Offset(0,4),

            ),



          ],



        ),






        child:
        Row(



          mainAxisSize:
          MainAxisSize.min,



          children: [





            Image.asset(



              "assets/images/rewards/Star_gold.png",



              width:
              36,



              height:
              36,



            ),





            const SizedBox(

              width:
              6,

            ),






            Text(



              "${widget.value}",




              style:
              const TextStyle(



                color:
                Colors.white,



                fontSize:
                20,



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
  void dispose() {


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
  Widget build(BuildContext context) {


    return Container(

      padding:
      const EdgeInsets.symmetric(

        horizontal: 10,

        vertical: 6,

      ),


      decoration:
      BoxDecoration(

        color:
        Colors.white24,


        borderRadius:
        BorderRadius.circular(18),



        border:
        Border.all(

          color:
          Colors.white30,

        ),



        boxShadow: [

          BoxShadow(

            color:
            Colors.black.withOpacity(0.25),

            blurRadius:
            8,

            offset:
            const Offset(0,4),

          ),

        ],

      ),



      child: Row(


        mainAxisSize:
        MainAxisSize.min,


        children: [


          Image.asset(

            image,

            width:
            30,

            height:
            30,

          ),



          const SizedBox(

            width:
            5,

          ),



          Text(

            "$value",


            style:
            const TextStyle(

              color:
              Colors.white,

              fontSize:
              18,

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
  Widget build(BuildContext context) {


    return Container(



      padding:
      const EdgeInsets.symmetric(


        horizontal:
        10,


        vertical:
        6,


      ),




      decoration:
      BoxDecoration(



        color:
        Colors.white24,



        borderRadius:
        BorderRadius.circular(18),




        border:
        Border.all(

          color:
          Colors.white30,

        ),





        boxShadow: [


          BoxShadow(

            color:
            Colors.black.withOpacity(0.25),


            blurRadius:
            8,


            offset:
            const Offset(0,4),


          ),


        ],



      ),






      child:
      Row(



        mainAxisSize:
        MainAxisSize.min,



        children: [





          Image.asset(



            "assets/images/ui/coin.png",



            width:
            30,



            height:
            30,



          ),






          const SizedBox(

            width:
            5,

          ),







          Text(



            "$value",




            style:
            const TextStyle(



              color:
              Colors.white,



              fontSize:
              18,



              fontWeight:
              FontWeight.bold,



            ),



          ),




        ],



      ),




    );



  }


}