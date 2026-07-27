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



class _WalletScreenState extends State<WalletScreen> {


  int stars = 0;

  int coins = 0;

  int gems = 0;


  bool loading = true;



  @override
  void initState(){

    super.initState();

    loadWallet();

  }




  Future<void> loadWallet() async {


    final prefs =
    await SharedPreferences.getInstance();


    setState(() {


      stars =
          prefs.getInt("wallet_stars") ?? 0;


      coins =
          prefs.getInt("wallet_coins") ?? 0;


      gems =
          prefs.getInt("wallet_gems") ?? 0;


      loading = false;


    });


  }





  Future<void> saveWallet() async {


    final prefs =
    await SharedPreferences.getInstance();


    await prefs.setInt(
        "wallet_stars",
        stars
    );


    await prefs.setInt(
        "wallet_coins",
        coins
    );


    await prefs.setInt(
        "wallet_gems",
        gems
    );


  }





  // مكافأة الإعلان
  Future<void> rewardFromAd() async {


    setState(() {


      stars += 1;

      coins += 50;

      gems += 1;


    });


    await saveWallet();



    ScaffoldMessenger.of(context)
        .showSnackBar(

      const SnackBar(

        content:
        Text(
          "🎁 حصلت على مكافأة الإعلان",
        ),

      ),

    );


  }







  @override
  Widget build(BuildContext context) {


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


      appBar: AppBar(

        title:
        const Text(
          "💰 المحفظة",
        ),

        centerTitle:true,

      ),




      body:


      Padding(


        padding:
        const EdgeInsets.all(20),



        child:


        Column(


          children:[




            walletCard(

              "⭐ النجوم الذهبية",

              stars.toString(),

              Colors.amber,

            ),





            walletCard(

              "🪙 العملات",

              coins.toString(),

              Colors.orange,

            ),





            walletCard(

              "💎 الجواهر",

              gems.toString(),

              Colors.blue,

            ),






            const SizedBox(height:30),





            SizedBox(


              width:double.infinity,


              height:55,



              child:


              ElevatedButton.icon(


                onPressed:
                rewardFromAd,


                icon:
                const Icon(
                    Icons.play_circle
                ),


                label:
                const Text(

                  "شاهد إعلان واحصل على مكافأة",

                  style:
                  TextStyle(
                    fontSize:18,
                  ),

                ),


              ),


            ),





          ],


        ),


      ),


    );

  }








  Widget walletCard(

      String title,

      String value,

      Color color,

      ){



    return Container(


      margin:
      const EdgeInsets.only(
          bottom:15
      ),



      padding:
      const EdgeInsets.all(20),



      decoration:

      BoxDecoration(

        color:
        color.withOpacity(.15),


        borderRadius:
        BorderRadius.circular(20),



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

            value,

            style:

            TextStyle(

              fontSize:26,

              color:color,

              fontWeight:
              FontWeight.bold,

            ),

          ),



        ],


      ),


    );


  }



}