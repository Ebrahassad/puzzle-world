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
  int gems = 0;
  int coins = 0;
  int achievements = 0;

  bool loading = true;
  bool isChestOpen = false;

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

    setState(() {
      isChestOpen = true;
    });

    await RewardManager.rewardedAdBonus();
    await loadWallet();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "🎉 مبروك! لقد فتحت الصندوق وحصلت على مكافأة رائعة",
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
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
            ScaleTransition(
              scale: starAnimation,
              child: Image.asset(
                "assets/images/rewards/Star_gold.png",
                height: 100,
                width: 100,
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

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(.15),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.amber.withOpacity(0.4),
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
                  const SizedBox(height: 10),
                  const Text(
                    "اضغط على الصندوق لفتحه والحصول على المكافأة",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 20),

                  GestureDetector(
                    onTap: openChest,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Image.asset(
                        isChestOpen
                            ? "assets/images/rewards/reward_chest_open.png"
                            : "assets/images/rewards/reward_chest_closed.png",
                        key: ValueKey<bool>(isChestOpen),
                        height: 110,
                        width: 110,
                        errorBuilder: (_, __, ___) {
                          return Icon(
                            isChestOpen ? Icons.lock_open : Icons.lock,
                            size: 80,
                            color: Colors.amber,
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: openChest,
                      icon: const Icon(
                        Icons.card_giftcard_rounded,
                      ),
                      label: Text(
                        isChestOpen ? "تم فتح الصندوق!" : "افتح الصندوق الآن",
                        style: const TextStyle(
                          fontSize: 18,
                        ),
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
      margin: const EdgeInsets.only(
        bottom: 15,
      ),
      padding: const EdgeInsets.all(16),
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
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
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
