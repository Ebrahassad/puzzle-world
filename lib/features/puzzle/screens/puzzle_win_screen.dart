import 'package:flutter/material.dart';

import '../models/game_result_model.dart';
import '../models/reward_result_model.dart';

import '../managers/puzzle_progress_manager.dart';
import '../managers/reward_manager.dart';

import '../services/puzzle_audio_service.dart';
import '../services/puzzle_navigation_service.dart';
import '../services/puzzle_statistics_service.dart';
import '../services/puzzle_cloud_service.dart';
import '../services/puzzle_event_service.dart';
import '../services/reward_ad_service.dart';

class PuzzleWinScreen extends StatefulWidget {
  final GameResultModel result;

  final int difficulty;

  final String? worldId;

  final int? level;

  final VoidCallback? onNextLevel;

  final VoidCallback? onBackToWorld;

  final VoidCallback? onBackToHome;

  const PuzzleWinScreen({
    super.key,
    required this.result,
    this.difficulty = 1,
    this.worldId,
    this.level,
    this.onNextLevel,
    this.onBackToWorld,
    this.onBackToHome,
  });

  @override
  State<PuzzleWinScreen> createState() =>
      _PuzzleWinScreenState();
}

class _PuzzleWinScreenState
    extends State<PuzzleWinScreen>
    with SingleTickerProviderStateMixin {

  RewardResultModel? reward;

  bool loading = true;

  bool adUsed = false;

  late AnimationController controller;

  late Animation<double> scaleAnimation;

  String? get levelId {
    if (widget.worldId == null ||
        widget.level == null) {
      return null;
    }

    return "${widget.worldId}_level_${widget.level}";
  }

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 900,
      ),
    )..repeat(reverse: true);

    scaleAnimation = Tween<double>(
      begin: 1,
      end: 1.12,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ),
    );

    _initialize();
  }

  Future<void> _initialize() async {
    await PuzzleAudioService.playWinSound();

    await _completeLevel();

    if (!mounted) return;

    setState(() {
      loading = false;
    });
  }


  //==================================================
  // 🏆 إنهاء المرحلة وحفظ كل البيانات
  //==================================================

  Future<void> _completeLevel() async {
    RewardResultModel result =
        const RewardResultModel(
          coins: 0,
          gems: 0,
        );

    final id = levelId;

    if (id != null) {

      final completed =
          await PuzzleProgressManager.isCompleted(id);


      if (!completed) {

        // حفظ المرحلة كمكتملة
        await PuzzleProgressManager.completeLevel(id);


        // فتح المرحلة التالية
        await PuzzleProgressManager
            .unlockNextLevel(id);


        // إضافة النجوم
        await PuzzleProgressManager
            .addStars(
          widget.result.stars,
        );


        // تسجيل الإحصائيات
        await PuzzleStatisticsService
            .addCompletedPuzzle(
          stars: widget.result.stars,
          moves: widget.result.moves,
          seconds: widget.result.seconds,
        );


        // إرسال حدث إكمال المرحلة
        await PuzzleEventService
            .onPuzzleCompleted(
          levelId: id,
          stars: widget.result.stars,
        );


        // مزامنة التقدم
        await PuzzleCloudService.sync();

      }



      // التأكد من عدم تكرار المكافأة

      final claimed =
          await PuzzleProgressManager
              .isRewardClaimed(id);



      if (!claimed) {

        result =
            await RewardManager.completePuzzle(
          difficulty: widget.difficulty,
        );


        await PuzzleProgressManager
            .markRewardClaimed(id);

      }


    } else {

      // في حال لم تكن مرحلة محددة

      result =
          await RewardManager.completePuzzle(
        difficulty: widget.difficulty,
      );

    }



    if (!mounted) return;



    setState(() {

      reward = result;

    });

  }







  //==================================================
  // 🎁 مضاعفة المكافأة عن طريق الإعلان
  //==================================================

  Future<void> doubleReward() async {

    if (adUsed || reward == null) {
      return;
    }


    final watched =
        await RewardAdService.showRewardAd();


    if (!watched) {
      return;
    }


    final coins =
        reward!.coins;


    final gems =
        reward!.gems;



    await RewardManager.addCoins(
      coins,
    );


    if (gems > 0) {

      await RewardManager.addGems(
        gems,
      );

    }


    if (!mounted) return;


    setState(() {

      reward =
          reward!.multiply(2);


      adUsed = true;

    });

  }

  //==================================================
  // 🎨 واجهة الشاشة
  //==================================================

  @override
  Widget build(BuildContext context) {

    if (loading) {

      return const Scaffold(

        body: Center(

          child: CircularProgressIndicator(),

        ),

      );

    }


    return Scaffold(

      backgroundColor:
          Colors.lightBlue.shade50,


      body: SafeArea(

        child: Center(

          child: SingleChildScrollView(

            padding:
                const EdgeInsets.all(24),


            child: Column(

              mainAxisAlignment:
                  MainAxisAlignment.center,


              children: [


                // نجمة متحركة

                ScaleTransition(

                  scale: scaleAnimation,

                  child: const Icon(

                    Icons.star,

                    size: 90,

                    color: Colors.amber,

                  ),

                ),



                const SizedBox(height:20),



                const Text(

                  "🎉 أحسنت!",

                  style: TextStyle(

                    fontSize:34,

                    fontWeight:FontWeight.bold,

                  ),

                ),



                const SizedBox(height:10),



                Text(

                  "أكملت المرحلة بنجاح",

                  style: TextStyle(

                    fontSize:20,

                    color:Colors.grey.shade700,

                  ),

                ),



                const SizedBox(height:30),




                // بطاقة المكافآت

                Container(

                  padding:
                      const EdgeInsets.all(20),


                  decoration:
                      BoxDecoration(

                    color:Colors.white,

                    borderRadius:
                        BorderRadius.circular(25),


                    boxShadow:[

                      BoxShadow(

                        color:
                            Colors.black.withOpacity(.1),

                        blurRadius:12,

                      ),

                    ],

                  ),



                  child: Column(

                    children:[



                      Text(

                        "⭐ ${widget.result.stars}",

                        style:
                            const TextStyle(

                          fontSize:35,

                          color:Colors.amber,

                          fontWeight:
                              FontWeight.bold,

                        ),

                      ),



                      const SizedBox(height:15),



                      if(reward != null)

                        Row(

                          mainAxisAlignment:
                              MainAxisAlignment.center,

                          children:[


                            _rewardItem(

                              "🪙",

                              reward!.coins,

                            ),



                            const SizedBox(width:25),



                            _rewardItem(

                              "💎",

                              reward!.gems,

                            ),


                          ],

                        ),



                    ],

                  ),

                ),



                const SizedBox(height:25),




                // زر مضاعفة المكافأة

                if(!adUsed && reward != null)

                  ElevatedButton.icon(

                    onPressed:
                        doubleReward,


                    icon:
                        const Icon(
                          Icons.ondemand_video,
                        ),


                    label:
                        const Text(
                          "ضاعف المكافأة",
                        ),



                    style:
                        ElevatedButton.styleFrom(

                      backgroundColor:
                          Colors.orange,

                      foregroundColor:
                          Colors.white,


                      padding:
                          const EdgeInsets.symmetric(

                        horizontal:30,

                        vertical:15,

                      ),


                      shape:
                          RoundedRectangleBorder(

                        borderRadius:
                            BorderRadius.circular(30),

                      ),

                    ),

                  ),



                const SizedBox(height:25),




                // الأزرار

                _buildButton(

                  title:"➡️ المرحلة التالية",

                  color:Colors.green,

                  onTap:_nextLevel,

                ),



                const SizedBox(height:12),



                _buildButton(

                  title:"🧩 العودة للعالم",

                  color:Colors.blue,

                  onTap:_backWorld,

                ),



                const SizedBox(height:12),



                _buildButton(

                  title:"🏠 الرئيسية",

                  color:Colors.purple,

                  onTap:_home,

                ),



              ],

            ),

          ),

        ),

      ),

    );

  }



  Widget _rewardItem(
      String icon,
      int value,
      ) {

    return Column(

      children:[

        Text(

          icon,

          style:
              const TextStyle(

            fontSize:35,

          ),

        ),


        Text(

          "$value",

          style:
              const TextStyle(

            fontSize:22,

            fontWeight:
                FontWeight.bold,

          ),

        ),

      ],

    );

  }

  //==================================================
  // ➡️ الانتقال للمرحلة التالية
  //==================================================

  Future<void> _nextLevel() async {

    if (widget.onNextLevel != null) {

      widget.onNextLevel!();

      return;

    }


    if (widget.worldId != null &&
        widget.level != null) {


      await PuzzleNavigationService.openNextLevel(

        context,

        worldId: widget.worldId!,

        currentLevel: widget.level!,

      );


    }

  }







  //==================================================
  // 🧩 العودة للعالم
  //==================================================

  Future<void> _backToWorld() async {


    if (widget.onBackToWorld != null) {

      widget.onBackToWorld!();

      return;

    }



    Navigator.pop(context);


  }







  //==================================================
  // 🏠 العودة للرئيسية
  //==================================================

  Future<void> _backHome() async {


    if (widget.onBackToHome != null) {

      widget.onBackToHome!();

      return;

    }



    Navigator.popUntil(

      context,

      (route) => route.isFirst,

    );


  }







  //==================================================
  // زر موحد
  //==================================================

  Widget _buildButton({

    required String title,

    required Color color,

    required VoidCallback onTap,

  }) {


    return SizedBox(

      width: double.infinity,


      child: ElevatedButton(

        onPressed: onTap,


        style: ElevatedButton.styleFrom(

          backgroundColor: color,

          foregroundColor: Colors.white,


          padding:
              const EdgeInsets.symmetric(

            vertical:16,

          ),


          shape:
              RoundedRectangleBorder(

            borderRadius:
                BorderRadius.circular(30),

          ),


          elevation:6,

        ),



        child: Text(

          title,

          style:
              const TextStyle(

            fontSize:18,

            fontWeight:
                FontWeight.bold,

          ),

        ),

      ),

    );


  }







  //==================================================
  // تنظيف الأنيميشن
  //==================================================

  @override
  void dispose() {

    controller.dispose();

    super.dispose();

  }

}