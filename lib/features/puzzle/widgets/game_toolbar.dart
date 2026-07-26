import 'package:flutter/material.dart';



class GameToolbar extends StatelessWidget {


  final String logo;

  final int stars;

  final int rewards;

  final VoidCallback? onBack;



  const GameToolbar({

    super.key,

    required this.logo,

    required this.stars,

    required this.rewards,

    this.onBack,

  });








  void showExitDialog(BuildContext context){



    showDialog(

      context: context,

      builder: (context){



        return Dialog(



          backgroundColor:

          Colors.transparent,



          child: Container(



            padding:

            const EdgeInsets.all(20),



            decoration:

            BoxDecoration(



              color:

              Colors.white,



              borderRadius:

              BorderRadius.circular(28),



              boxShadow:[



                BoxShadow(

                  color:

                  Colors.black26,

                  blurRadius:15,

                ),

              ],



            ),





            child: Column(



              mainAxisSize:

              MainAxisSize.min,



              children:[



                const Text(



                  "🌍 ماذا تريد أن تفعل؟",



                  style:

                  TextStyle(



                    fontSize:22,

                    fontWeight:

                    FontWeight.bold,

                  ),

                ),




                const SizedBox(height:20),







                _dialogButton(



                  context,

                  icon:

                  Icons.map,

                  text:

                  "العودة إلى الخريطة",



                  onTap:(){



                    Navigator.pop(context);



                    // هنا نربط الإعلان لاحقاً



                    if(onBack != null){

                      onBack!();

                    }



                  },

                ),






                const SizedBox(height:12),





                _dialogButton(



                  context,

                  icon:

                  Icons.exit_to_app,

                  text:

                  "إغلاق اللعبة",



                  onTap:(){



                    Navigator.pop(context);



                    // هنا نربط إعلان الخروج لاحقاً



                    Navigator.popUntil(

                      context,

                      (route)=>route.isFirst,

                    );



                  },

                ),





                const SizedBox(height:12),





                TextButton(



                  onPressed:(){



                    Navigator.pop(context);



                  },



                  child:

                  const Text(

                    "إلغاء",

                    style:

                    TextStyle(

                      fontSize:18,

                    ),

                  ),



                ),




              ],



            ),



          ),



        );



      },

    );

  }








  Widget _dialogButton(

      BuildContext context,{

        required IconData icon,

        required String text,

        required VoidCallback onTap,

      }){



    return InkWell(



      onTap:onTap,



      child: Container(



        width:

        double.infinity,



        padding:

        const EdgeInsets.symmetric(

          vertical:14,

        ),



        decoration:

        BoxDecoration(



          color:

          Colors.blueAccent,



          borderRadius:

          BorderRadius.circular(20),



          boxShadow:[



            BoxShadow(

              color:

              Colors.black26,

              blurRadius:8,

              offset:

              const Offset(0,4),

            ),

          ],



        ),



        child:Row(



          mainAxisAlignment:

          MainAxisAlignment.center,



          children:[



            Icon(

              icon,

              color:

              Colors.white,

            ),



            const SizedBox(width:10),




            Text(



              text,



              style:

              const TextStyle(



                color:

                Colors.white,



                fontSize:18,



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
  Widget build(BuildContext context){



    return SafeArea(



      child: Container(



        margin:

        const EdgeInsets.all(12),




        padding:

        const EdgeInsets.symmetric(

          horizontal:14,

          vertical:8,

        ),




        decoration:

        BoxDecoration(



          color:

          Colors.black38,



          borderRadius:

          BorderRadius.circular(32),




          border:

          Border.all(

            color:

            Colors.white30,

            width:1,

          ),



        ),





        child:Row(



          mainAxisAlignment:

          MainAxisAlignment.spaceBetween,



          children:[





            // زر الرجوع

            onBack != null

                ? GestureDetector(



              onTap:(){

                showExitDialog(context);

              },



              child:

              const Icon(



                Icons.arrow_back_ios_new,



                color:

                Colors.white,



                size:28,



              ),



            )

                :

            const SizedBox(

              width:28,

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



                const SizedBox(width:8),




                _counterBox(

                  "🎁",

                  rewards,

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



          fontSize:17,



          fontWeight:

          FontWeight.bold,



        ),



      ),



    );

  }



}