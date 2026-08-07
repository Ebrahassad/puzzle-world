import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'private_island_screen.dart';
import '../data/puzzle_data.dart';
import '../models/puzzle_model.dart';
import '../widgets/wallet_icon_widget.dart';
import 'island_screen.dart';
import '../managers/puzzle_progress_manager.dart';
import '../managers/ads_manager.dart';
import '../managers/reward_manager.dart';
// import 'puzzle_game_screen.dart'; // <--- قم بإلغاء التعليق واستيراد شاشة اللعب الخاصة بك إذا لزم الأمر

class _RelativeRect {
final String id;
final double left;
final double top;
final double width;
final double height;

const _RelativeRect({
required this.id,
required this.left,
required this.top,
required this.width,
required this.height,
});
}

class _RelativeCloud {
final String image;
final double top;
final double size;
final double opacity;
final Duration duration;

const _RelativeCloud({
required this.image,
required this.top,
required this.size,
required this.opacity,
required this.duration,
});
}

class WorldMapScreen extends StatefulWidget {
const WorldMapScreen({
super.key,
});

@override
State<WorldMapScreen> createState() =>
_WorldMapScreenState();
}

class _WorldMapScreenState
extends State<WorldMapScreen>
with TickerProviderStateMixin {

static const String mapImage =
"assets/images/world/world_map.jpg";

static const double worldWidth = 896;
static const double worldHeight = 1350;

static const int privateIslandCoinCost = 500;
static const int privateIslandGemCost = 100;

static const String privateIslandKey =
"private_island_unlocked";

late final List<PuzzleModel> islands;

late final AnimationController worldController;
late final Animation<double> worldScale;
late final Animation<double> worldTranslateY;

late final List<AnimationController> cloudControllers;
late final AudioPlayer audioPlayer;

bool openingAd = false;
bool spaceUnlocked = false;
bool privateIslandUnlocked = false;
bool unlockingPrivateIsland = false;

// تم تعديل إحداثيات الجزر بدقة:
// 1. المعالم والسيارات مرفوعة قليلاً للأعلى.
// 2. الطبيعة مرفوعة للأعلى لتترك مسافة فاصلة وآمنة تماماً بينها وبين جزيرة الحيوانات.
static final List<_RelativeRect> _islandRects = [

// جزيرة الفضاء  
_RelativeRect(  
  id: "space",  
  left: 210 / worldWidth,  
  top: 9 / worldHeight,  
  width: 480 / worldWidth,  
  height: 540 / worldHeight,  
),  

// المعالم (مرفوعة قليلاً)  
_RelativeRect(  
  id: "landmarks",  
  left: 100 / worldWidth,  
  top: 408 / worldHeight,  
  width: 335 / worldWidth,  
  height: 365 / worldHeight,  
),  

// السيارات (مرفوعة قليلاً)  
_RelativeRect(  
  id: "cars",  
  left: 460 / worldWidth,  
  top: 408 / worldHeight,  
  width: 335 / worldWidth,  
  height: 365 / worldHeight,  
),  

// الطبيعة (مرفوعة أكثر لتترك مسافة بينها وبين الحيوانات)  
_RelativeRect(  
  id: "nature",  
  left: 268 / worldWidth,  
  top: 600 / worldHeight,  
  width: 360 / worldWidth,  
  height: 380 / worldHeight,  
),  

// الحيوانات (في الأسفل مع وجود مسافة فاصلة بينها وبين الطبيعة)  
_RelativeRect(  
  id: "animals",  
  left: 268 / worldWidth,  
  top: 935 / worldHeight,  
  width: 350 / worldWidth,  
  height: 380 / worldHeight,  
),

];

static final List<_RelativeCloud> _clouds = [
_RelativeCloud(
image: "assets/images/background/cloud_01.png",
top: 80 / worldHeight,
size: 280 / worldWidth,
opacity: 0.22,
duration: const Duration(seconds: 55),
),
_RelativeCloud(
image: "assets/images/background/cloud_02.png",
top: 200 / worldHeight,
size: 220 / worldWidth,
opacity: 0.22,
duration: const Duration(seconds: 70),
),
_RelativeCloud(
image: "assets/images/background/cloud_03.png",
top: 40 / worldHeight,
size: 170 / worldWidth,
opacity: 0.22,
duration: const Duration(seconds: 90),
),
_RelativeCloud(
image: "assets/images/background/cloud_04.png",
top: 300 / worldHeight,
size: 240 / worldWidth,
opacity: 0.22,
duration: const Duration(seconds: 65),
),
];

@override
void initState() {
super.initState();

islands = PuzzleData.puzzles;  
audioPlayer = AudioPlayer();  

WidgetsBinding.instance.addPostFrameCallback((_) {  
  AdsManager().initAds();  
});  

loadIslandState();  
loadPrivateIslandState();  

worldController = AnimationController(  
  vsync: this,  
  duration: const Duration(seconds: 22),  
)..forward(from: 0.0);  
  
worldController.repeat(reverse: true);  

worldScale = Tween<double>(  
  begin: 1.00,  
  end: 1.035,  
).animate(  
  CurvedAnimation(  
    parent: worldController,  
    curve: Curves.easeInOut,  
  ),  
);  

worldTranslateY = Tween<double>(  
  begin: -10,  
  end: 10,  
).animate(  
  CurvedAnimation(  
    parent: worldController,  
    curve: Curves.easeInOut,  
  ),  
);  

cloudControllers = _clouds  
    .map(  
      (cloud) => AnimationController(  
        vsync: this,  
        duration: cloud.duration,  
      )..repeat(),  
    )  
    .toList();

}

Future<void> loadIslandState() async {
final unlocked =
await PuzzleProgressManager.isIslandUnlocked("space");

if(!mounted) return;  

setState(() {  
  spaceUnlocked = unlocked;  
});

}

Future<void> loadPrivateIslandState() async {

final prefs = await SharedPreferences.getInstance();  

final unlocked =  
    prefs.getBool(privateIslandKey) ?? false;  

if(!mounted) return;  

setState(() {  
  privateIslandUnlocked = unlocked;  
});

}

Future<void> unlockPrivateIsland() async {

final prefs = await SharedPreferences.getInstance();  

await prefs.setBool(  
  privateIslandKey,  
  true,  
);  

if(!mounted) return;  

setState(() {  
  privateIslandUnlocked = true;  
  unlockingPrivateIsland = false;  
});  

ScaffoldMessenger.of(context)  
    .showSnackBar(  
  const SnackBar(  
    content: Text("🏝️ تم فتح جزيرتك الخاصة!"),  
  ),  
);  

await Future.delayed(  
  const Duration(milliseconds: 600),  
);  

if (!mounted) return;  

Navigator.push(  
  context,  
  MaterialPageRoute(  
    builder: (_) => const PrivateIslandScreen(),  
  ),  
);

}

@override
void dispose() {
worldController.dispose();
audioPlayer.dispose();

for (final controller in cloudControllers) {  
  controller.dispose();  
}  

super.dispose();

}

PuzzleModel? getIsland(String id) {
for (final item in islands) {
if (item.id == id) {
return item;
}
}
return null;
}

Future<void> playClickSound() async {
try {
await audioPlayer.play(AssetSource('audio/puzzle_click.mp3'));
} catch (_) {}
}

@override
Widget build(BuildContext context) {
final bottomPadding = MediaQuery.of(context).padding.bottom;

return Scaffold(  
  backgroundColor: const Color(0xff08182b),  
  body: LayoutBuilder(  
    builder: (context, constraints) {  
      final double screenWidth = constraints.maxWidth;  
      final double screenHeight = constraints.maxHeight;  

      if (screenWidth <= 0 || screenHeight <= 0) {  
        return const SizedBox.shrink();  
      }  

      final double scale = math.max(  
        screenWidth / worldWidth,  
        screenHeight / worldHeight,  
      );  

      final double scaledWidth = worldWidth * scale;  
      final double scaledHeight = worldHeight * scale;  

      final double dx = (screenWidth - scaledWidth) / 2;  
      final double dy = (screenHeight - scaledHeight) / 2;  

      return ClipRect(  
        child: Stack(  
          children: [  
            Positioned(  
              left: dx,  
              top: dy,  
              child: Transform.scale(  
                scale: scale,  
                alignment: Alignment.topLeft,  
                child: SizedBox(  
                  width: worldWidth,  
                  height: worldHeight,  
                  child: AnimatedBuilder(  
                    animation: worldController,  
                    builder: (context, child) {  
                      return Transform.translate(  
                        offset: Offset(0, worldTranslateY.value),  
                        child: Transform.scale(  
                          scale: worldScale.value,  
                          alignment: Alignment.center,  
                          child: child,  
                        ),  
                      );  
                    },  
                    child: SizedBox(  
                      width: worldWidth,  
                      height: worldHeight,  
                      child: Stack(  
                        clipBehavior: Clip.none,  
                        children: [  
                          Positioned.fill(  
                            child: Image.asset(  
                              mapImage,  
                              fit: BoxFit.cover,  
                              errorBuilder: (context, error, stack) =>  
                                  const SizedBox.shrink(),  
                            ),  
                          ),  

                          for (int i = 0; i < _clouds.length; i++)  
                            cloudWidget(  
                              cloud: _clouds[i],  
                              controller: cloudControllers[i],  
                            ),  

                          for (final rect in _islandRects)  
                            islandImage(  
                              rect: rect,  
                            ),  
                        ],  
                      ),  
                    ),  
                  ),  
                ),  
              ),  
            ),  
              
            // أيقونة المحفظة: أسفل يسار الشاشة مع وهج مشع وآمن لا يغطي الشاشة  
            Positioned(  
              bottom: bottomPadding + 20,  
              left: 20,  
              child: GestureDetector(  
                onTap: () async {  
                  await playClickSound();  
                },  
                child: Container(  
                  decoration: BoxDecoration(  
                    shape: BoxShape.circle,  
                    boxShadow: [  
                      BoxShadow(  
                        color: Colors.amber.withOpacity(0.85),  
                        blurRadius: 16,  
                        spreadRadius: 4,  
                      ),  
                    ],  
                  ),  
                  child: Transform.scale(  
                    scale: 1.15,  
                    child: const WalletIconWidget(),  
                  ),  
                ),  
              ),  
            ),  

            // أيقونة الجزيرة الخاصة: تفتح استوديو الصور  
            Positioned(  
              bottom: bottomPadding + 20,  
              right: 20,  
              child: GestureDetector(  
                onTap: () async {  
                  await playClickSound();  

                  if (!context.mounted) return;  

                  if(privateIslandUnlocked){  

                    Navigator.push(  
                      context,  
                      MaterialPageRoute(  
                        builder: (_) => const PrivateIslandScreen(),  
                      ),  
                    );  

                    return;  
                  }  

                  final coins = await RewardManager.getCoins();  
                  final gems = await RewardManager.getGems();  

                  showDialog(  
                    context: context,  
                    builder: (context) {  

                      return AlertDialog(  
                        title: const Text(  
                          "🏝️ الجزيرة الخاصة",  
                        ),  

                        content: const Text(  
                          "افتح جزيرتك الخاصة واختر المكافأة:\n\n"  
                          "🪙 500 عملة\n"  
                          "أو\n"  
                          "💎 100 جوهرة",  
                        ),  

                        actions: [  

                          TextButton(  
                            child: const Text("إلغاء"),  
                            onPressed: (){  
                              Navigator.pop(context);  
                            },  
                          ),  


                          ElevatedButton(  
                            child: const Text("🪙 500"),  
                            onPressed: unlockingPrivateIsland ? null : () async {  

                              if(coins >= privateIslandCoinCost && !unlockingPrivateIsland){  

                                setState(() {  
                                  unlockingPrivateIsland = true;  
                                });  

                                try {  

                                  await RewardManager.spendCoins(  
                                    privateIslandCoinCost,  
                                  );  

                                  if(!context.mounted) return;  

                                  Navigator.pop(context);  

                                  await unlockPrivateIsland();  

                                } catch(e){  

                                  setState(() {  
                                    unlockingPrivateIsland = false;  
                                  });  

                                }  

                              } else {  

                                ScaffoldMessenger.of(context)  
                                    .showSnackBar(  
                                  const SnackBar(  
                                    content: Text(  
                                      "لا تملك عملات كافية",  
                                    ),  
                                  ),  
                                );  

                              }  

                            },  
                          ),  


                          ElevatedButton(  
                            child: const Text("💎 100"),  
                            onPressed: unlockingPrivateIsland ? null : () async {  

                              if(gems >= privateIslandGemCost && !unlockingPrivateIsland){  

                                setState(() {  
                                  unlockingPrivateIsland = true;  
                                });  

                                try {  

                                  await RewardManager.spendGems(  
                                    privateIslandGemCost,  
                                  );  

                                  if(!context.mounted) return;  

                                  Navigator.pop(context);  

                                  await unlockPrivateIsland();  

                                } catch(e){  

                                  setState(() {  
                                    unlockingPrivateIsland = false;  
                                  });  

                                }  

                              } else {  

                                ScaffoldMessenger.of(context)  
                                    .showSnackBar(  
                                  const SnackBar(  
                                    content: Text(  
                                      "لا تملك جواهر كافية",  
                                    ),  
                                  ),  
                                );  

                              }  

                            },  
                          ),  

                        ],  
                      );  

                    },  
                  );  
                },  
                child: Container(  
                  decoration: BoxDecoration(  
                    shape: BoxShape.circle,  
                    boxShadow: [  
                      BoxShadow(  
                        color: Colors.amber.withOpacity(0.85),  
                        blurRadius: 16,  
                        spreadRadius: 4,  
                      ),  
                    ],  
                  ),  
                  child: Transform.scale(  
                    scale: 1.15,  
                    child: SizedBox(  
                      width: 55,  
                      height: 55,  
                      child: Image.asset(  
                        "assets/images/ui/add_pic.png",  
                        fit: BoxFit.contain,  
                        errorBuilder: (context, error, stack) =>  
                            const SizedBox.shrink(),  
                      ),  
                    ),  
                  ),  
                ),  
              ),  
            ),  
          ],  
        ),  
      );  
    },  
  ),  
);

}

Widget cloudWidget({
required _RelativeCloud cloud,
required AnimationController controller,
}) {
final double top = cloud.top * worldHeight;
final double size = cloud.size * worldWidth;

return AnimatedBuilder(  
  animation: controller,  
  builder: (context, child) {  
    return Positioned(  
      left: (worldWidth + 100) -  
          (controller.value * (worldWidth + 400)),  
      top: top,  
      child: Opacity(  
        opacity: cloud.opacity,  
        child: Transform.rotate(  
          angle: controller.value * 0.15,  
          child: child,  
        ),  
      ),  
    );  
  },  
  child: Image.asset(  
    cloud.image,  
    width: size,  
    errorBuilder: (context, error, stack) => const SizedBox.shrink(),  
  ),  
);

}

Widget islandImage({
required _RelativeRect rect,
}) {
final island = getIsland(rect.id);

if (island == null) {  
  return const SizedBox.shrink();  
}  

final double left = rect.left * worldWidth;  
final double top = rect.top * worldHeight;  
final double width = rect.width * worldWidth;  
final double height = rect.height * worldHeight;  

return Positioned(  
  left: left,  
  top: top,  
  width: width,  
  height: height,  
  child: GestureDetector(  
    onTap: () async {  
      await playClickSound();  
      openIsland(island);  
    },  
    behavior: HitTestBehavior.opaque,  
    child: Stack(  
      alignment: Alignment.center,  
      children: [  

        Image.asset(  
          island.image,  
          fit: BoxFit.contain,  
          errorBuilder: (context, error, stack) =>  
              const SizedBox.shrink(),  
        ),  


        if(island.id == "space" && !spaceUnlocked)  
          Positioned(  
            right: 20,  
            top: 20,  
            child: Image.asset(  
              "assets/images/ui/lock.png",  
              width: 70,  
              height: 70,  
              fit: BoxFit.contain,  
              errorBuilder: (context, error, stack) =>  
                  const SizedBox.shrink(),  
            ),  
          ),  

      ],  
    ),  
  ),  
);

}

Future<void> openIsland(PuzzleModel island) async {

final unlocked =  
    await PuzzleProgressManager.isIslandUnlocked(  
      island.id,  
    );  


if(unlocked){  

  Navigator.push(  
    context,  
    MaterialPageRoute(  
      builder: (_) => IslandScreen(  
        island: island,  
      ),  
    ),  
  );  

  return;  
}  


showDialog(  
  context: context,  
  builder: (context){  

    return AlertDialog(  
      title: const Text(  
        "🔒 الجزيرة مغلقة",  
      ),  

      content: FutureBuilder<List<dynamic>>(  
        future: Future.wait([  
          Future.value(  
            PuzzleProgressManager.getIslandRequiredAds(island.id),  
          ),  
          PuzzleProgressManager.getAdsBalance(),  
        ]),  
        builder: (context, snapshot) {  

          if (!snapshot.hasData) {  
            return const SizedBox(  
              height: 40,  
              child: Center(  
                child: CircularProgressIndicator(),  
              ),  
            );  
          }  

          final required = snapshot.data![0] as int;  
          final balance = snapshot.data![1] as int;  

          return Text(  
            "رصيدك: $balance مشاهدة\n"  
            "المطلوب: $required مشاهدة",  
          );  
        },  
      ),  


      actions: [  

        TextButton(  
          child: const Text(  
            "إلغاء",  
          ),  

          onPressed: (){  
            Navigator.pop(context);  
          },  
        ),  


        ElevatedButton(  
          child: const Text(  
            "📺 مشاهدة إعلان",  
          ),  

          onPressed: openingAd ? null : () async {  

            if (openingAd) return;  

            setState(() {  
              openingAd = true;  
            });  

            Navigator.pop(context);  


            if (!AdsManager().isInitialized) {  
              await AdsManager().initAds();  
            }  


            AdsManager().showRewardedAd(  

              onRewardEarned: () async {  

                await PuzzleProgressManager.addAdsBalance(1);  

                final balance =  
                    await PuzzleProgressManager.getAdsBalance();  

                final required =  
                    PuzzleProgressManager.getIslandRequiredAds(  
                      island.id,  
                    );  


                // إذا وصل الرصيد للحد المطلوب افتح الجزيرة  
                if(balance >= required){  

                  await PuzzleProgressManager.unlockIsland(  
                    island.id,  
                  );  

                  if(!mounted) return;  

                  await loadIslandState();  

                  if(!mounted) return;  

                  ScaffoldMessenger.of(context).showSnackBar(  
                    const SnackBar(  
                      content: Text(  
                        "🎉 تم فتح الجزيرة!",  
                      ),  
                    ),  
                  );  

                }  
                else {  

                  if(!mounted) return;  

                  ScaffoldMessenger.of(context).showSnackBar(  
                    SnackBar(  
                      content: Text(  
                        "تمت إضافة مشاهدة الإعلان\n"  
                        "الرصيد: $balance / $required",  
                      ),  
                    ),  
                  );  

                }  


                if(!mounted) return;  

                setState(() {  
                  openingAd = false;  
                });  

              },  


              onAdFailed: () {  

                if(!mounted) return;  


                setState(() {  
                  openingAd = false;  
                });  


                ScaffoldMessenger.of(context)  
                    .showSnackBar(  
                  const SnackBar(  
                    content: Text(  
                      "الإعلان غير متوفر حالياً",  
                    ),  
                  ),  
                );  

              },  

            );  

          },  
        ),  

      ],  
    );  

  },  
);

}
}