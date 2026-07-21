import 'package:flutter/material.dart';
import 'categories_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Container(

        decoration: const BoxDecoration(

          gradient: LinearGradient(

            colors: [
              Color(0xff74EBD5),
              Color(0xffACB6E5),
            ],

            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,

          ),

        ),


        child: SafeArea(

          child: Center(

            child: Column(

              mainAxisAlignment: MainAxisAlignment.center,

              children: [


                Container(

                  width: 170,
                  height: 170,

                  decoration: BoxDecoration(

                    color: Colors.white,

                    shape: BoxShape.circle,

                    boxShadow: [

                      BoxShadow(

                        color: Colors.black.withOpacity(0.2),

                        blurRadius: 20,

                        offset: const Offset(0,10),

                      )

                    ],

                  ),


                  child: const Icon(

                    Icons.extension,

                    size: 90,

                    color: Colors.blue,

                  ),

                ),



                const SizedBox(height:30),



                const Text(

                  'Puzzle World',

                  style: TextStyle(

                    fontSize:42,

                    fontWeight: FontWeight.bold,

                    color: Colors.white,

                    shadows: [

                      Shadow(

                        blurRadius:10,

                        offset: Offset(2,3),

                      )

                    ],

                  ),

                ),



                const SizedBox(height:15),



                const Text(

                  'رتّب القطع وأكمل الصورة 🧩',

                  style: TextStyle(

                    fontSize:20,

                    color: Colors.white,

                  ),

                ),



                const SizedBox(height:50),



                ElevatedButton(

                  onPressed: (){

                    Navigator.push(

                      context,

                      MaterialPageRoute(

                        builder:(context)=>

                        const CategoriesScreen(),

                      ),

                    );

                  },


                  style: ElevatedButton.styleFrom(

                    padding: const EdgeInsets.symmetric(

                      horizontal:60,

                      vertical:18,

                    ),

                    elevation:10,

                    shape: RoundedRectangleBorder(

                      borderRadius:

                      BorderRadius.circular(30),

                    ),

                  ),


                  child: const Text(

                    'ابدأ اللعب',

                    style: TextStyle(

                      fontSize:24,

                      fontWeight:FontWeight.bold,

                    ),

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
