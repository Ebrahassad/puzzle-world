import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/world_provider.dart';



class WorldMapScreen extends ConsumerWidget {


  const WorldMapScreen({
    super.key,
  });





  @override
  Widget build(BuildContext context, WidgetRef ref) {


    final worlds = ref.watch(worldProvider);




    return Scaffold(



      body: Container(


        decoration: const BoxDecoration(


          gradient: LinearGradient(


            begin: Alignment.topCenter,


            end: Alignment.bottomCenter,


            colors: [


              Color(0xff7ED6FF),


              Color(0xff2E86DE),


            ],


          ),


        ),



        child: SafeArea(


          child: Column(


            children: [



              const SizedBox(height:20),





              const Text(


                "🌍 Puzzle World",


                style: TextStyle(


                  fontSize:32,


                  fontWeight:FontWeight.bold,


                  color:Colors.white,


                ),


              ),






              const SizedBox(height:20),






              Expanded(


                child: ListView.builder(



                  padding:

                  const EdgeInsets.all(20),



                  itemCount: worlds.length,



                  itemBuilder:(context,index){



                    final world = worlds[index];




                    return GestureDetector(



                      onTap: world.unlocked

                          ? (){


                        // دخول العالم


                      }

                          : null,



                      child: Container(



                        margin:

                        const EdgeInsets.only(

                          bottom:25,

                        ),




                        padding:

                        const EdgeInsets.all(20),




                        decoration:

                        BoxDecoration(



                          color:

                          Colors.white.withOpacity(.9),




                          borderRadius:

                          BorderRadius.circular(30),




                          boxShadow:[



                            BoxShadow(



                              color:

                              Colors.black.withOpacity(.15),



                              blurRadius:15,



                              offset:

                              const Offset(0,8),



                            )



                          ],



                        ),





                        child: Row(



                          children:[





                            Container(



                              width:80,



                              height:80,



                              decoration:

                              BoxDecoration(



                                shape:

                                BoxShape.circle,



                                color:

                                world.unlocked

                                    ? Colors.blue

                                    : Colors.grey,



                              ),



                              child:Icon(



                                world.unlocked

                                    ? Icons.public

                                    : Icons.lock,



                                color:

                                Colors.white,



                                size:40,



                              ),



                            ),






                            const SizedBox(width:20),






                            Expanded(



                              child:Column(



                                crossAxisAlignment:

                                CrossAxisAlignment.start,



                                children:[



                                  Text(



                                    world.worldId,



                                    style:

                                    const TextStyle(



                                      fontSize:24,



                                      fontWeight:

                                      FontWeight.bold,



                                    ),



                                  ),





                                  const SizedBox(height:8),





                                  LinearProgressIndicator(



                                    value:

                                    world.progress,



                                  ),





                                  const SizedBox(height:5),





                                  Text(



                                    "${world.completedLevels}/${world.totalLevels}",



                                  ),




                                ],



                              ),



                            ),



                          ],



                        ),



                      ),



                    );



                  },



                ),


              ),



            ],



          ),



        ),


      ),



    );


  }


}
