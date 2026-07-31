import 'package:flutter/material.dart';

import '../data/puzzle_data.dart';
import '../models/puzzle_model.dart';

import 'island_screen.dart';



class WorldMapScreen extends StatefulWidget {

  const WorldMapScreen({
    super.key,
  });


  @override
  State<WorldMapScreen> createState()
      => _WorldMapScreenState();

}






class _WorldMapScreenState extends State<WorldMapScreen>
    with TickerProviderStateMixin {


  static const String mapImage =
      "assets/images/world/world_map.png";


  static const double worldWidth = 896;

  static const double worldHeight = 1350;




  late final List<PuzzleModel> islands;



  late final AnimationController worldController;

  late final Animation<double> worldScale;



  late final AnimationController islandController;

  late final Animation<double> islandFloat;



  late final AnimationController cloudController1;

  late final AnimationController cloudController2;

  late final AnimationController cloudController3;

  late final AnimationController cloudController4;







  @override
  void initState() {

    super.initState();


    islands = PuzzleData.puzzles;



    worldController = AnimationController(

      vsync: this,

      duration: const Duration(seconds:18),

    )..repeat(reverse:true);




    worldScale = Tween<double>(

      begin:1.0,

      end:1.012,

    ).animate(

      CurvedAnimation(

        parent:worldController,

        curve:Curves.easeInOut,

      ),

    );







    islandController = AnimationController(

      vsync:this,

      duration:const Duration(seconds:5),

    )..repeat(reverse:true);




    islandFloat = Tween<double>(

      begin:-4,

      end:4,

    ).animate(

      CurvedAnimation(

        parent:islandController,

        curve:Curves.easeInOut,

      ),

    );







    cloudController1 = AnimationController(

      vsync:this,

      duration:const Duration(seconds:55),

    )..repeat();



    cloudController2 = AnimationController(

      vsync:this,

      duration:const Duration(seconds:70),

    )..repeat();



    cloudController3 = AnimationController(

      vsync:this,

      duration:const Duration(seconds:90),

    )..repeat();



    cloudController4 = AnimationController(

      vsync:this,

      duration:const Duration(seconds:65),

    )..repeat();



  }








  @override
  void dispose(){

    worldController.dispose();

    islandController.dispose();

    cloudController1.dispose();

    cloudController2.dispose();

    cloudController3.dispose();

    cloudController4.dispose();


    super.dispose();

  }







  PuzzleModel getIsland(String id){

    return islands.firstWhere(
        (item)=>item.id == id
    );

  }








  @override
  Widget build(BuildContext context){


    return Scaffold(

      backgroundColor:
      const Color(0xff08182b),


      body:SizedBox.expand(


        child:ClipRect(


          child:FittedBox(

            fit:BoxFit.cover,


            child:AnimatedBuilder(

              animation:worldController,


              builder:(context,child){


                return Transform.scale(

                  scale:worldScale.value,

                  child:child,

                );

              },



              child:SizedBox(

                width:worldWidth,

                height:worldHeight,



                child:Stack(


                  clipBehavior:Clip.none,


                  children:[





                    Positioned.fill(

                      child:Image.asset(

                        mapImage,

                        fit:BoxFit.fill,

                      ),

                    ),






                    cloud(

                      controller:cloudController1,

                      image:"assets/images/background/cloud_01.png",

                      top:80,

                      size:280,

                    ),



                    cloud(

                      controller:cloudController2,

                      image:"assets/images/background/cloud_02.png",

                      top:200,

                      size:220,

                    ),



                    cloud(

                      controller:cloudController3,

                      image:"assets/images/background/cloud_03.png",

                      top:40,

                      size:170,

                    ),



                    cloud(

                      controller:cloudController4,

                      image:"assets/images/background/cloud_04.png",

                      top:300,

                      size:240,

                    ),







                    islandImage(

                      id:"space",

                      left:260,

                      top:20,

                      width:370,

                      height:450,

                    ),





                    islandImage(

                      id:"landmarks",

                      left:120,

                      top:330,

                      width:280,

                      height:360,

                    ),





                    islandImage(

                      id:"cars",

                      left:500,

                      top:330,

                      width:280,

                      height:360,

                    ),





                    islandImage(

                      id:"nature",

                      left:275,

                      top:590,

                      width:320,

                      height:395,

                    ),





                    islandImage(

                      id:"animals",

                      left:285,

                      top:980,

                      width:320,

                      height:390,

                    ),



                  ],

                ),

              ),

            ),

          ),

        ),

      ),

    );


  }









  Widget cloud({

    required AnimationController controller,

    required String image,

    required double top,

    required double size,

  }){


    return AnimatedBuilder(

      animation:controller,


      builder:(context,child){


        return Positioned(

          left:
(worldWidth + 100) -
(controller.value * (worldWidth + 400)),


          top:top,

          child:Opacity(

            opacity:0.22,


            child:Transform.rotate(

              angle:
              controller.value * 0.15,


              child:child,

            ),

          ),

        );


      },


      child:Image.asset(

        image,

        width:size,

      ),

    );


  }









  Widget islandImage({

    required String id,

    required double left,

    required double top,

    required double width,

    required double height,

  }){


    final island = getIsland(id);



    return AnimatedBuilder(

      animation:islandController,


      builder:(context,child){


        return Positioned(

          left:left,

          top:top + islandFloat.value,

          width:width,

          height:height,


          child:GestureDetector(

            onTap:()=>openIsland(island),


            child:Image.asset(

              island.image,

              fit:BoxFit.contain,

            ),

          ),

        );


      },

    );


  }








  void openIsland(PuzzleModel island){

    Navigator.push(

      context,

      MaterialPageRoute(

        builder:(_)=>IslandScreen(

          island:island,

        ),

      ),

    );

  }


}
