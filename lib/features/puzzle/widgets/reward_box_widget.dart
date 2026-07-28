import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';



class RewardBoxWidget extends StatefulWidget {


  final VoidCallback onRewardOpened;


  final VoidCallback? onStarReady;


  final GlobalKey? starTargetKey;



  const RewardBoxWidget({


    super.key,


    required this.onRewardOpened,


    this.onStarReady,


    this.starTargetKey,


  });




  @override
  State<RewardBoxWidget> createState() =>
      _RewardBoxWidgetState();

}






class _RewardBoxWidgetState

    extends State<RewardBoxWidget>

    with TickerProviderStateMixin {



  final AudioPlayer audioPlayer = AudioPlayer();



  late AnimationController boxController;


  late AnimationController pulseController;


  late AnimationController starController;



  late Animation<double> boxScale;


  late Animation<double> boxRotate;


  late Animation<double> pulseScale;



  late Animation<double> starScale;


  late Animation<double> starOpacity;


  late Animation<Offset> starMove;


  late Animation<double> starSize;




  bool opened = false;


  bool showStar = false;


  bool starArrived = false;



  Offset starOffset = Offset.zero;





  @override
  void initState(){


    super.initState();




    boxController = AnimationController(

      vsync:this,

      duration:

      const Duration(milliseconds:800),

    );





    boxScale = Tween<double>(

      begin:1,

      end:1.15,

    ).animate(

      CurvedAnimation(

        parent:boxController,

        curve:Curves.elasticOut,

      ),

    );





    boxRotate = Tween<double>(

      begin:-0.08,

      end:0.08,

    ).animate(

      CurvedAnimation(

        parent:boxController,

        curve:Curves.easeInOut,

      ),

    );





    pulseController = AnimationController(

      vsync:this,

      duration:

      const Duration(seconds:1),

    )

      ..repeat(reverse:true);





    pulseScale = Tween<double>(

      begin:0.95,

      end:1.08,

    ).animate(

      CurvedAnimation(

        parent:pulseController,

        curve:Curves.easeInOut,

      ),

    );





    starController = AnimationController(

      vsync:this,

      duration:

      const Duration(milliseconds:1500),

    );





    starScale = Tween<double>(

      begin:0.2,

      end:1,

    ).animate(

      CurvedAnimation(

        parent:starController,

        curve:Curves.elasticOut,

      ),

    );





    starOpacity = Tween<double>(

      begin:0,

      end:1,

    ).animate(

      CurvedAnimation(

        parent:starController,

        curve:Curves.easeIn,

      ),

    );





    starMove = Tween<Offset>(

      begin:Offset.zero,

      end:Offset.zero,

    ).animate(

      CurvedAnimation(

        parent:starController,

        curve:Curves.easeInOut,

      ),

    );





    starSize = Tween<double>(

      begin:120,

      end:28,

    ).animate(

      CurvedAnimation(

        parent:starController,

        curve:Curves.easeInOut,

      ),

    );


  }

  bool starArrived = false;


  Future<void> openBox() async {


    if(opened || !mounted){

      return;

    }


    opened = true;


    try{


      pulseController.stop();


      await playOpenSound();



      await boxController.forward();



      if(!mounted){

        return;

      }



      setState((){

        showStar = true;

      });





      calculateStarPosition();





      await starController.forward();





      if(widget.onStarReady != null){

        widget.onStarReady!();

      }





      await Future.delayed(

        const Duration(

          milliseconds:300,

        ),

      );





      if(!mounted){

        return;

      }





      widget.onRewardOpened();




    }catch(e){


      debugPrint(

        "Reward open error: $e",

      );



      if(mounted){

        widget.onRewardOpened();

      }


    }


  }







  Future<void> playOpenSound() async {


    try{


      await audioPlayer.play(


        AssetSource(

          "audio/reward_open.mp3",

        ),


      );


    }catch(e){


      debugPrint(

        "Reward sound error: $e",

      );


    }


  }







  Widget rewardImage(

      String path,

      double size,

      ){


    return Image.asset(


      path,


      width:size,


      height:size,


      errorBuilder:

          (_,__,___){


        return Icon(


          Icons.card_giftcard,


          size:size,


          color:Colors.orange,


        );


      },


    );


  }


  @override
  Widget build(BuildContext context){

    return Center(

      child: GestureDetector(

        onTap: openBox,


        child: Stack(

          alignment: Alignment.center,


          clipBehavior: Clip.none,


          children:[


            // صندوق المكافأة

            AnimatedBuilder(

              animation:

              Listenable.merge([

                boxController,

                pulseController,

              ]),


              builder:(context,child){


                return Transform.rotate(

                  angle:

                  boxRotate.value,


                  child:

                  Transform.scale(

                    scale:

                    boxScale.value *

                    pulseScale.value,


                    child:child,


                  ),


                );


              },


              child:

              rewardImage(

                "assets/images/rewards/reward_box.png",

                170,

              ),


            ),





            // النجمة التي تخرج من الصندوق

            if(showStar)


              AnimatedBuilder(

                animation:starController,


                builder:(context,child){


                  return Transform.translate(

                    offset:

                    starOffset *

                    starController.value,


                    child:

                    Transform.translate(

                      offset:

                      Offset(

                        0,

                        -120 *

                        starController.value,

                      ),


                      child:

                      Opacity(

                        opacity:

                        starOpacity.value,


                        child:

                        Transform.scale(

                          scale:

                          starScale.value,


                          child:child,


                        ),

                      ),

                    ),

                  );


                },


                child:

                AnimatedScale(

                  scale:

                  starArrived

                      ? 0.35

                      : 1,


                  duration:

                  const Duration(

                    milliseconds:500,

                  ),


                  child:

                  rewardImage(

                    "assets/images/rewards/Star_gold.png",

                    120,

                  ),


                ),


              ),



          ],


        ),


      ),


    );


  }

  @override
  void dispose(){


    try{


      boxController.dispose();


      pulseController.dispose();


      starController.dispose();


      audioPlayer.dispose();


    }catch(e){


      debugPrint(

        "Reward box dispose error: $e",

      );


    }



    super.dispose();


  }


}