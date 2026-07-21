import 'package:flutter/material.dart';

import '../managers/reward_manager.dart';



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



  @override
  void initState() {


    super.initState();


    loadWallet();


  }






  Future<void> loadWallet() async {


    final c =
    await RewardManager.getCoins();



    final g =
    await RewardManager.getGems();




    setState((){


      coins = c;

      gems = g;


    });


  }







  @override
  Widget build(BuildContext context) {


    return Scaffold(


      appBar: AppBar(


        title:const Text(

          'محفظتي',

        ),


        centerTitle:true,


      ),



      body:Container(


        decoration:const BoxDecoration(


          gradient:LinearGradient(


            colors:[

              Color(0xff89F7FE),

              Color(0xff66A6FF),

            ],


          ),

        ),



        child:Center(


          child:Column(


            mainAxisAlignment:

            MainAxisAlignment.center,



            children:[



              _buildCard(

                icon:'🪙',

                title:'العملات',

                value:'$coins',

              ),




              const SizedBox(height:20),




              _buildCard(

                icon:'💎',

                title:'الجواهر',

                value:'$gems',

              ),



            ],


          ),


        ),


      ),


    );


  }








  Widget _buildCard({


    required String icon,


    required String title,


    required String value,


  }){


    return Container(


      width:300,


      padding:

      const EdgeInsets.all(25),



      decoration:BoxDecoration(


        color:Colors.white.withOpacity(.9),


        borderRadius:

        BorderRadius.circular(30),



        boxShadow:[


          BoxShadow(


            color:Colors.black26,


            blurRadius:15,


            offset:Offset(0,8),


          ),


        ],


      ),



      child:Column(


        children:[



          Text(


            icon,


            style:const TextStyle(

              fontSize:50,

            ),


          ),



          const SizedBox(height:10),



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


    );


  }



}