import 'package:flutter/material.dart';



class RewardBoxWidget extends StatefulWidget {


  final VoidCallback onRewardOpened;


  final GlobalKey starTarget;



  const RewardBoxWidget({

    super.key,

    required this.onRewardOpened,

    required this.starTarget,

  });



  @override
  State<RewardBoxWidget> createState() =>
      _RewardBoxWidgetState();


}







class _RewardBoxWidgetState
    extends State<RewardBoxWidget>
    with TickerProviderStateMixin {



  late AnimationController boxController;

  late AnimationController starController;

  late AnimationController pulseController;



  late Animation<double> boxScale;

  late Animation<double> boxRotate;


  late Animation<double> pulseAnimation;



  late Animation<double> starScale;

  late Animation<double> starOpacity;



  bool opened = false;

  bool showStar = false;

  bool movingStar = false;



  Offset starPosition = Offset.zero;









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

        curve:

        Curves.elasticOut,

      ),

    );





    boxRotate = Tween<double>(

      begin:-0.08,

      end:0.08,

    ).animate(

      CurvedAnimation(

        parent:boxController,

        curve:

        Curves.easeInOut,

      ),

    );









    pulseController = AnimationController(

      vsync:this,

      duration:

      const Duration(seconds:1),

    )..repeat(

      reverse:true,

    );





    pulseAnimation = Tween<double>(

      begin:0.95,

      end:1.08,

    ).animate(

      CurvedAnimation(

        parent:pulseController,

        curve:

        Curves.easeInOut,

      ),

    );









    starController = AnimationController(

      vsync:this,

      duration:

      const Duration(milliseconds:1200),

    );






    starScale = Tween<double>(

      begin:0.2,

      end:1,

    ).animate(

      CurvedAnimation(

        parent:starController,

        curve:

        Curves.elasticOut,

      ),

    );





    starOpacity = Tween<double>(

      begin:0,

      end:1,

    ).animate(

      CurvedAnimation(

        parent:starController,

        curve:

        Curves.easeIn,

      ),

    );



  }









  Future<void> openBox() async {



    if(opened){

      return;

    }



    opened=true;



    pulseController.stop();





    await boxController.forward();





    setState((){

      showStar=true;

    });





    await starController.forward();





    await Future.delayed(

      const Duration(milliseconds:300),

    );





    moveStarToToolbar();



  }









  void moveStarToToolbar(){



    final RenderBox? target =

    widget.starTarget.currentContext

        ?.findRenderObject()

    as RenderBox?;





    if(target == null){



      widget.onRewardOpened();


      return;

    }







    final position =

    target.localToGlobal(

      target.size.center(

        Offset.zero,

      ),

    );






    setState((){



      movingStar=true;


      starPosition=position;



    });






    Future.delayed(

      const Duration(milliseconds:900),

      (){



        widget.onRewardOpened();



      },

    );



  }









  @override
  Widget build(BuildContext context){



    return Center(



      child:

      GestureDetector(



        onTap:

        openBox,



        child:

        Stack(



          clipBehavior:

          Clip.none,



          alignment:

          Alignment.center,



          children:[






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

                    pulseAnimation.value,



                    child:

                    child,



                  ),



                );



              },





              child:

              Image.asset(



                "assets/images/rewards/reward_box.png",



                width:170,

                height:170,



                fit:

                BoxFit.contain,



              ),



            ),







            if(showStar && !movingStar)



              FadeTransition(



                opacity:

                starOpacity,



                child:

                ScaleTransition(



                  scale:

                  starScale,



                  child:

                  Image.asset(



                    "assets/images/rewards/Star_gold.png",



                    width:120,

                    height:120,



                  ),



                ),



              ),






            if(movingStar)



              AnimatedPositioned(



                duration:

                const Duration(milliseconds:900),



                curve:

                Curves.easeInOutCubic,



                left:

                starPosition.dx - 40,



                top:

                starPosition.dy - 40,



                child:

                Image.asset(



                  "assets/images/rewards/Star_gold.png",



                  width:80,

                  height:80,



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


    starController.dispose();


    pulseController.dispose();



    super.dispose();


  }



}