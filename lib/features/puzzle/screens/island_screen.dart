import 'package:flutter/material.dart';

import '../data/puzzle_level_data.dart';
import '../managers/puzzle_progress_manager.dart';

import '../models/puzzle_model.dart';
import '../models/puzzle_level_model.dart';

import '../widgets/game_toolbar.dart';

import 'puzzle_game_screen.dart';



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
    with TickerProviderStateMixin {



  //==================================================
  // بيانات اللاعب
  //==================================================


  int totalStars = 0;


  int coins = 0;


  int rewards = 0;



  bool unlocked = false;



  final GlobalKey starKey = GlobalKey();





  //==================================================
  // حركة الجزيرة
  //==================================================


  late AnimationController floatController;


  late Animation<double> floatAnimation;





  //==================================================
  // حركة الخلفية
  //==================================================


  late AnimationController backgroundController;


  late Animation<double> backgroundMove;


  late Animation<double> backgroundScale;





  //==================================================
  // نظام الإعلانات
  //==================================================


  int requiredAds = 5;


  int watchedAds = 0;





  //==================================================
  // لون اسم الجزيرة
  //==================================================


  Color islandTitleColor(){


    switch(widget.island.id){


      case "animals":

        return const Color(0xffB87928);



      case "cars":

        return const Color(0xff2196F3);



      case "space":

        return const Color(0xff8E44AD);



      case "nature":

        return const Color(0xff4CAF50);



      case "landmarks":

        return const Color(0xffD4AF37);



      default:

        return Colors.white;


    }


  }









  @override
  void initState(){


    super.initState();



    loadData();





    // حركة الجزيرة العائمة


    floatController = AnimationController(

      vsync:this,

      duration:

      const Duration(

        seconds:3,

      ),

    )
      ..repeat(

        reverse:true,

      );





    floatAnimation = Tween<double>(

      begin:-8,

      end:8,

    )
        .animate(

      CurvedAnimation(

        parent:floatController,

        curve:Curves.easeInOut,

      ),

    );








    // حركة الخلفية


    backgroundController = AnimationController(

      vsync:this,

      duration:

      const Duration(

        seconds:25,

      ),

    )
      ..repeat(

        reverse:true,

      );






    backgroundMove = Tween<double>(

      begin:-10,

      end:10,

    )
        .animate(

      CurvedAnimation(

        parent:backgroundController,

        curve:Curves.easeInOut,

      ),

    );







    backgroundScale = Tween<double>(

      begin:1.0,

      end:1.03,

    )
        .animate(

      CurvedAnimation(

        parent:backgroundController,

        curve:Curves.easeInOut,

      ),

    );


  }









  //==================================================
  // تحميل بيانات الجزيرة
  //==================================================


  Future<void> loadData() async {


    final stars =

    await PuzzleProgressManager
        .getTotalStars();




    final islandOpened =

    await PuzzleProgressManager
        .isIslandUnlocked(

      widget.island.id,

    );




    final ads =

    PuzzleProgressManager
        .getIslandRequiredAds(

      widget.island.id,

    );




    final adsWatched =

    await PuzzleProgressManager
        .getIslandAds(

      widget.island.id,

    );





    final coinsValue =

    await PuzzleProgressManager
        .getCoins();






    if(mounted){


      setState((){


        totalStars = stars;


        coins = coinsValue;



        requiredAds = ads;


        watchedAds = adsWatched;




// نظام فتح الجزر

unlocked =
    islandOpened ||
    stars >= widget.island.requiredStars ||
    widget.island.id == "animals";


      });


    }


  }

  //==================================================
  // فتح المرحلة
  //==================================================


  void openLevel(int level) {


    if(!unlocked){


      showLockedDialog();


      return;


    }




    try {


      final levels =

      PuzzleLevelData.getLevels(

        widget.island.id,

      );





      final selectedLevel =


      levels.firstWhere(


            (item) =>

        item.levelNumber == level,


      );






      Navigator.push(


        context,


        MaterialPageRoute(


          builder:(_)=>


              PuzzleGameScreen(


                puzzle: widget.island,


                level: selectedLevel,


              ),


        ),


      );




    }

    catch(e){



      debugPrint(

        "خطأ في فتح المرحلة: $e",

      );



      ScaffoldMessenger.of(context)

          .showSnackBar(


        const SnackBar(


          content: Text(

            "حدث خطأ في فتح المرحلة",

          ),


        ),


      );



    }


  }









  //==================================================
  // نافذة الجزيرة المغلقة
  //==================================================


  void showLockedDialog(){


    showDialog(


      context: context,


      builder:(_){


        return Dialog(


          backgroundColor:

          Colors.transparent,



          child:Container(



            padding:

            const EdgeInsets.all(25),



            decoration:BoxDecoration(



              color:

              Colors.white,



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



                      size:75,



                    );


                  },


                ),





                const SizedBox(

                  height:15,

                ),





                Text(



                  "🔒 ${widget.island.title}",



                  textAlign:

                  TextAlign.center,



                  style:const TextStyle(



                    fontSize:22,



                    fontWeight:

                    FontWeight.bold,



                  ),



                ),





                const SizedBox(

                  height:10,

                ),






                Text(



                  "تحتاج ⭐ ${widget.island.requiredStars} لفتح الجزيرة\nأو شاهد $requiredAds إعلانات\n($watchedAds / $requiredAds)",



                  textAlign:

                  TextAlign.center,



                  style:const TextStyle(



                    fontSize:16,



                  ),



                ),






                const SizedBox(

                  height:20,

                ),






                ElevatedButton.icon(



                  icon:const Icon(

                    Icons.play_circle,

                  ),




                  label:const Text(

                    "شاهد إعلان",

                  ),




                  onPressed:(){



                    Navigator.pop(context);



                    watchRewardAd();



                  },



                ),






                TextButton(



                  onPressed:(){



                    Navigator.pop(context);



                  },



                  child:const Text(

                    "إلغاء",

                  ),



                ),




              ],



            ),



          ),



        );



      },


    );


  }









  //==================================================
  // مشاهدة إعلان لفتح الجزيرة
  //==================================================


  Future<void> watchRewardAd() async {


    // هنا يتم ربط AdMob Rewarded لاحقاً


    final opened =

    await PuzzleProgressManager

        .watchIslandAd(

      widget.island.id,

    );





    final ads =

    await PuzzleProgressManager

        .getIslandAds(

      widget.island.id,

    );






    if(opened){







      setState((){


        unlocked = true;


        watchedAds = requiredAds;


      });






      ScaffoldMessenger.of(context)

          .showSnackBar(



        const SnackBar(



          content:Text(

            "🎉 تم فتح الجزيرة",

          ),



        ),



      );



    }

    else{


      setState((){


        watchedAds = ads;


      });




      ScaffoldMessenger.of(context)

          .showSnackBar(



        SnackBar(



          content:Text(

            "📺 شاهد $ads / $requiredAds إعلانات",

          ),



        ),



      );



    }


  }

  //==================================================
  // زر المرحلة
  //==================================================


  Widget levelButton(int level){



    final levelKey =

        "${widget.island.id}_level_$level";





    return FutureBuilder<bool>(


      future:

      PuzzleProgressManager

          .isLevelUnlocked(

        levelKey,

      ),



      builder:(context,snapshot){



        final levelOpen =
    snapshot.data ?? (level == 1);



        return GestureDetector(



          onTap:(){



            if(!unlocked){


              showLockedDialog();


              return;


            }




            if(levelOpen){


              openLevel(level);


            }

            else{



              ScaffoldMessenger.of(context)

                  .showSnackBar(



                const SnackBar(



                  content:Text(

                    "أكمل المرحلة السابقة لفتح هذه المرحلة",

                  ),



                ),



              );



            }



          },





          child:AnimatedContainer(



            duration:

            const Duration(

              milliseconds:250,

            ),




            width:70,


            height:70,





            decoration:BoxDecoration(



              color:

              levelOpen

                  ? Colors.white

                  : Colors.white.withOpacity(0.55),





              shape:

              BoxShape.circle,





              boxShadow:[



                BoxShadow(



                  color:

                  Colors.black.withOpacity(0.25),



                  blurRadius:10,



                  offset:

                  const Offset(0,5),



                ),



              ],



            ),






            child:Center(



              child:

              !unlocked



                  ? Image.asset(



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


              )



                  : levelOpen



                  ? Text(



                "$level",



                style:const TextStyle(



                  fontSize:26,



                  fontWeight:

                  FontWeight.bold,



                  color:

                  Colors.blue,



                ),



              )



                  : Image.asset(



                "assets/images/ui/level_lock.png",



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



      },


    );



  }

  //==================================================
  // بناء الشاشة
  //==================================================


  @override
  Widget build(BuildContext context){


    return Scaffold(


      body:Stack(


        children:[




          //==================================================
          // خلفية شاشة الجزيرة
          //==================================================


          Positioned.fill(


            child:AnimatedBuilder(


              animation:backgroundController,


              builder:(context,child){



                return Transform.scale(



                  scale:

                  backgroundScale.value,





                  child:Transform.translate(



                    offset:Offset(



                      backgroundMove.value,



                      0,



                    ),



                    child:child,



                  ),



                );


              },



              child:Image.asset(



                "assets/images/background/level_background.png",



                fit:BoxFit.cover,



              ),



            ),



          ),






          // طبقة دمج خفيفة

          Container(


            color:

            Colors.white.withOpacity(0.08),


          ),








          //==================================================
          // الشريط العلوي
          //==================================================


          Positioned(


            top:0,


            left:0,


            right:0,



            child: GameToolbar(

  logo:
  "assets/images/ui/puzzle_logo.png",

  starKey:
  starKey,

  onBack:(){

    Navigator.pop(context);

  },

),


          ),







          //==================================================
          // الجزيرة الرئيسية 3D
          //==================================================


          Positioned(


            top:85,


            left:0,


            right:0,



            child:AnimatedBuilder(



              animation:floatAnimation,



              builder:(context,child){



                return Transform.translate(



                  offset:Offset(



                    0,



                    floatAnimation.value,



                  ),



                  child:child,



                );



              },





              child:Image.asset(



                widget.island.image,



                height:280,



                fit:BoxFit.contain,



                errorBuilder:

                    (_,__,___){



                  return const SizedBox();



                },



              ),



            ),



          ),







          //==================================================
          // اسم الجزيرة
          //==================================================


          Positioned(


            top:360,


            left:20,


            right:20,



            child:Text(



              widget.island.title,



              textAlign:

              TextAlign.center,





              style:TextStyle(



                color:

                islandTitleColor(),





                fontSize:30,





                fontWeight:

                FontWeight.w900,





                shadows:[



                  Shadow(



                    color:

                    Colors.black.withOpacity(0.35),



                    blurRadius:6,





                    offset:

                    const Offset(0,3),



                  ),



                ],



              ),



            ),



          ),







          //==================================================
          // شبكة المراحل
          //==================================================


          Positioned(


            top:470,


            left:20,


            right:20,


            bottom:20,



            child:GridView.builder(



              padding:

              const EdgeInsets.only(



                top:20,



                bottom:20,



              ),






              gridDelegate:

              const SliverGridDelegateWithFixedCrossAxisCount(



                crossAxisCount:4,



                crossAxisSpacing:22,



                mainAxisSpacing:22,



              ),






              itemCount:

              widget.island.totalLevels,







              itemBuilder:(context,index){



                return levelButton(



                  index + 1,



                );



              },



            ),



          ),




        ],


      ),


    );


  }








  //==================================================
  // إغلاق الأنيميشن
  //==================================================


  @override
  void dispose(){



    floatController.dispose();



    backgroundController.dispose();




    super.dispose();


  }