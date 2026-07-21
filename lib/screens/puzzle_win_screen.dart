import 'package:flutter/material.dart';
import '../models/game_result_model.dart';



class PuzzleWinScreen extends StatelessWidget {


  final GameResultModel result;


  const PuzzleWinScreen({

    super.key,

    required this.result,

  });



  @override
  Widget build(BuildContext context) {


    return Scaffold(


      body:Container(


        decoration:const BoxDecoration(


          gradient:LinearGradient(


            colors:[

              Color(0xffFFD166),

              Color(0xffFF9F1C),

            ],


            begin:Alignment.topCenter,

            end:Alignment.bottomCenter,


          ),

        ),



        child:SafeArea(


          child:Center(


            child:Column(


              mainAxisAlignment:
              MainAxisAlignment.center,


              children:[


                const Text(


                  '🎉 أحسنت!',


                  style:TextStyle(


                    fontSize:45,

                    fontWeight:
                    FontWeight.bold,

                    color:Colors.white,

                  ),


                ),




                const SizedBox(height:30),




                Row(


                  mainAxisAlignment:
                  MainAxisAlignment.center,


                  children:List.generate(


                    result.stars,


                        (index)=>const Padding(


                      padding:
                      EdgeInsets.all(5),


                      child:Icon(


                        Icons.star,


                        color:Colors.yellow,

                        size:55,

                      ),


                    ),


                  ),


                ),




                const SizedBox(height:30),




                Text(


                  'الحركات: ${result.moves}',


                  style:const TextStyle(


                    fontSize:22,

                    color:Colors.white,

                  ),


                ),




                const SizedBox(height:10),




                Text(


                  'الوقت: ${result.time.inSeconds} ثانية',


                  style:const TextStyle(


                    fontSize:22,

                    color:Colors.white,

                  ),


                ),




                const SizedBox(height:50),




                ElevatedButton(


                  onPressed:(){


                    Navigator.pop(context);


                  },


                  style:ElevatedButton.styleFrom(


                    padding:
                    const EdgeInsets.symmetric(

                      horizontal:50,

                      vertical:18,

                    ),


                    shape:
                    RoundedRectangleBorder(

                      borderRadius:
                      BorderRadius.circular(30),

                    ),


                  ),



                  child:const Text(


                    'ممتاز 🧩',


                    style:TextStyle(

                      fontSize:22,

                    ),

                  ),



                ),



              ],


            ),


          ),


        ),


      ),


    );


  }

}