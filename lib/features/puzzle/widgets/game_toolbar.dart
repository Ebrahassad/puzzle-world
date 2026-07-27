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


import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';



class WalletScreen extends StatefulWidget {


  const WalletScreen({

    super.key,

  });



  @override
  State<WalletScreen> createState() =>
      _WalletScreenState();


}






class _WalletScreenState
    extends State<WalletScreen>
    with SingleTickerProviderStateMixin {



  int stars = 0;

  int coins = 0;

  int achievements = 0;



  bool loading = true;



  late AnimationController starController;

  late Animation<double> starAnimation;







  @override
  void initState(){


    super.initState();


    loadWallet();



    starController = AnimationController(

      vsync:this,

      duration:

      const Duration(seconds:2),

    )..repeat(

      reverse:true,

    );



    starAnimation = Tween<double>(

      begin:0.9,

      end:1.1,

    ).animate(

      CurvedAnimation(

        parent:starController,

        curve:Curves.easeInOut,

      ),

    );



  }









  Future<void> loadWallet() async {


    final prefs =
    await SharedPreferences.getInstance();



    setState((){


      stars =
      prefs.getInt("wallet_stars") ?? 0;



      coins =
      prefs.getInt("wallet_coins") ?? 0;



      achievements =
      prefs.getInt("wallet_achievements") ?? 0;



      loading = false;


    });



  }









  Future<void> saveWallet() async {


    final prefs =
    await SharedPreferences.getInstance();



    await prefs.setInt(

      "wallet_stars",

      stars,

    );



    await prefs.setInt(

      "wallet_coins",

      coins,

    );



    await prefs.setInt(

      "wallet_achievements",

      achievements,

    );



  }









  Future<void> rewardFromAd() async {


    setState((){


      stars += 5;


      coins += 10;


    });



    await saveWallet();



    ScaffoldMessenger.of(context)
        .showSnackBar(


      const SnackBar(


        content:

        Text(

          "🎁 حصلت على +10 رصيد و +5 نجوم",

        ),


      ),


    );



  }









  @override
  void dispose(){


    starController.dispose();


    super.dispose();


  }









  @override
  Widget build(BuildContext context){



    if(loading){


      return const Scaffold(


        body:

        Center(

          child:

          CircularProgressIndicator(),

        ),


      );


    }






    return Scaffold(



      appBar:

      AppBar(



        title:

        const Text(

          "👜 المحفظة",

        ),



        centerTitle:true,


      ),






      body:

      SingleChildScrollView(



        padding:

        const EdgeInsets.all(20),



        child:

        Column(



          children:[








            // النجمة الذهبية

            ScaleTransition(



              scale:

              starAnimation,



              child:

              Image.asset(



                "assets/images/rewards/Star_gold.png",



                height:100,



                errorBuilder:

                    (_,__,___){


                  return const Icon(

                    Icons.star,

                    size:90,

                    color:

                    Colors.amber,

                  );


                },


              ),



            ),








            const SizedBox(height:20),






            walletCard(

              "⭐ النجوم",

              stars,

              Colors.amber,

            ),






            walletCard(

              "🪙 الرصيد",

              coins,

              Colors.orange,

            ),






            walletCard(

              "🏆 الإنجازات",

              achievements,

              Colors.blue,

            ),









            const SizedBox(height:25),






            Container(



              padding:

              const EdgeInsets.all(20),



              decoration:

              BoxDecoration(



                color:

                Colors.amber.withOpacity(.15),



                borderRadius:

                BorderRadius.circular(25),



              ),



              child:

              Column(



                children:[



                  const Text(



                    "🎁 صندوق المكافأة الذهبية",

                    style:

                    TextStyle(

                      fontSize:22,

                      fontWeight:

                      FontWeight.bold,

                    ),

                  ),




                  const SizedBox(height:15),





                  const Text(



                    "شاهد إعلان واحصل على مكافأة",

                    style:

                    TextStyle(

                      fontSize:17,

                    ),

                  ),




                  const SizedBox(height:20),






                  SizedBox(



                    width:

                    double.infinity,



                    height:55,



                    child:

                    ElevatedButton.icon(



                      onPressed:

                      rewardFromAd,



                      icon:

                      const Icon(

                        Icons.play_circle,

                      ),



                      label:

                      const Text(

                        "شاهد إعلان",

                        style:

                        TextStyle(

                          fontSize:18,

                        ),

                      ),



                    ),



                  ),




                  const SizedBox(height:15),





                  const Text(



                    "+10 🪙 رصيد   +5 ⭐ نجوم",

                    style:

                    TextStyle(

                      fontSize:18,

                      fontWeight:

                      FontWeight.bold,

                    ),

                  ),



                ],



              ),



            ),



          ],



        ),



      ),



    );



  }









  Widget walletCard(

      String title,

      int value,

      Color color,

      ){



    return Container(



      margin:

      const EdgeInsets.only(

        bottom:15,

      ),



      padding:

      const EdgeInsets.all(18),



      decoration:

      BoxDecoration(



        color:

        color.withOpacity(.15),



        borderRadius:

        BorderRadius.circular(22),



        border:

        Border.all(

          color:color,

          width:2,

        ),



      ),




      child:

      Row(



        mainAxisAlignment:

        MainAxisAlignment.spaceBetween,



        children:[



          Text(

            title,

            style:

            const TextStyle(

              fontSize:20,

              fontWeight:

              FontWeight.bold,

            ),

          ),




          Text(

            value.toString(),

            style:

            TextStyle(

              color:color,

              fontSize:26,

              fontWeight:

              FontWeight.bold,

            ),

          ),



        ],



      ),



    );


  }



}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';



