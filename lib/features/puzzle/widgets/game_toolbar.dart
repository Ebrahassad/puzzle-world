import 'package:flutter/material.dart';

import '../screens/wallet_screen.dart';



class GameToolbar extends StatelessWidget {


  final String logo;


  final int stars;


  final int coins;


  final VoidCallback? onBack;



  const GameToolbar({

    super.key,


    required this.logo,


    required this.stars,


    required this.coins,


    this.onBack,

  });








  void openWallet(BuildContext context){


    Navigator.push(

      context,

      MaterialPageRoute(

        builder:(_)=>

        const WalletScreen(),

      ),

    );


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

              ),


              SizedBox(height:10),


              Text(

                "الإصدار: 1.0.0",

              ),


              SizedBox(height:10),


              Text(

                "تواصل معنا",

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

            )


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

          Colors.black38,


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

                Icons.settings,

                color:

                Colors.white,

                size:30,

              ),


            ),





            // اللوقو

            Image.asset(

              logo,


              height:45,


              fit:

              BoxFit.contain,


            ),






            Row(


              children:[



                _counterBox(

                  "⭐",

                  stars,

                ),




                const SizedBox(width:6),




                GestureDetector(


                  onTap:(){

                    openWallet(context);

                  },


                  child:_counterBox(

                    "🪙",

                    coins,

                  ),


                ),



              ],


            ),



          ],



        ),



      ),



    );


  }








  Widget _counterBox(

      String icon,

      int value,

      ){



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




      child:Text(



        "$icon $value",



        style:

        const TextStyle(


          color:

          Colors.white,


          fontSize:16,


          fontWeight:

          FontWeight.bold,


        ),



      ),



    );


  }



}