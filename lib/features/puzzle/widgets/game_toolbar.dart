import 'package:flutter/material.dart';

import '../screens/wallet_screen.dart';



class GameToolbar extends StatefulWidget {


  final String logo;


  final int stars;


  final int coins;


  final int rewards;


  final VoidCallback? onBack;


  final GlobalKey starKey;




  const GameToolbar({


    super.key,


    required this.logo,


    required this.stars,


    required this.coins,


    required this.rewards,


    required this.starKey,


    this.onBack,


  });







  @override
  State<GameToolbar> createState() =>
      _GameToolbarState();


}









class _GameToolbarState extends State<GameToolbar>{



  void openWallet(BuildContext context){


    Navigator.push(

      context,

      MaterialPageRoute(

        builder:(_)=> const WalletScreen(),

      ),

    );


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

                  fontWeight: FontWeight.bold,

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


                icon: const Icon(

                  Icons.exit_to_app,

                ),


                label: const Text(

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


      child:Container(



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





        child:Row(



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



                color:

                Colors.white,



                size:30,


              ),


            ),







            Image.asset(


              widget.logo,


              height:45,


              fit:

              BoxFit.contain,


            ),







            Row(



              children:[





                Container(


                  key:

                  widget.starKey,


                  child:

                  _imageCounterBox(



                    image:

                    "assets/images/rewards/Star_gold.png",



                    value:

                    widget.stars,



                  ),



                ),







                const SizedBox(width:8),







                _imageCounterBox(



                  image:

                  "assets/images/rewards/reward_box.png",



                  value:

                  widget.rewards,



                ),







                const SizedBox(width:8),







                GestureDetector(



                  onTap:(){



                    openWallet(context);



                  },



                  child:

                  _coinBox(

                    widget.coins,

                  ),



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



            errorBuilder:

                (_,__,___){



              return const Icon(



                Icons.star,



                color:Colors.yellow,



                size:24,



              );


            },


          ),





          const SizedBox(width:4),





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

  Widget _coinBox(int value){



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





          const SizedBox(width:4),





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









  @override
  void dispose(){



    super.dispose();



  }



}