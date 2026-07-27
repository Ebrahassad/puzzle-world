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

      begin:-10,

      end:10,

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







  void openLevel(){


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

                  "assets/images/ui/lock.png",

                  height:70,


                  errorBuilder:
                      (_,__,___){

                    return const Icon(

                      Icons.lock,

                      size:65,

                    );

                  },

                ),




                const SizedBox(height:15),



                const Text(

                  "🔒 الجزيرة مغلقة",

                  style:

                  TextStyle(

                    fontSize:22,

                    fontWeight:

                    FontWeight.bold,

                  ),

                ),




                const SizedBox(height:10),




                Text(

                  "تحتاج ⭐ ${widget.island.requiredStars} لفتح الجزيرة",

                  textAlign:

                  TextAlign.center,

                  style:

                  const TextStyle(

                    fontSize:16,

                  ),

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







  Widget levelButton(int level){



    bool open =

    level == 1;



    return GestureDetector(



      onTap:(){

        if(open){

          openLevel();

        }

        else{

          showLockedDialog();

        }

      },



      child:AnimatedContainer(



        duration:

        const Duration(

          milliseconds:180,

        ),



        width:75,


        height:75,



        decoration:BoxDecoration(


          color:

          Colors.white.withOpacity(.90),



          borderRadius:

          BorderRadius.circular(22),



          boxShadow:[


            const BoxShadow(

              color:Colors.black26,

              blurRadius:8,

              offset:

              Offset(0,4),

            ),

          ],


        ),



        child:Center(



          child:open



              ? Text(

            "$level",

            style:

            const TextStyle(

              fontSize:24,

              fontWeight:

              FontWeight.bold,

            ),

          )

              :

          Image.asset(

            "assets/images/ui/lock.png",

            width:35,

            height:35,

            errorBuilder:

                (_,__,___){

              return const Icon(

                Icons.lock,

                size:35,

              );

            },

          ),



        ),



      ),



    );


  }

  @override
  Widget build(BuildContext context){


    return Scaffold(


      body:Stack(


        children:[



          // الخلفية

          Positioned.fill(

            child:Container(

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






          // الجزيرة العائمة الشفافة بالخلف

          Align(

            alignment:

            Alignment.topCenter,


            child:

            Padding(

              padding:

              const EdgeInsets.only(

                top:90,

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

                Opacity(

                  opacity:0.55,


                  child:

                  Image.asset(

                    widget.island.image,

                    height:320,

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







          // الشريط العلوي

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







          // اسم الجزيرة مع حركة الطفو

          Positioned(

            top:330,

            left:20,

            right:20,


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

              Text(

                widget.island.title,


                textAlign:

                TextAlign.center,


                style:

                const TextStyle(

                  fontSize:30,

                  fontWeight:

                  FontWeight.bold,

                  color:

                  Colors.white,

                  shadows:[

                    Shadow(

                      color:

                      Colors.black54,

                      blurRadius:8,

                      offset:

                      Offset(0,3),

                    ),

                  ],

                ),

              ),

            ),

          ),







          // أزرار المراحل

          Positioned.fill(

            top:410,


            child:

            GridView.builder(


              padding:

              const EdgeInsets.symmetric(

                horizontal:25,

                vertical:15,

              ),


              gridDelegate:

              const SliverGridDelegateWithFixedCrossAxisCount(


                crossAxisCount:5,


                crossAxisSpacing:12,


                mainAxisSpacing:12,


                childAspectRatio:1,

              ),


              itemCount:

              widget.island.totalLevels,


              itemBuilder:(context,index){


                return levelButton(

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