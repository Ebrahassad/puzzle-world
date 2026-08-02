import 'package:flutter/material.dart';


class FlyingCoin extends StatefulWidget {

  final Offset start;
  final Offset end;
  final VoidCallback onFinished;


  const FlyingCoin({

    super.key,

    required this.start,

    required this.end,

    required this.onFinished,

  });


  @override
  State<FlyingCoin> createState() =>
      _FlyingCoinState();

}



class _FlyingCoinState extends State<FlyingCoin>
    with SingleTickerProviderStateMixin {


  late AnimationController controller;

  late Animation<Offset> position;



  @override
  void initState(){

    super.initState();


    controller =
        AnimationController(

          vsync:this,

          duration:
          const Duration(milliseconds:700),

        );



    position =
        Tween<Offset>(

          begin:widget.start,

          end:widget.end,

        ).animate(

          CurvedAnimation(

            parent:controller,

            curve:Curves.easeInOut,

          ),

        );



    controller.forward()
      .then((_){

        widget.onFinished();

      });

  }



  @override
  Widget build(BuildContext context){

    return AnimatedBuilder(

      animation:controller,

      builder:(context,child){


        return Positioned(

          left:position.value.dx,

          top:position.value.dy,


          child:const Text(

            "🪙",

            style:TextStyle(

              fontSize:32,

            ),

          ),

        );


      },

    );

  }



  @override
  void dispose(){

    controller.dispose();

    super.dispose();

  }

}