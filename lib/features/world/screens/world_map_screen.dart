import 'package:flutter/material.dart';

import '../data/islands_data.dart';
import '../widgets/island_widget.dart';
import 'world_levels_screen.dart';



class WorldMapScreen extends StatelessWidget {


  const WorldMapScreen({
    super.key,
  });



  @override
  Widget build(BuildContext context) {


    return Scaffold(


      body: Container(


        decoration: const BoxDecoration(


          gradient: LinearGradient(


            begin: Alignment.topCenter,


            end: Alignment.bottomCenter,


            colors: [


              Color(0xff74D7FF),


              Color(0xff2196F3),


            ],


          ),


        ),



        child: SafeArea(


          child: Stack(


            children: [



              Positioned(


                top:20,


                left:0,


                right:0,


                child: const Text(


                  "🌍 Puzzle World",


                  textAlign: TextAlign.center,


                  style: TextStyle(


                    color: Colors.white,


                    fontSize:32,


                    fontWeight:FontWeight.bold,


                  ),


                ),


              ),





              Positioned(


                top:80,


                left:30,


                child: cloud(),


              ),




              Positioned(


                top:180,


                right:40,


                child: cloud(),


              ),





              ...islands.map((island){


                return Positioned(


                  left:

                  MediaQuery.of(context).size.width *

                  island.position.dx - 50,



                  top:

                  MediaQuery.of(context).size.height *

                  island.position.dy,





                  child: IslandWidget(


                    island:island,



                    onTap:(){



                      Navigator.push(


                        context,


                        MaterialPageRoute(


                          builder:(context)=>


                          WorldLevelsScreen(


                            worldId:island.worldId,


                            title:island.title,


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