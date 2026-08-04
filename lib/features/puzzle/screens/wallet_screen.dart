import 'package:flutter/material.dart';
import '../managers/reward_manager.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with TickerProviderStateMixin {
  int stars = 0;
  int gems = 0;
  int coins = 0;
  int achievements = 0;

  bool loading = true;
  bool isChestOpen = false;

  late AnimationController starController;
  late Animation<double> starAnimation;

  // أنيميشن عند النقر على الصندوق
  late AnimationController chestController;
  late Animation<double> chestScaleAnimation;

  @override
  void initState() {
    super.initState();
    loadWallet();

    starController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    starAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: starController, curve: Curves.easeInOut),
    );

    chestController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    chestScaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: chestController, curve: Curves.elasticOut),
    );
  }

  Future<void> loadWallet() async {
    final reward = await RewardManager.getReward();
    if (!mounted) return;
    setState(() {
      stars = reward.stars;
      gems = reward.gems;
      coins = reward.coins;
      loading = false;
    });
  }

  Future<void> openChest() async {
    if (isChestOpen) return;

    // تشغيل أنيميشن النقر
    await chestController.forward();
    
    setState(() {
      isChestOpen = true;
    });

    // منح المكافأة عبر الـ Manager وتحديث البيانات
    await RewardManager.rewardedAdBonus();
    await loadWallet();

    if (!mounted) return;
    
    // إظهار رسالة نجاح منح المكافأة
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.card_giftcard, color: Colors.amber),
            SizedBox(width: 10),
            Text("🎉 مبروك! لقد فتحت الصندوق وحصلت على مكافأة رائعة"),
          ],
        ),
        backgroundColor: Colors.grey[900],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        duration: const Duration(seconds: 3),
      ),
    );

    await chestController.reverse();

    // إعادة إغلاق الصندوق بعد فترة (اختياري)
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          isChestOpen = false;
        });
      }
    });
  }

  @override
  void dispose() {
    starController.dispose();
    chestController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("👜 المحفظة"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // النجمة الذهبية المتحركة
            ScaleTransition(
              scale: starAnimation,
              child: Image.asset(
                "assets/images/rewards/Star_gold.png",
                height: 90,
                width: 90,
                errorBuilder: (_, __, ___) => const Icon(Icons.star, size: 80, color: Colors.amber),
              ),
            ),
            const SizedBox(height: 20),

            // البطاقات
            walletCard(
              title: "النجوم",
              value: stars,
              color: Colors.amber,
              assetPath: "assets/images/rewards/Star_gold.png",
            ),
            walletCard(
              title: "الجواهر",
              value: gems,
              color: Colors.purple,
              assetPath: "assets/images/rewards/gem.png",
            ),
            walletCard(
              title: "الرصيد",
              value: coins,
              color: Colors.orange,
              assetPath: "assets/images/ui/coin.png",
            ),
            walletCard(
              title: "الإنجازات",
              value: achievements,
              color: Colors.blue,
              iconData: Icons.emoji_events_rounded,
            ),

            const SizedBox(height: 25),

            // صندوق المكافآت التفاعلي
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.12),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.amber.withOpacity(0.5),
                  width: 1.5,
                ),
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
                  const SizedBox(height: 8),
                  const Text(
                    "اضغط على الصندوق لفتحه والحصول على مكافأتك",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 20),

                  // الصندوق مع الأنيميشن والصور المخصصة
                  GestureDetector(
                    onTap: openChest,
                    child: ScaleTransition(
                      scale: chestScaleAnimation,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Image.asset(
                          isChestOpen
                              ? "assets/images/rewards/reward_chest_open.png"
                              : "assets/images/rewards/reward_chest_closed.png",
                          key: ValueKey<bool>(isChestOpen),
                          height: 130,
                          width: 130,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) {
                            return Icon(
                              isChestOpen ? Icons.lock_open : Icons.lock,
                              size: 90,
                              color: Colors.amber,
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: openChest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[700],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      icon: const Icon(Icons.card_giftcard_rounded),
                      label: Text(
                        isChestOpen ? "تم فتح الصندوق بنجاح!" : "افتح الصندوق الآن",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
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

  Widget walletCard({
    required String title,
    required int value,
    required Color color,
    String? assetPath,
    IconData? iconData,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(.15),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (assetPath != null)
                Image.asset(
                  assetPath,
                  width: 32,
                  height: 32,
                  errorBuilder: (_, __, ___) => Icon(Icons.star, color: color),
                )
              else if (iconData != null)
                Icon(iconData, size: 32, color: color),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
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
