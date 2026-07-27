import 'package:flutter/material.dart';



class RewardBoxWidget extends StatefulWidget {


  final VoidCallback onRewardOpened;

  final VoidCallback? onStarReady;



  const RewardBoxWidget({

    super.key,

    required this.onRewardOpened,

    this.onStarReady,

  });






  @override
  State<RewardBoxWidget> createState() =>
      _RewardBoxWidgetState();


}









class _RewardBoxWidgetState
    extends State<RewardBoxWidget>
    with TickerProviderStateMixin {



  late AnimationController boxController;

  late AnimationController pulseController;

  late AnimationController starController;



  late Animation<double> boxScale;

  late Animation<double> boxRotate;

  late Animation<double> pulseScale;



  late Animation<double> starScale;

  late Animation<double> starOpacity;

  late Animation<Offset> starMove;




  bool opened = false;

  bool showStar = false;









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

    )..repeat(

      reverse:true,

    );







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

      end:

      const Offset(0,-2.5),

    ).animate(

      CurvedAnimation(

        parent:starController,

        curve:Curves.easeOut,

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







    if(widget.onStarReady != null){


      widget.onStarReady!();


    }







    await Future.delayed(

      const Duration(milliseconds:800),

    );






    widget.onRewardOpened();



  }









  @override
  Widget build(BuildContext context){



    return Center(



      child:GestureDetector(



        onTap:openBox,



        child:Stack(



          alignment:Alignment.center,



          clipBehavior:Clip.none,



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

                    pulseScale.value,



                    child:child,



                  ),



                );



              },



              child:

              Image.asset(



                "assets/images/rewards/reward_box.png",



                width:170,

                height:170,



              ),



            ),







            if(showStar)



              SlideTransition(



                position:

                starMove,



                child:

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


    super.dispose();


  }


}