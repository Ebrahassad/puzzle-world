import 'package:flutter/material.dart';
import '../data/puzzle_data.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(

        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xff8ED6FF),
              Color(0xffB8F2E6),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(

          child: Column(

            children: [

              const SizedBox(height: 20),

              const Text(
                '🧩 اختر عالم البازل',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 8,
                      offset: Offset(2,2),
                    )
                  ],
                ),
              ),


              const SizedBox(height: 25),


              Expanded(

                child: GridView.builder(

                  padding: const EdgeInsets.all(18),

                  itemCount: PuzzleData.categories.length,


                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(

                    crossAxisCount: 2,

                    crossAxisSpacing: 18,

                    mainAxisSpacing: 18,

                  ),


                  itemBuilder: (context,index){


                    final category =
                    PuzzleData.categories[index];


                    return Container(

                      decoration: BoxDecoration(

                        color: Colors.white,

                        borderRadius:
                        BorderRadius.circular(25),


                        boxShadow: const [

                          BoxShadow(

                            color: Colors.black26,

                            blurRadius: 10,

                            offset: Offset(0,8),

                          )

                        ],

                      ),


                      child: Column(

                        mainAxisAlignment:
                        MainAxisAlignment.center,


                        children: [


                          Container(

                            height: 90,

                            width: 90,

                            decoration: BoxDecoration(

                              shape: BoxShape.circle,

                              color:
                              Colors.blue.shade50,

                            ),


                            child: const Icon(

                              Icons.extension,

                              size: 55,

                              color: Colors.blue,

                            ),

                          ),



                          const SizedBox(height:15),



                          Text(

                            category.name,

                            style: const TextStyle(

                              fontSize:22,

                              fontWeight:
                              FontWeight.bold,

                            ),

                          ),


                        ],

                      ),

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
