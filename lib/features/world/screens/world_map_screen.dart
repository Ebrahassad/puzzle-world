import 'package:flutter/material.dart';
import '../data/islands_data.dart';
import '../widgets/island_widget.dart';


class WorldMapScreen extends StatelessWidget {


  const WorldMapScreen({
    super.key,
  });



  @override
  Widget build(BuildContext context) {


    return Scaffold(


      body:Container(



        decoration:const BoxDecoration(



          gradient:LinearGradient(



            begin:Alignment.topCenter,



            end:Alignment.bottomCenter,



            colors:[



              Color(0xff74D7FF),


              Color(0xff2196F3),



            ],



          ),



        ),




        child:SafeArea(



          child:Stack(



            children:[



              // عنوان الخريطة


              Positioned(



                top:20,


                left:0,


                right:0,



                child:Text(



                  "🌍 Puzzle World",



                  textAlign:TextAlign.center,



                  style:const TextStyle(



                    color:Colors.white,



                    fontSize:32,



                    fontWeight:FontWeight.bold,



                  ),



                ),



              ),







              // السحب



              Positioned(



                top:80,


                left:30,



                child:cloud(),



              ),




              Positioned(



                top:180,


                right:40,



                child:cloud(),



              ),







              // الجزر



              ...islands.map((island){



                return Positioned(



                  left:

                  MediaQuery.of(context).size.width *

                  island.position.dx - 50,



                  top:

                  MediaQuery.of(context).size.height *

                  island.position.dy,





                  child:IslandWidget(



                    island:island,



                    onTap:(){



                      ScaffoldMessenger.of(context)

                          .showSnackBar(



                        SnackBar(



                          content:Text(



                            "فتح عالم ${island.title}",



                          ),



                        ),



                      );



                    },



                  ),



                );



              }),



            ],



          ),



        ),



      ),



    );


  }







  Widget cloud(){



    return Container(



      width:90,


      height:40,



      decoration:BoxDecoration(



        color:Colors.white.withOpacity(.8),



        borderRadius:

        BorderRadius.circular(40),



      ),



    );



  }


}