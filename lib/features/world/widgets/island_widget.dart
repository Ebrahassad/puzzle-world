import 'package:flutter/material.dart';

import '../models/island_model.dart';



class IslandWidget extends StatefulWidget {


  final IslandModel island;


  final VoidCallback? onTap;



  const IslandWidget({

    super.key,

    required this.island,

    this.onTap,

  });



  @override
  State<IslandWidget> createState() =>
      _IslandWidgetState();

}




class _IslandWidgetState
    extends State<IslandWidget>
    with SingleTickerProviderStateMixin {



  late AnimationController controller;


  late Animation<double> scale;



  @override
  void initState() {


    super.initState();



    controller = AnimationController(


      vsync:this,


      duration:

      const Duration(seconds:2),


    )..repeat(

      reverse:true,

    );




    scale = Tween<double>(


      begin:1,


      end:1.08,


    ).animate(

      CurvedAnimation(

        parent:controller,

        curve:Curves.easeInOut,

      ),

    );


  }





  @override
  void dispose(){


    controller.dispose();


    super.dispose();


  }






  @override
  Widget build(BuildContext context) {


    return ScaleTransition(


      scale:scale,



      child:GestureDetector(



        onTap:

        widget.island.unlocked

            ? widget.onTap

            : null,



        child:Column(



          children:[



            Container(



              width:100,


              height:100,



              decoration:BoxDecoration(



                shape:

                BoxShape.circle,



                color:

                widget.island.unlocked

                    ? widget.island.color

                    : Colors.grey,



                boxShadow:[



                  BoxShadow(



                    color:

                    Colors.black.withOpacity(.25),



                    blurRadius:15,


                    offset:

                    const Offset(0,8),



                  ),



                ],



              ),



              child:Icon(



                widget.island.unlocked

                    ? widget.island.icon

                    : Icons.lock,



                size:45,



                color:Colors.white,



              ),



            ),





            const SizedBox(height:8),





            Container(



              padding:

              const EdgeInsets.symmetric(



                horizontal:15,



                vertical:6,



              ),



              decoration:BoxDecoration(



                color:

                Colors.white,



                borderRadius:

                BorderRadius.circular(20),



              ),



              child:Text(



                widget.island.title,



                style:

                const TextStyle(



                  fontWeight:

                  FontWeight.bold,



                ),



              ),



            ),




          ],



        ),



      ),



    );


  }


}