class WalletScreen extends StatefulWidget {


  const WalletScreen({

    super.key,

  });



  @override
  State<WalletScreen> createState() =>
      _WalletScreenState();


}






class _WalletScreenState
    extends State<WalletScreen>
    with SingleTickerProviderStateMixin {



  int stars = 0;

  int coins = 0;

  int achievements = 0;



  bool loading = true;



  late AnimationController starController;

  late Animation<double> starAnimation;







  @override
  void initState(){


    super.initState();


    loadWallet();



    starController = AnimationController(

      vsync:this,

      duration:

      const Duration(seconds:2),

    )..repeat(

      reverse:true,

    );



    starAnimation = Tween<double>(

      begin:0.9,

      end:1.1,

    ).animate(

      CurvedAnimation(

        parent:starController,

        curve:Curves.easeInOut,

      ),

    );



  }









  Future<void> loadWallet() async {


    final prefs =
    await SharedPreferences.getInstance();



    setState((){


      stars =
      prefs.getInt("wallet_stars") ?? 0;



      coins =
      prefs.getInt("wallet_coins") ?? 0;



      achievements =
      prefs.getInt("wallet_achievements") ?? 0;



      loading = false;


    });



  }









  Future<void> saveWallet() async {


    final prefs =
    await SharedPreferences.getInstance();



    await prefs.setInt(

      "wallet_stars",

      stars,

    );



    await prefs.setInt(

      "wallet_coins",

      coins,

    );



    await prefs.setInt(

      "wallet_achievements",

      achievements,

    );



  }









  Future<void> rewardFromAd() async {


    setState((){


      stars += 5;


      coins += 10;


    });



    await saveWallet();



    ScaffoldMessenger.of(context)
        .showSnackBar(


      const SnackBar(


        content:

        Text(

          "🎁 حصلت على +10 رصيد و +5 نجوم",

        ),


      ),


    );



  }









  @override
  void dispose(){


    starController.dispose();


    super.dispose();


  }









  @override
  Widget build(BuildContext context){



    if(loading){


      return const Scaffold(


        body:

        Center(

          child:

          CircularProgressIndicator(),

        ),


      );


    }






    return Scaffold(



      appBar:

      AppBar(



        title:

        const Text(

          "👜 المحفظة",

        ),



        centerTitle:true,


      ),






      body:

      SingleChildScrollView(



        padding:

        const EdgeInsets.all(20),



        child:

        Column(



          children:[








            // النجمة الذهبية

            ScaleTransition(



              scale:

              starAnimation,



              child:

              Image.asset(



                "assets/images/rewards/Star_gold.png",



                height:100,



                errorBuilder:

                    (_,__,___){


                  return const Icon(

                    Icons.star,

                    size:90,

                    color:

                    Colors.amber,

                  );


                },


              ),



            ),








            const SizedBox(height:20),






            walletCard(

              "⭐ النجوم",

              stars,

              Colors.amber,

            ),






            walletCard(

              "🪙 الرصيد",

              coins,

              Colors.orange,

            ),






            walletCard(

              "🏆 الإنجازات",

              achievements,

              Colors.blue,

            ),









            const SizedBox(height:25),






            Container(



              padding:

              const EdgeInsets.all(20),



              decoration:

              BoxDecoration(



                color:

                Colors.amber.withOpacity(.15),



                borderRadius:

                BorderRadius.circular(25),



              ),



              child:

              Column(



                children:[



                  const Text(



                    "🎁 صندوق المكافأة الذهبية",

                    style:

                    TextStyle(

                      fontSize:22,

                      fontWeight:

                      FontWeight.bold,

                    ),

                  ),




                  const SizedBox(height:15),





                  const Text(



                    "شاهد إعلان واحصل على مكافأة",

                    style:

                    TextStyle(

                      fontSize:17,

                    ),

                  ),




                  const SizedBox(height:20),






                  SizedBox(



                    width:

                    double.infinity,



                    height:55,



                    child:

                    ElevatedButton.icon(



                      onPressed:

                      rewardFromAd,



                      icon:

                      const Icon(

                        Icons.play_circle,

                      ),



                      label:

                      const Text(

                        "شاهد إعلان",

                        style:

                        TextStyle(

                          fontSize:18,

                        ),

                      ),



                    ),



                  ),




                  const SizedBox(height:15),





                  const Text(



                    "+10 🪙 رصيد   +5 ⭐ نجوم",

                    style:

                    TextStyle(

                      fontSize:18,

                      fontWeight:

                      FontWeight.bold,

                    ),

                  ),



                ],



              ),



            ),



          ],



        ),



      ),



    );



  }









  Widget walletCard(

      String title,

      int value,

      Color color,

      ){



    return Container(



      margin:

      const EdgeInsets.only(

        bottom:15,

      ),



      padding:

      const EdgeInsets.all(18),



      decoration:

      BoxDecoration(



        color:

        color.withOpacity(.15),



        borderRadius:

        BorderRadius.circular(22),



        border:

        Border.all(

          color:color,

          width:2,

        ),



      ),




      child:

      Row(



        mainAxisAlignment:

        MainAxisAlignment.spaceBetween,



        children:[



          Text(

            title,

            style:

            const TextStyle(

              fontSize:20,

              fontWeight:

              FontWeight.bold,

            ),

          ),




          Text(

            value.toString(),

            style:

            TextStyle(

              color:color,

              fontSize:26,

              fontWeight:

              FontWeight.bold,

            ),

          ),



        ],



      ),



    );


  }



}