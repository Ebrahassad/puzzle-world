import 'package:flutter/material.dart';

import '../models/category_model.dart';
import '../models/puzzle_model.dart';
import '../data/puzzles_data.dart';

import 'levels_screen.dart';



class PuzzlesScreen extends StatelessWidget {


  final CategoryModel category;



  const PuzzlesScreen({

    super.key,

    required this.category,

  });



  @override
  Widget build(BuildContext context) {



    final puzzles =
    PuzzlesData.byCategory(category.id);



    return Scaffold(



      body: Container(



        decoration: const BoxDecoration(



          gradient: LinearGradient(



            colors: [

              Color(0xff89F7FE),

              Color(0xff66A6FF),

            ],



            begin: Alignment.topCenter,

            end: Alignment.bottomCenter,



          ),



        ),





        child: SafeArea(



          child: Column(



            children: [



              _TopBar(

                title: category.name,

              ),





              Expanded(



                child: puzzles.isEmpty



                    ? const Center(



                  child: Text(



                    'لا توجد صور حالياً',

                    style: TextStyle(

                      color: Colors.white,

                      fontSize:22,

                    ),

                  ),

                )



                    : GridView.builder(



                  padding:
                  const EdgeInsets.all(18),



                  itemCount:
                  puzzles.length,



                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(



                    crossAxisCount:2,



                    crossAxisSpacing:18,



                    mainAxisSpacing:18,



                    childAspectRatio:0.8,



                  ),




                  itemBuilder:(context,index){



                    return PuzzleCard(



                      puzzle:puzzles[index],



                    );



                  },



                ),



              ),



            ],



          ),



        ),



      ),



    );

  }

}







class _TopBar extends StatelessWidget {



  final String title;



  const _TopBar({

    required this.title,

  });



  @override
  Widget build(BuildContext context) {



    return Padding(



      padding: const EdgeInsets.all(16),



      child: Row(



        children: [



          IconButton(



            onPressed: (){

              Navigator.pop(context);

            },



            icon: const Icon(

              Icons.arrow_back_ios,

              color:Colors.white,

            ),

          ),





          Expanded(



            child: Text(



              title,



              textAlign:TextAlign.center,



              style:const TextStyle(



                color:Colors.white,



                fontSize:30,



                fontWeight:FontWeight.bold,



              ),



            ),



          ),





          const SizedBox(width:50),



        ],



      ),



    );

  }

}









class PuzzleCard extends StatelessWidget {



  final PuzzleModel puzzle;



  const PuzzleCard({

    super.key,

    required this.puzzle,

  });





  @override
  Widget build(BuildContext context) {



    return InkWell(



      borderRadius:
      BorderRadius.circular(25),




      onTap:(){



        Navigator.push(



          context,



          MaterialPageRoute(



            builder:(context)=>



            LevelsScreen(

              puzzle:puzzle,

            ),



          ),



        );



      },





      child: Container(



        decoration:BoxDecoration(



          color:Colors.white,



          borderRadius:
          BorderRadius.circular(25),




          boxShadow:const [



            BoxShadow(



              color:Colors.black26,



              blurRadius:12,



              offset:Offset(0,8),



            )



          ],



        ),




        child:Column(



          children:[





            Expanded(



              child:ClipRRect(



                borderRadius:
                const BorderRadius.vertical(

                  top:Radius.circular(25),

                ),




                child:Image.asset(



                  puzzle.image,



                  width:double.infinity,



                  fit:BoxFit.cover,



                  errorBuilder:
                  (context,error,stack)=>



                  const Icon(



                    Icons.extension,



                    size:70,



                    color:Colors.blue,



                  ),



                ),



              ),



            ),






            Padding(



              padding:
              const EdgeInsets.all(12),



              child:Column(



                children:[



                  Text(



                    puzzle.title,



                    style:const TextStyle(



                      fontSize:22,



                      fontWeight:
                      FontWeight.bold,



                    ),



                  ),




                  const SizedBox(height:5),




                  Text(



                    '${puzzle.pieces} قطعة',



                    style:const TextStyle(

                      fontSize:16,

                    ),



                  ),



                ],



              ),



            ),



          ],



        ),



      ),



    );

  }

}
