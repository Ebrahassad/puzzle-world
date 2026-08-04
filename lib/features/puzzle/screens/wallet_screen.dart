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

    // إظهار الرسالة في وسط الشاشة تماماً مع صورة النجمة المحددة
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(const Duration(seconds: 3), () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        });
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2A1B3D),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.6),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    "assets/images/rewards/Star_gold.png",
                    height: 50,
                    width: 50,
                    errorBuilder: (_, __, ___) => const Icon(Icons.star, color: Colors.amber, size: 50),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "تم منح المكافئة",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
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
      backgroundColor: const Color(0xFF1A0B2E),
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              "assets/images/rewards/reward_chest_closed.png",
              width: 28,
              height: 28,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.wallet, color: Colors.amber),
            ),
            const SizedBox(width: 8),
            const Text(
              "المحفظة الملكية",
              style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF2A1B3D),
        elevation: 4,
        iconTheme: const IconThemeData(color: Colors.amber),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ScaleTransition(
                      scale: starAnimation,
                      child: Image.asset(
                        "assets/images/rewards/Star_gold.png",
                        height: 70,
                        width: 70,
                        errorBuilder: (_, __, ___) => const Icon(Icons.star, size: 70, color: Colors.amber),
                      ),
                    ),

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
                      assetPath: "assets/images/rewards/puzzle_coin.png",
                    ),

                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF35224E), Color(0xFF211333)],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.amber.withOpacity(0.6),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/images/rewards/reward_chest_closed.png",
                                width: 26,
                                height: 26,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "صندوق المكافأة الملكي",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "اضغط على الصندوق لفتحه والحصول على مكافأتك",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: Colors.white70),
                          ),
                          const SizedBox(height: 10),

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
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) {
                                    return Icon(
                                      isChestOpen ? Icons.lock_open : Icons.lock,
                                      size: 70,
                                      color: Colors.amber,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          SizedBox(
                            width: double.infinity,
                            height: 42,
                            child: ElevatedButton.icon(
                              onPressed: openChest,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber[700],
                                foregroundColor: const Color(0xFF1A0B2E),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                              ),
                              icon: const Icon(Icons.card_giftcard_rounded, color: Color(0xFF1A0B2E), size: 20),
                              label: Text(
                                isChestOpen ? "تم فتح الصندوق بنجاح!" : "افتح الصندوق الآن",
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF311E4B), Color(0xFF221335)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.amber.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 2),
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
                  width: 42,
                  height: 42,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.star, color: Colors.amber, size: 42),
                )
              else if (iconData != null)
                Icon(iconData, size: 42, color: Colors.amber),
              const SizedBox(width: 15),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
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
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
