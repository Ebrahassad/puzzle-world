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

    await chestController.forward();
    setState(() {
      isChestOpen = true;
    });

    await RewardManager.rewardedAdBonus();
    await loadWallet();

    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.card_giftcard, color: Colors.amber),
            SizedBox(width: 10),
            Text("🎉 مبروك! لقد فتحت الصندوق وحصلت على مكافأة رائعة"),
          ],
        ),
        backgroundColor: const Color(0xFF2A1B3D),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(color: Colors.amber, width: 1),
        ),
        duration: const Duration(seconds: 3),
      ),
    );

    await chestController.reverse();

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
        backgroundColor: Color(0xFF1A0B2E),
        body: Center(child: CircularProgressIndicator(color: Colors.amber)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A0B2E), // خلفية داكنة متناسقة مع الصندوق
      appBar: AppBar(
        title: const Text(
          "👜 المحفظة الملكية",
          style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2A1B3D),
        elevation: 4,
        iconTheme: const IconThemeData(color: Colors.amber),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
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

            // البطاقات بتصميم مستوحى من إطارات الصندوق الذهبية والبنفسجية
            walletCard(
              title: "النجوم",
              value: stars,
              assetPath: "assets/images/rewards/Star_gold.png",
            ),
            walletCard(
              title: "الجواهر",
              value: gems,
              assetPath: "assets/images/rewards/gem.png",
            ),
            walletCard(
              title: "الرصيد",
              value: coins,
              assetPath: "assets/images/ui/coin.png",
            ),
            walletCard(
              title: "الإنجازات",
              value: achievements,
              iconData: Icons.emoji_events_rounded,
            ),

            const SizedBox(height: 25),

            // صندوق المكافآت التفاعلي بتصميم منسجم تماماً
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF35224E), Color(0xFF211333)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.amber.withOpacity(0.6),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "🎁 صندوق المكافأة الملكي",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "اضغط على الصندوق لفتحه والحصول على مكافأتك",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 20),

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
                        foregroundColor: const Color(0xFF1A0B2E),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 5,
                      ),
                      icon: const Icon(Icons.card_giftcard_rounded, color: Color(0xFF1A0B2E)),
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
    String? assetPath,
    IconData? iconData,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        // تدرج بنفسجي داكن مشابه للمحفظة/الصندوق مع إطار ذهبي نحاسي
        gradient: const LinearGradient(
          colors: [Color(0xFF311E4B), Color(0xFF221335)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.amber.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (assetPath != null)
                Image.asset(
                  assetPath,
                  width: 34,
                  height: 34,
                  errorBuilder: (_, __, ___) => const Icon(Icons.star, color: Colors.amber),
                )
              else if (iconData != null)
                Icon(iconData, size: 34, color: Colors.amber),
              const SizedBox(width: 15),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Text(
            value.toString(),
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
