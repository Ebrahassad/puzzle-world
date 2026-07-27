import 'package:flutter/material.dart';


class RewardBoxWidget extends StatefulWidget {


  final VoidCallback onRewardOpened;


  const RewardBoxWidget({

    super.key,

    required this.onRewardOpened,

  });



  @override
  State<RewardBoxWidget> createState() =>
      _RewardBoxWidgetState();

}





class _RewardBoxWidgetState
    extends State<RewardBoxWidget>
    with SingleTickerProviderStateMixin {



  late AnimationController controller;


  late Animation<double> scaleAnimation;

  late Animation<double> rotateAnimation;


  bool opened = false;


  bool showStar = false;



  @override
  void initState(){


    super.initState();


    controller = AnimationController(

      vsync: this,

      duration: const Duration(milliseconds:900),

    );



    scaleAnimation = Tween<double>(

      begin: 1,

      end: 1.12,

    ).animate(

      CurvedAnimation(

        parent: controller,

        curve: Curves.easeInOut,

      ),

    );



    rotateAnimation = Tween<double>(

      begin: -0.05,

      end: 0.05,

    ).animate(

      CurvedAnimation(

        parent: controller,

        curve: Curves.elasticInOut,

      ),

    );


  }





  Future<void> openBox() async {



    if(opened){

      return;

    }


    opened=true;



    await controller.forward();



    setState((){

      showStar=true;

    });



    await Future.delayed(

      const Duration(milliseconds:1200),

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


          children:[



            AnimatedBuilder(


              animation:controller,


              builder:(context,child){


                return Transform.rotate(


                  angle:rotateAnimation.value,


                  child:Transform.scale(


                    scale:scaleAnimation.value,


                    child:child,


                  ),


                );


              },


              child:Image.asset(


                "assets/images/rewards/reward_box.png",


                width:170,

                height:170,


              ),


            ),





            if(showStar)


              TweenAnimationBuilder<double>(


                tween:Tween(

                  begin:0.3,

                  end:1,

                ),


                duration:

                const Duration(milliseconds:700),


                builder:(context,value,child){


                  return Transform.scale(


                    scale:value,


                    child:Opacity(


                      opacity:value,


                      child:child,


                    ),


                  );


                },


                child:Image.asset(


                  "assets/images/rewards/Star_gold.png",


                  width:120,

                  height:120,


                ),


              ),



          ],


        ),


      ),


    );


  }






  @override
  void dispose(){


    controller.dispose();


    super.dispose();


  }


}