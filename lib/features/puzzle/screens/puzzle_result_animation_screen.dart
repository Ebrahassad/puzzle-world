import 'package:flutter/material.dart';

import '../models/game_result_model.dart';
import '../models/puzzle_level_model.dart';
import '../models/puzzle_model.dart';

import '../widgets/reward_box_widget.dart';
import '../screens/puzzle_win_screen.dart';



class PuzzleResultAnimationScreen extends StatefulWidget {


  final GameResultModel result;


  final PuzzleLevelModel level;


  // مكان النجمة في التول بار

  final GlobalKey starKey;



  // صورة البازل المكتملة

  final String image;
final PuzzleModel island;


  const PuzzleResultAnimationScreen({

    super.key,

    required this.result,

    required this.level,

    required this.starKey,

    required this.image,

required this.island,

  });



  @override
  State<PuzzleResultAnimationScreen> createState() =>
      _PuzzleResultAnimationScreenState();


}






class _PuzzleResultAnimationScreenState

    extends State<PuzzleResultAnimationScreen>

    with TickerProviderStateMixin {



  late AnimationController imageController;


  late Animation<double> imageScale;


  late Animation<double> imageOpacity;



  bool showRewardBox = false;


  bool winScreenOpened = false;


  @override
  void initState(){

    super.initState();



    imageController =
        AnimationController(

          vsync:this,

          duration:
          const Duration(

            milliseconds:1200,

          ),

        );




    imageScale =
        Tween<double>(

          begin:0.2,

          end:1,

        ).animate(

          CurvedAnimation(

            parent:imageController,

            curve:
            Curves.easeOutBack,

          ),

        );





    imageOpacity =
        Tween<double>(

          begin:0,

          end:1,

        ).animate(

          CurvedAnimation(

            parent:imageController,

            curve:
            Curves.easeIn,

          ),

        );



    startAnimation();


  }






  Future<void> startAnimation() async {


    await imageController.forward();



    await Future.delayed(

      const Duration(

        milliseconds:700,

      ),

    );



    if(!mounted)return;



    setState((){

      showRewardBox=true;

    });


  }

@override
Widget build(BuildContext context) {

  return Scaffold(

    backgroundColor:
    Colors.black,

    body:Stack(

      alignment:
      Alignment.center,


      children:[




        // خلفية الشاشة

        Positioned.fill(

          child:
          Image.asset(

            "assets/images/background/win_background.png",

            fit:
            BoxFit.cover,

          ),

        ),





        // طبقة شفافية

        Positioned.fill(

          child:
          Container(

            color:
            Colors.black.withOpacity(
              0.25,
            ),

          ),

        ),







        // صورة البازل المكتملة

        AnimatedBuilder(

          animation:
          imageController,


          builder:(context,child){


            return Opacity(

              opacity:
              imageOpacity.value,


              child:
              Transform.scale(

                scale:
                imageScale.value,


                child:child,

              ),

            );


          },


          child:
          Container(

            width:300,

            height:300,


            decoration:
            BoxDecoration(

              borderRadius:
              BorderRadius.circular(25),


              boxShadow:[

                BoxShadow(

                  color:
                  Colors.black45,

                  blurRadius:25,

                  spreadRadius:5,

                ),

              ],


            ),



            child:
            ClipRRect(

              borderRadius:
              BorderRadius.circular(25),


              child:
              Image.asset(

                widget.image,

                fit:
                BoxFit.cover,

              ),

            ),


          ),

        ),








        // صندوق المكافأة

        if(showRewardBox)

          RewardBoxWidget(

            starTargetKey:
            widget.starKey,


            onStarReady:(){

              openWinScreen();

            },


            onRewardOpened:(){

              // فقط تأكيد انتهاء الصندوق

            },

          ),





      ],


    ),


  );


}






void openWinScreen(){


  if (winScreenOpened) {
  return;
}

winScreenOpened = true;


  Future.delayed(

    const Duration(

      milliseconds:600,

    ),


    (){


      if(!mounted)return;



      Navigator.pushReplacement(

        context,


        MaterialPageRoute(

          builder:(_)=>

          PuzzleWinScreen(

  island: widget.island,

),

        ),

      );


    },


  );


}





@override
void dispose(){

  imageController.dispose();

  super.dispose();

}


}