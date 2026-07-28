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



  final AudioPlayer audioPlayer =
      AudioPlayer();



  late AnimationController boxController;

  late AnimationController pulseController;

  late AnimationController starController;



  late Animation<double> boxScale;

  late Animation<double> boxRotate;

  late Animation<double> pulseScale;



  late Animation<double> starScale;

  late Animation<double> starOpacity;


late Animation<Offset> starMove;


  Offset starOffset = Offset.zero;



  bool opened = false;

  bool showStar = false;

  bool starArrived = false;



  @override
  void initState(){


    super.initState();



    // حركة الصندوق

    boxController = AnimationController(

      vsync:this,

      duration:
      const Duration(
        milliseconds:800,
      ),

    );



    boxScale =
        Tween<double>(
          begin:1,
          end:1.15,
        ).animate(

          CurvedAnimation(

            parent:
            boxController,

            curve:
            Curves.elasticOut,

          ),

        );




    boxRotate =
        Tween<double>(
          begin:-0.08,
          end:0.08,
        ).animate(

          CurvedAnimation(

            parent:
            boxController,

            curve:
            Curves.easeInOut,

          ),

        );





    // لمعان الصندوق

    pulseController =
        AnimationController(

          vsync:this,

          duration:
          const Duration(
            seconds:1,
          ),

        )
          ..repeat(
            reverse:true,
          );




    pulseScale =
        Tween<double>(
          begin:0.95,
          end:1.08,
        ).animate(

          CurvedAnimation(

            parent:
            pulseController,

            curve:
            Curves.easeInOut,

          ),

        );






    // حركة النجمة

    starController =
        AnimationController(

          vsync:this,

          duration:
          const Duration(
            milliseconds:1500,
          ),

        );



    starScale =
        Tween<double>(
          begin:0.1,
          end:1,
        ).animate(

          CurvedAnimation(

            parent:
            starController,

            curve:
            Curves.elasticOut,

          ),

        );



    starOpacity =
        Tween<double>(
          begin:0,
          end:1,
        ).animate(

          CurvedAnimation(

            parent:
            starController,

            curve:
            Curves.easeIn,

          ),

        );


  }

starMove =
    Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(

      CurvedAnimation(

        parent:
        starController,

        curve:
        Curves.easeInOut,

      ),

    );


  void calculateStarPosition(){

    if(widget.starTargetKey == null){
      return;
    }


    try{


      final targetBox =
      widget.starTargetKey!
          .currentContext
          ?.findRenderObject()
          as RenderBox?;



      final currentBox =
      context.findRenderObject()
          as RenderBox?;



      if(targetBox == null ||
          currentBox == null){

        return;

      }



      final targetPosition =
      targetBox.localToGlobal(

        Offset(

          targetBox.size.width / 2,

          targetBox.size.height / 2,

        ),

      );



      final currentPosition =
      currentBox.localToGlobal(

        Offset(

          currentBox.size.width / 2,

          currentBox.size.height / 2,

        ),

      );




      setState((){


        starOffset = Offset(

          targetPosition.dx -
              currentPosition.dx,


          targetPosition.dy -
              currentPosition.dy,


        );


      });



    }catch(e){


      debugPrint(

        "Star position error: $e",

      );


    }


  }







  Future<void> openBox() async {


    if(opened || !mounted){

      return;

    }



    opened = true;



    try{



      pulseController.stop();



      await audioPlayer.play(

        AssetSource(
          "audio/reward_open.mp3",
        ),

      );





      await boxController.forward();





      if(!mounted){

        return;

      }






      setState((){

        showStar = true;

      });





      calculateStarPosition();





      await starController.forward();






      if(!mounted){

        return;

      }





      setState((){

        starArrived = true;

      });






      if(widget.onStarReady != null){

        widget.onStarReady!();

      }





      await Future.delayed(

        const Duration(

          milliseconds:500,

        ),

      );





      if(!mounted){

        return;

      }





      widget.onRewardOpened();





    }catch(e){


      debugPrint(

        "Open reward box error: $e",

      );



      widget.onRewardOpened();


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

      fit:

      BoxFit.contain,

      errorBuilder:

          (_,__,___){

        return Icon(

          Icons.card_giftcard,

          size:size,

          color:

          Colors.orange,

        );

      },

    );

  }


 
  @override
  Widget build(BuildContext context){


    return Center(


      child: GestureDetector(


        onTap:openBox,



        child:Stack(


          alignment:

          Alignment.center,


          clipBehavior:

          Clip.none,



          children:[




            // 🎁 صندوق المكافأة

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







            // ⭐ النجمة الذهبية

            if(showStar)


              AnimatedBuilder(



                animation:

                starController,



                builder:(context,child){



                  return Transform.translate(

  offset:

  Offset(

    starOffset.dx *

    starController.value,


    (starOffset.dy - 120) *

    starController.value,


  ),


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



    boxController.dispose();


    pulseController.dispose();


    starController.dispose();


    audioPlayer.dispose();



    super.dispose();


  }


}
