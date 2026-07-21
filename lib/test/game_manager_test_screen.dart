import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/managers/game_manager.dart';


class GameManagerTestScreen extends ConsumerWidget {

  const GameManagerTestScreen({super.key});


  @override
  Widget build(BuildContext context, WidgetRef ref) {


    final player = ref.watch(gameManagerProvider);


    return Scaffold(

      appBar:AppBar(

        title:const Text('اختبار المحفظة'),

      ),


      body:Center(

        child:Column(

          mainAxisAlignment:MainAxisAlignment.center,


          children:[


            Text(
              '🪙 ${player.coins}',
              style:const TextStyle(fontSize:30),
            ),


            Text(
              '💎 ${player.gems}',
              style:const TextStyle(fontSize:30),
            ),


            Text(
              '💡 ${player.hints}',
              style:const TextStyle(fontSize:30),
            ),



            ElevatedButton(

              onPressed:(){

                ref
                .read(gameManagerProvider.notifier)
                .addCoins(100);

              },

              child:const Text(
                '+100 عملة',
              ),

            ),



          ],

        ),

      ),

    );

  }

}
