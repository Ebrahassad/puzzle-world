import 'package:flutter/material.dart';

import '../managers/puzzle_progress_manager.dart';
import '../models/puzzle_model.dart';

import '../widgets/game_toolbar.dart';

import 'puzzle_level_screen.dart';



class IslandScreen extends StatefulWidget {


  final PuzzleModel island;



  const IslandScreen({

    super.key,

    required this.island,

  });



  @override
  State<IslandScreen> createState() =>
      _IslandScreenState();


}






class _IslandScreenState
    extends State<IslandScreen>
    with SingleTickerProviderStateMixin {



  int totalStars = 0;

  int rewards = 0;


  bool unlocked = true;



  late AnimationController floatController;

  late Animation<double> floatAnimation;








  @override
  void initState(){


    super.initState();


    loadData();



    floatController = AnimationController(

      vsync:this,

      duration:
      const Duration(seconds:3),

    )..repeat(

      reverse:true,

    );



    floatAnimation = Tween<double>(

      begin:-8,

      end:8,

    ).animate(

      CurvedAnimation(

        parent:floatController,

        curve:Curves.easeInOut,

      ),

    );


  }







  Future<void> loadData() async {


    final stars =
    await PuzzleProgressManager
        .getTotalStars();



    if(mounted){


      setState((){


        totalStars = stars;



        unlocked =
            stars >= widget.island.requiredStars;



      });


    }


  }







  void openLevels(){


    if(!unlocked){


      showLockedDialog();


      return;

    }




    Navigator.push(

      context,

      MaterialPageRoute(

        builder:(_)=>

            PuzzleLevelScreen(

              puzzle:widget.island,

            ),

      ),

    );


  }








  void showLockedDialog(){



    showDialog(

      context:context,


      builder:(_){


        return Dialog(


          backgroundColor:
          Colors.transparent,



          child:
          Container(



            padding:
            const EdgeInsets.all(25),



            decoration:
            BoxDecoration(



              color:
              Colors.white,



              borderRadius:
              BorderRadius.circular(30),



            ),



            child:
            Column(



              mainAxisSize:
              MainAxisSize.min,



              children:[




                Image.asset(

                  "assets/images/ui/level_lock.png",

                  height:80,

                  errorBuilder:
                      (_,__,___){

                    return const Icon(

                      Icons.lock,

                      size:70,

                    );

                  },

                ),




                const SizedBox(height:15),





                Text(

                  "🏝️ الجزيرة مقفلة",


                  style:
                  Theme.of(context)
                      .textTheme
                      .titleLarge,

                ),





                const SizedBox(height:10),





                Text(

                  "تحتاج ⭐ ${widget.island.requiredStars} لفتح هذه الجزيرة",


                  textAlign:
                  TextAlign.center,


                ),




                const SizedBox(height:20),





                ElevatedButton(

                  onPressed:(){

                    Navigator.pop(context);

                  },


                  child:
                  const Text(

                    "حسناً",

                  ),

                ),




              ],



            ),



          ),



        );


      },

    );


  }









  @override
  void dispose(){


    floatController.dispose();


    super.dispose();


  }








  @override
  Widget build(BuildContext context){



    return Scaffold(



      body:

      Stack(



        children:[






          Positioned.fill(



            child:

            Image.asset(



              widget.island.image,



              fit:

              BoxFit.cover,



              errorBuilder:

                  (_,__,___){



                return Container(

                  color:

                  Colors.blueGrey,

                );


              },


            ),



          ),







          Positioned.fill(



            child:

            Container(

              color:

              Colors.black26,

            ),



          ),







          Positioned(

            top:0,

            left:0,

            right:0,


            child:

            GameToolbar(


              logo:

              "assets/images/ui/puzzle_logo.png",



              stars:

              totalStars,



              rewards:

              rewards,



              onBack:(){


                Navigator.pop(context);


              },


            ),


          ),







          Center(



            child:

            AnimatedBuilder(



              animation:
              floatAnimation,



              builder:(context,child){



                return Transform.translate(



                  offset:

                  Offset(

                    0,

                    floatAnimation.value,

                  ),



                  child:

                  child,



                );



              },



              child:

              unlocked

                  ?

              const SizedBox()

                  :

              Image.asset(



                "assets/images/ui/level_lock.png",



                height:120,



                errorBuilder:

                    (_,__,___){



                  return const Icon(

                    Icons.lock,

                    color:Colors.white,

                    size:90,

                  );



                },



              ),



            ),



          ),








          Align(



            alignment:

            Alignment.bottomCenter,



            child:

            Container(



              margin:

              const EdgeInsets.all(20),



              padding:

              const EdgeInsets.all(22),



              decoration:

              BoxDecoration(



                color:

                Colors.white.withOpacity(.9),



                borderRadius:

                BorderRadius.circular(30),



              ),



              child:

              Column(



                mainAxisSize:

                MainAxisSize.min,



                children:[



                  Text(



                    widget.island.title,



                    style:

                    Theme.of(context)
                        .textTheme
                        .titleLarge,



                  ),




                  const SizedBox(height:8),





                  Text(



                    widget.island.description,



                    textAlign:

                    TextAlign.center,



                  ),




                  const SizedBox(height:15),





                  Text(



                    "🧩 ${widget.island.totalLevels} مراحل",



                    style:

                    const TextStyle(

                      fontSize:18,

                      fontWeight:

                      FontWeight.bold,

                    ),



                  ),





                  const SizedBox(height:15),





                  SizedBox(



                    width:

                    double.infinity,



                    height:

                    58,



                    child:

                    ElevatedButton(



                      onPressed:

                      openLevels,



                      style:

                      ElevatedButton.styleFrom(



                        backgroundColor:

                        Colors.orange,



                        shape:

                        RoundedRectangleBorder(



                          borderRadius:

                          BorderRadius.circular(30),



                        ),



                      ),



                      child:

                      const Text(



                        "ابدأ المغامرة 🧩",



                        style:

                        TextStyle(



                          color:

                          Colors.white,



                          fontSize:22,



                          fontWeight:

                          FontWeight.bold,



                        ),



                      ),



                    ),



                  ),



                ],



              ),



            ),



          ),




        ],



      ),



    );


  }


}