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


  int coins = 0;


  int rewards = 0;



  bool unlocked = true;



  final GlobalKey starKey = GlobalKey();



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







  String levelImage(int level){


    return

    "assets/images/Puzzle/${widget.island.id}/level_$level.png";


  }


  void openLevel(int level){


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


          child:Container(


            padding:
            const EdgeInsets.all(25),



            decoration:BoxDecoration(


              color:Colors.white,


              borderRadius:
              BorderRadius.circular(30),


            ),



            child:Column(


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

                  "🔒 المستوى مقفل",

                  style:

                  Theme.of(context)
                      .textTheme
                      .titleLarge,

                ),




                const SizedBox(height:10),




                const Text(

                  "اكمل المراحل السابقة لفتح المستوى",

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








  Widget levelCard(int level){



    bool open =
    level == 1;



    return GestureDetector(


      onTap:(){


        if(open){

          openLevel(level);

        }
        else{

          showLockedDialog();

        }


      },



      child:Container(


        margin:

        const EdgeInsets.symmetric(

          horizontal:20,

          vertical:8,

        ),



        height:95,



        decoration:BoxDecoration(


          color:
          Colors.white.withOpacity(.85),



          borderRadius:
          BorderRadius.circular(25),



          boxShadow:[


            const BoxShadow(

              blurRadius:8,

              color:Colors.black26,

            ),


          ],


        ),



        child:Stack(



          alignment:
          Alignment.center,



          children:[



            Row(


              children:[



                const SizedBox(width:15),




                Image.asset(


                  levelImage(level),


                  width:70,


                  height:70,


                  fit:
                  BoxFit.contain,


                ),




                const SizedBox(width:20),




                Text(


                  "المستوى $level",


                  style:

                  const TextStyle(

                    fontSize:22,

                    fontWeight:
                    FontWeight.bold,

                  ),


                ),



              ],


            ),






            if(!open)


              Positioned(


                right:20,


                child:Image.asset(


                  "assets/images/ui/level_lock.png",


                  width:38,


                  height:38,


                  errorBuilder:
                      (_,__,___){

                    return const Icon(

                      Icons.lock,

                      size:38,

                    );

                  },

                ),


              ),



          ],



        ),



      ),


    );


  }

  @override
  Widget build(BuildContext context){



    return Scaffold(



      body:Stack(



        children:[






          Positioned.fill(



            child:

            Container(



              decoration:

              const BoxDecoration(



                gradient:

                LinearGradient(



                  colors:[


                    Color(0xff8ED6FF),

                    Color(0xffDDF6FF),


                  ],



                  begin:

                  Alignment.topCenter,



                  end:

                  Alignment.bottomCenter,


                ),



              ),



            ),



          ),







          Align(



            alignment:

            Alignment.topCenter,



            child:

            Padding(



              padding:

              const EdgeInsets.only(

                top:80,

              ),



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

                Hero(



                  tag:

                  widget.island.id,



                  child:

                  Image.asset(



                    "assets/images/islands/${widget.island.id}_island.png",



                    height:260,



                    fit:

                    BoxFit.contain,



                    errorBuilder:

                        (_,__,___){



                      return const SizedBox();

                    },



                  ),



                ),



              ),



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



              coins:

              coins,



              rewards:

              rewards,



              starKey:

              starKey,



              onBack:(){



                Navigator.pop(context);



              },


            ),



          ),







          Positioned(



            top:310,



            left:20,

            right:20,



            child:

            Text(



              widget.island.title,



              textAlign:

              TextAlign.center,



              style:

              const TextStyle(



                fontSize:28,

                fontWeight:
                FontWeight.bold,

                color:
                Colors.white,

                shadows:[



                  Shadow(

                    blurRadius:5,

                    color:Colors.black54,

                  ),


                ],


              ),



            ),



          ),







          Positioned.fill(



            top:360,



            child:

            ListView.builder(



              padding:

              const EdgeInsets.only(

                bottom:30,

              ),



              itemCount:

              widget.island.totalLevels,



              itemBuilder:

                  (context,index){



                return levelCard(

                  index+1,

                );



              },



            ),



          ),




        ],



      ),



    );


  }







  @override
  void dispose(){


    floatController.dispose();


    super.dispose();


  }



}