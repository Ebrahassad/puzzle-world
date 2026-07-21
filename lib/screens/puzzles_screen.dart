import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../data/puzzles_data.dart';
import '../models/puzzle_model.dart';

class PuzzlesScreen extends StatelessWidget {
  final CategoryModel category;

  const PuzzlesScreen({
    super.key,
    required this.category,
  });


  @override
  Widget build(BuildContext context) {

    final List<PuzzleModel> puzzles =
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


              Padding(

                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 15,
                ),

                child: Row(

                  children: [


                    IconButton(

                      onPressed: () {
                        Navigator.pop(context);
                      },

                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),

                    ),


                    Expanded(

                      child: Text(

                        category.name,

                        textAlign: TextAlign.center,

                        style: const TextStyle(

                          color: Colors.white,

                          fontSize: 30,

                          fontWeight: FontWeight.bold,

                          shadows: [

                            Shadow(

                              blurRadius: 8,

                              offset: Offset(2,3),

                            )

                          ],

                        ),

                      ),

                    ),


                    const SizedBox(width: 45),


                  ],

                ),

              ),



              Expanded(

                child: puzzles.isEmpty

                    ? const Center(

                        child: Text(

                          'لا توجد ألغاز حالياً',

                          style: TextStyle(

                            fontSize: 22,

                            color: Colors.white,

                          ),

                        ),

                      )


                    : GridView.builder(

                        padding: const EdgeInsets.all(18),


                        itemCount: puzzles.length,


                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(

                          crossAxisCount: 2,

                          crossAxisSpacing: 18,

                          mainAxisSpacing: 18,

                          childAspectRatio: 0.85,

                        ),


                        itemBuilder: (context,index){


                          final puzzle = puzzles[index];


                          return _PuzzleCard(
                            puzzle: puzzle,
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



class _PuzzleCard extends StatelessWidget {


  final PuzzleModel puzzle;


  const _PuzzleCard({

    required this.puzzle,

  });



  @override
  Widget build(BuildContext context) {


    return Container(

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius: BorderRadius.circular(25),


        boxShadow: const [

          BoxShadow(

            color: Colors.black26,

            blurRadius: 12,

            offset: Offset(0,8),

          )

        ],

      ),


      child: Column(

        children: [


          Expanded(

            child: ClipRRect(

              borderRadius:
              const BorderRadius.vertical(
                top: Radius.circular(25),
              ),

              child: Image.asset(

                puzzle.image,

                width: double.infinity,

                fit: BoxFit.cover,


                errorBuilder:
                (context,error,stackTrace){

                  return const Icon(

                    Icons.extension,

                    size:70,

                    color:Colors.blue,

                  );

                },

              ),

            ),

          ),



          Padding(

            padding: const EdgeInsets.all(10),

            child: Column(

              children: [


                Text(

                  puzzle.title,

                  style: const TextStyle(

                    fontSize:20,

                    fontWeight:FontWeight.bold,

                  ),

                ),



                const SizedBox(height:5),



                Row(

                  mainAxisAlignment:
                  MainAxisAlignment.center,

                  children: [


                    const Icon(

                      Icons.grid_on,

                      size:18,

                    ),


                    const SizedBox(width:5),


                    Text(

                      '${puzzle.pieces} قطعة',

                      style: const TextStyle(

                        fontSize:16,

                      ),

                    ),


                  ],

                ),


              ],

            ),

          ),

        ],

      ),

    );

  }

}
