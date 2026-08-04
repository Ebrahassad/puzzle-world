import 'package:flutter/material.dart';
import '../managers/reward_manager.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with SingleTickerProviderStateMixin {
  int stars = 0;
  int coins = 0;
  int achievements = 0;

  bool loading = true;

  late AnimationController starController;
  late Animation<double> starAnimation;

  @override
  void initState() {
    super.initState();
    loadWallet();

    starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(
        reverse: true,
      );

    starAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(
      CurvedAnimation(
        parent: starController,
        curve: Curves.easeInOut,
      ),
    );
  }

  // تحميل بيانات المحفظة من خلال RewardManager المركزي
  Future<void> loadWallet() async {
    final reward = await RewardManager.getReward();
    
    // ملاحظة: إذا كان لديك متغير للإنجازات في مكان آخر يمكنك جلبه بالطريقة المعتادة، وهنا نجلب النجوم والعملات من RewardManager
    if (!mounted) return;
    setState(() {
      stars = reward.stars;
      coins = reward.coins;
      // achievements = ... (إذا كان لديك مدير خاص للإنجازات يمكنك ربطه هنا)
      loading = false;
    });
  }

  // منح المكافأة وتحديث النظام المركزي مباشرة
  Future<void> rewardFromAd() async {
    // استخدام مكافأة الإعلان المتاحة في RewardManager لضمان التحديث الشامل
    await RewardManager.rewardedAdBonus();

    // إعادة تحميل البيانات لتحديث الواجهة فوراً
    await loadWallet();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "🎁 حصلت على +100 رصيد و +1 نجمة",
        ),
      ),
    );
  }

  @override
  void dispose() {
    starController.dispose();
    super.dispose();
  }

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
      appBar: AppBar(
        title: const Text(
          "👜 المحفظة",
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // النجمة الذهبية
            ScaleTransition(
              scale: starAnimation,
              child: Image.asset(
                "assets/images/rewards/Star_gold.png",
                height: 100,
                errorBuilder: (_, __, ___) {
                  return const Icon(
                    Icons.star,
                    size: 90,
                    color: Colors.amber,
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            walletCard(
              "⭐ النجوم",
              stars,
              Colors.amber,
            ),
            walletCard(
              "🪙 الرصيد",
              coins,
              Colors.orange,
            ),
            walletCard(
              "🏆 الإنجازات",
              achievements,
              Colors.blue,
            ),
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(.15),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                children: [
                  const Text(
                    "🎁 صندوق المكافأة الذهبية",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "شاهد إعلان واحصل على مكافأة",
                    style: TextStyle(
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: rewardFromAd,
                      icon: const Icon(
                        Icons.play_circle,
                      ),
                      label: const Text(
                        "شاهد إعلان",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "+100 🪙 رصيد   +1 ⭐ نجمة",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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

  Widget walletCard(
    String title,
    int value,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 15,
      ),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(.15),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: color,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value.toString(),
            style: TextStyle(
              color: color,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
