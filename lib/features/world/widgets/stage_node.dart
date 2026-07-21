import 'package:flutter/material.dart';

import '../models/stage_node_model.dart';



class StageNode extends StatefulWidget {


  final StageNodeModel node;


  final VoidCallback? onTap;



  const StageNode({


    super.key,


    required this.node,


    this.onTap,

  });



  @override

  State<StageNode> createState() => _StageNodeState();

}




class _StageNodeState extends State<StageNode>

with SingleTickerProviderStateMixin {



  late AnimationController controller;



  @override

  void initState(){


    super.initState();



    controller = AnimationController(


      vsync:this,


      duration:

      const Duration(seconds:1),


    )..repeat(

      reverse:true,

    );


  }





  @override

  void dispose(){


    controller.dispose();


    super.dispose();


  }






  @override

  Widget build(BuildContext context){


    return ScaleTransition(


      scale:Tween<double>(


        begin:1,


        end:1.1,


      ).animate(controller),




      child:GestureDetector(



        onTap:

        widget.node.unlocked

            ? widget.onTap

            : null,



        child:Container(



          width:55,


          height:55,



          decoration:BoxDecoration(



            shape:BoxShape.circle,



            color:

            widget.node.unlocked

                ? Colors.orange

                : Colors.grey,



            boxShadow:[



              BoxShadow(



                color:

                Colors.black.withOpacity(.2),



                blurRadius:8,



              )



            ],



          ),




          child:Center(



            child:Column(



              mainAxisAlignment:

              MainAxisAlignment.center,



              children:[



                Icon(



                  widget.node.unlocked

                      ? Icons.star

                      : Icons.lock,



                  color:Colors.white,


                  size:20,


                ),




                Text(



                  "${widget.node.level}",



                  style:

                  const TextStyle(



                    color:Colors.white,


                    fontWeight:

                    FontWeight.bold,


                  ),



                ),



              ],



            ),



          ),



        ),



      ),



    );


  }

}