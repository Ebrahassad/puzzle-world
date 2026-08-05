import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
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

  late AudioPlayer audioPlayer;
  late AnimationController chestController;
  late Animation<double> chestScaleAnimation;

  @override
  void initState() {
    super.initState();
    loadWallet();

    audioPlayer = AudioPlayer();

    chestController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    chestScaleAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
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

    try {
      await audioPlayer.play(AssetSource('audio/puzzle_reward.mp3'));
    } catch (_) {}

    await chestController.forward();
    setState(() {
      isChestOpen = true;
    });

    await RewardManager.rewardedAdBonus();
    await loadWallet();

    if (!mounted) return;

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
                    height: 60,
                    width: 60,
                    errorBuilder: (_, __, ___) => const Icon(Icons.star, color: Colors.amber, size: 60),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "تم منح المكافئة",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 22,
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
    audioPlayer.dispose();
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
              "assets/images/ui/open_wallet.png",
              width: 38,
              height: 38,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.wallet, color: Colors.amber, size: 38),
            ),
            const SizedBox(width: 10),
            const Text(
              "المحفظة",
              style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 20),
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
                                width: 34,
                                height: 34,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "صندوق المكافأة الملكي",
                                style: TextStyle(
                                  fontSize: 20,
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
                            style: TextStyle(fontSize: 14, color: Colors.white70),
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

                          const SizedBox(height: 10),

                          SizedBox(
                            width: double.infinity,
                            height: 46,
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
                              icon: const Icon(Icons.card_giftcard_rounded, color: Color(0xFF1A0B2E), size: 24),
                              label: Text(
                                isChestOpen ? "تم فتح الصندوق بنجاح!" : "افتح الصندوق الآن",
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    walletCard(
                      title: "رصيد العملات",
                      value: coins,
                      assetPath: "assets/images/rewards/puzzle_coin.png",
                    ),
                    walletCard(
                      title: "رصيد النجوم",
                      value: stars,
                      assetPath: "assets/images/rewards/Star_gold.png",
                    ),
                    walletCard(
                      title: "رصيد الجوهر",
                      value: gems,
                      assetPath: "assets/images/rewards/gem.png",
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  width: 50,
                  height: 50,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.star, color: Colors.amber, size: 50),
                )
              else if (iconData != null)
                Icon(iconData, size: 50, color: Colors.amber),
              const SizedBox(width: 15),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 19,
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
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
