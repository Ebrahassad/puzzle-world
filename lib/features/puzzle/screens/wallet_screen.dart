import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../managers/reward_manager.dart';
import '../managers/puzzle_progress_manager.dart';
import '../managers/ads_manager.dart';
import '../models/reward_result_model.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with TickerProviderStateMixin {
  //==================================================
  // 💰 الأرصدة
  //==================================================

  int stars = 0;
  int gems = 0;
  int coins = 0;
  int adsBalance = 0;

  bool loading = true;
  bool isChestOpen = false;
  bool openingAd = false;

  bool buyingCoins = false;
  bool buyingStars = false;
  bool buyingGems = false;

  //==================================================
  // 💼 حركة المحفظة
  //==================================================

  bool isWalletOpeningAnim = false;

  late AudioPlayer audioPlayer;

  late AnimationController chestController;
  late Animation<double> chestScaleAnimation;

  late AnimationController walletAnimController;
  late Animation<Offset> walletPositionAnimation;
  late Animation<double> walletScaleAnimation;

  //==================================================
  // 🎨 ألوان الشاشة
  //==================================================

  static const Color backgroundColor =
      Color(0xFFE8E1F3);

  static const Color cardColor =
      Color(0xFFDCCFEA);

  static const Color cardDarkColor =
      Color(0xFFCFC0E0);

  static const Color purpleText =
      Color(0xFF4A3564);

  static const Color purpleDark =
      Color(0xFF352447);

  //==================================================
  // 🛒 أسعار المتجر
  //==================================================

  static const int coinsAdsCost = 50;
  static const int coinsReward = 100;

  static const int starsAdsCost = 50;
  static const int starsReward = 1;

  static const int gemsAdsCost = 100;
  static const int gemsReward = 1;

  //==================================================
  // INIT
  //==================================================

  @override
  void initState() {
    super.initState();

    loadWallet();

    audioPlayer = AudioPlayer();

    chestController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    chestScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(
      CurvedAnimation(
        parent: chestController,
        curve: Curves.elasticOut,
      ),
    );

    walletAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    walletPositionAnimation = Tween<Offset>(
      begin: const Offset(-2.5, 2.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: walletAnimController,
        curve: Curves.easeInOutCubic,
      ),
    );

    walletScaleAnimation = Tween<double>(
      begin: 0.4,
      end: 1.2,
    ).animate(
      CurvedAnimation(
        parent: walletAnimController,
        curve: Curves.easeInOutCubic,
      ),
    );
  }

  //==================================================
  // 🔄 تحميل المحفظة
  //==================================================

  Future<void> loadWallet() async {
    final reward = await RewardManager.getReward();

    final ads =
        await PuzzleProgressManager.getAdsBalance();

    final currentCoins =
        await PuzzleProgressManager.getCoins();

    final currentStars =
        await PuzzleProgressManager.getStars();

    final currentGems =
        await PuzzleProgressManager.getGems();

    if (!mounted) return;

    setState(() {
      coins = currentCoins;
      stars = currentStars;
      gems = currentGems;
      adsBalance = ads;

      reward;

      loading = false;
    });
  }

  //==================================================
  // 💼 حركة المحفظة
  //==================================================

  void triggerWalletOpeningAnimation() {
    if (isWalletOpeningAnim) return;

    setState(() {
      isWalletOpeningAnim = true;
    });

    walletAnimController.forward();
  }

  //==================================================
  // 🛒 شراء العملات
  //==================================================

  Future<void> buyCoins() async {
    if (buyingCoins) return;

    if (adsBalance < coinsAdsCost) {
      showNotEnoughAdsMessage(coinsAdsCost);
      return;
    }

    setState(() {
      buyingCoins = true;
    });

    final paid =
        await PuzzleProgressManager.spendAdsBalance(
      coinsAdsCost,
    );

    if (!paid) {
      if (!mounted) return;

      setState(() {
        buyingCoins = false;
      });

      showNotEnoughAdsMessage(coinsAdsCost);
      return;
    }

    await PuzzleProgressManager.addCoins(
      coinsReward,
    );

    await loadWallet();

    if (!mounted) return;

    setState(() {
      buyingCoins = false;
    });

    showPurchaseMessage(
      "🪙 تم شراء $coinsReward عملة",
    );
  }

  //==================================================
  // 🛒 شراء النجوم
  //==================================================

  Future<void> buyStars() async {
    if (buyingStars) return;

    if (adsBalance < starsAdsCost) {
      showNotEnoughAdsMessage(starsAdsCost);
      return;
    }

    setState(() {
      buyingStars = true;
    });

    final paid =
        await PuzzleProgressManager.spendAdsBalance(
      starsAdsCost,
    );

    if (!paid) {
      if (!mounted) return;

      setState(() {
        buyingStars = false;
      });

      showNotEnoughAdsMessage(starsAdsCost);
      return;
    }

    await PuzzleProgressManager.addStars(
      starsReward,
    );

    await loadWallet();

    if (!mounted) return;

    setState(() {
      buyingStars = false;
    });

    showPurchaseMessage(
      "⭐ تم شراء نجمة واحدة",
    );
  }

  //==================================================
  // 🛒 شراء الجواهر
  //==================================================

  Future<void> buyGems() async {
    if (buyingGems) return;

    if (adsBalance < gemsAdsCost) {
      showNotEnoughAdsMessage(gemsAdsCost);
      return;
    }

    setState(() {
      buyingGems = true;
    });

    final paid =
        await PuzzleProgressManager.spendAdsBalance(
      gemsAdsCost,
    );

    if (!paid) {
      if (!mounted) return;

      setState(() {
        buyingGems = false;
      });

      showNotEnoughAdsMessage(gemsAdsCost);
      return;
    }

    await PuzzleProgressManager.addGems(
      gemsReward,
    );

    await loadWallet();

    if (!mounted) return;

    setState(() {
      buyingGems = false;
    });

    showPurchaseMessage(
      "💎 تم شراء جوهرة واحدة",
    );
  }

  //==================================================
  // ❌ رصيد إعلانات غير كافٍ
  //==================================================

  void showNotEnoughAdsMessage(int required) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: purpleDark,
        content: Text(
          "📺 تحتاج إلى $required مشاهدة إعلان",
        ),
      ),
    );
  }

  //==================================================
  // ✅ نجاح الشراء
  //==================================================

  void showPurchaseMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: purpleDark,
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  //==================================================
  // 🎁 صندوق المكافأة
  //==================================================

  Future<void> openChest() async {
    if (isChestOpen || openingAd) return;

    setState(() {
      openingAd = true;
    });

    AdsManager().showRewardedAd(
      onRewardEarned: () async {
        if (!mounted) return;

        try {
          await audioPlayer.play(
            AssetSource(
              'audio/puzzle_reward.mp3',
            ),
          );
        } catch (_) {}

        await chestController.forward();

        if (!mounted) return;

        setState(() {
          isChestOpen = true;
        });

        final reward =
            await RewardManager.openRewardChest();

        if (reward == null) {
          if (!mounted) return;

          setState(() {
            openingAd = false;
            isChestOpen = false;
          });

          return;
        }

        await loadWallet();

        await chestController.reverse();

        if (!mounted) return;

        setState(() {
          isChestOpen = false;
          openingAd = false;
        });

        showRewardDialog(reward);
      },
      onAdFailed: () {
        if (!mounted) return;

        setState(() {
          openingAd = false;
        });

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              backgroundColor: purpleDark,
              content: Text(
                "الإعلان غير متوفر حالياً",
              ),
              duration: Duration(seconds: 2),
            ),
          );
      },
    );
  }

  //==================================================
  // 🎁 رسالة المكافأة
  //==================================================

  void showRewardDialog(
    RewardResultModel reward,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(
          const Duration(seconds: 3),
          () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        );

        return AlertDialog(
          backgroundColor: purpleDark,
          title: const Text(
            "🎁 مكافأة الصندوق",
            style: TextStyle(
              color: Colors.amber,
            ),
          ),
          content: Text(
            "🪙 العملات: ${reward.coins}\n"
            "⭐ النجوم: ${reward.stars}\n"
            "💎 الجواهر: ${reward.gems}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        );
      },
    );
  }

  //==================================================
  // DISPOSE
  //==================================================

  @override
  void dispose() {
    audioPlayer.dispose();
    chestController.dispose();
    walletAnimController.dispose();

    super.dispose();
  }

  //==================================================
  // BUILD
  //==================================================

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.amber,
          ),
        ),
      );
    }

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: backgroundColor,

        //================================================
        // APP BAR
        //================================================

        appBar: PreferredSize(
  preferredSize: const Size.fromHeight(
    kToolbarHeight,
  ),
  child: AppBar(
    automaticallyImplyLeading: false,

    //================================================
    // 👜 صورة المحفظة — الطرف الأيسر
    //================================================

    leading: Padding(
      padding: const EdgeInsets.all(5),
      child: Image.asset(
        "assets/images/ui/open_wallet.png",
        width: 46,
        height: 46,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) {
          return const Icon(
            Icons.account_balance_wallet_rounded,
            color: Color(0xFF5B2A86),
            size: 42,
          );
        },
      ),
    ),

    //================================================
    // ◀️ زر الرجوع — الطرف الأيمن
    //================================================

    actions: [
      Padding(
        padding: const EdgeInsets.all(7),
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Image.asset(
            "assets/images/ui/back_screen.png",
            width: 38,
            height: 38,
            fit: BoxFit.contain,
          ),
        ),
      ),
    ],

    //================================================
    // العنوان — يبقى في المنتصف
    //================================================

    title: const Text(
      "المحفظة والمتجر",
      style: TextStyle(
        color: Color(0xFF5B2A86),
        fontWeight: FontWeight.bold,
        fontSize: 19,
      ),
    ),

    centerTitle: true,
    backgroundColor: cardDarkColor,
    elevation: 3,

    iconTheme: const IconThemeData(
      color: purpleDark,
    ),
  ),
),

        //================================================
        // BODY
        //================================================

        body: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(
                    12,
                    8,
                    12,
                    6,
                  ),
                  child: Column(
                    children: [
                      //================================
                      // 📺 رصيد المشاهدات
                      //================================

                      SizedBox(
                        height: 66,
                        child: adsBalanceCard(),
                      ),

                      const SizedBox(height: 8),

                      //================================
                      // 🛒 عنوان المتجر
                      //================================

                      const Text(
                        "🛒 متجر المكافآت",
                        style: TextStyle(
                          color: purpleText,
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 2),

                      const Text(
                        "استخدم رصيد المشاهدات لشراء المكافآت",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: purpleText,
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(height: 7),

                      //================================
                      // 🪙 العملات
                      //================================

                      SizedBox(
                        height: 66,
                        child: walletCard(
                          title: "العملات",
                          value: coins,
                          assetPath:
                              "assets/images/rewards/puzzle_coin.png",
                          priceText: "50 مشاهدة",
                          onBuy: buyingCoins
                              ? null
                              : buyCoins,
                          loading: buyingCoins,
                        ),
                      ),

                      const SizedBox(height: 6),

                      //================================
                      // ⭐ النجوم
                      //================================

                      SizedBox(
                        height: 66,
                        child: walletCard(
                          title: "النجوم",
                          value: stars,
                          assetPath:
                              "assets/images/rewards/Star_gold.png",
                          priceText: "50 مشاهدة",
                          onBuy: buyingStars
                              ? null
                              : buyStars,
                          loading: buyingStars,
                        ),
                      ),

                      const SizedBox(height: 6),

                      //================================
                      // 💎 الجواهر
                      //================================

                      SizedBox(
                        height: 66,
                        child: walletCard(
                          title: "الجواهر",
                          value: gems,
                          assetPath:
                              "assets/images/rewards/gem.png",
                          priceText: "100 مشاهدة",
                          onBuy: buyingGems
                              ? null
                              : buyGems,
                          loading: buyingGems,
                        ),
                      ),

                      const SizedBox(height: 7),

                      //================================
                      // 🎁 الصندوق — أكبر
                      //================================

                      Expanded(
                        child: rewardChestCard(),
                      ),

                      //================================
                      // 📢 الإعلان
                      //================================

                      const SizedBox(height: 5),

                      SizedBox(
                        height: 50,
                        child: AdsManager().banner(),
                      ),
                    ],
                  ),
                );
              },
            ),

            //==============================================
            // 💼 حركة المحفظة
            //==============================================

            if (isWalletOpeningAnim)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.35),
                  child: Center(
                    child: SlideTransition(
                      position:
                          walletPositionAnimation,
                      child: ScaleTransition(
                        scale:
                            walletScaleAnimation,
                        child: Image.asset(
                          "assets/images/ui/open_wallet.png",
                          width: 180,
                          height: 180,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  //==================================================
  // 📺 بطاقة رصيد المشاهدات
  //==================================================

  Widget adsBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE1D4ED),
            Color(0xFFD3C2E3),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.amber.withOpacity(0.8),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(
            "assets/images/rewards/ad.png",
            width: 42,
            height: 42,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) {
              return const Icon(
                Icons.ondemand_video,
                color: Colors.amber,
                size: 42,
              );
            },
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  "رصيد المشاهدات",
                  style: TextStyle(
                    color: purpleDark,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "عملة المتجر",
                  style: TextStyle(
                    color: purpleText,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          Text(
            adsBalance.toString(),
            style: const TextStyle(
              color: Color(0xFF9A6A00),
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  //==================================================
  // 🛒 بطاقة المتجر
  //==================================================

  Widget walletCard({
    required String title,
    required int value,
    required String assetPath,
    required String priceText,
    required VoidCallback? onBuy,
    required bool loading,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE0D3EC),
            Color(0xFFD0C0E1),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.amber.withOpacity(0.55),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(
            assetPath,
            width: 45,
            height: 45,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) {
              return const Icon(
                Icons.star,
                color: Colors.amber,
                size: 42,
              );
            },
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: purpleDark,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "الرصيد: $value",
                  style: const TextStyle(
                    color: Color(0xFF80632A),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 32,
                child: ElevatedButton(
                  onPressed: onBuy,
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.amber[700],
                    foregroundColor:
                        purpleDark,
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 13,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(9),
                    ),
                  ),
                  child: loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color: purpleDark,
                          ),
                        )
                      : const Text(
                          "شراء",
                          style: TextStyle(
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 1),

              Text(
                priceText,
                style: const TextStyle(
                  color: purpleText,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //==================================================
  // 🎁 صندوق المكافأة
  //==================================================

  Widget rewardChestCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE2D5ED),
            Color(0xFFCFBEDF),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.amber.withOpacity(0.7),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.13),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          //==========================================
          // 🎁 عنوان الصندوق
          //==========================================

          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/rewards/reward_chest_closed.png",
                width: 30,
                height: 30,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) {
                  return const Icon(
                    Icons.card_giftcard,
                    color: Colors.amber,
                    size: 30,
                  );
                },
              ),

              const SizedBox(width: 6),

              const Text(
                "صندوق المكافأة الملكي",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: purpleDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 2),

          //==========================================
          // 📝 الوصف
          //==========================================

          const Text(
            "شاهد إعلاناً وافتح الصندوق للحصول على مكافأة عشوائية",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: purpleText,
            ),
          ),

          const SizedBox(height: 4),

          //==========================================
          // 🎁 الصندوق
          //==========================================

          GestureDetector(
            onTap: openingAd ? null : openChest,
            child: ScaleTransition(
              scale: chestScaleAnimation,
              child: AnimatedSwitcher(
                duration:
                    const Duration(milliseconds: 800),
                child: Image.asset(
                  isChestOpen
                      ? "assets/images/rewards/reward_chest_open.png"
                      : "assets/images/rewards/reward_chest_closed.png",
                  key: ValueKey<bool>(
                    isChestOpen,
                  ),
                  height: 145,
                  width: 145,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) {
                    return Icon(
                      isChestOpen
                          ? Icons.lock_open
                          : Icons.lock,
                      size: 100,
                      color: Colors.amber,
                    );
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 4),

          //==========================================
          // 📺 زر مشاهدة الإعلان وفتح الصندوق
          //==========================================

          SizedBox(
            width: 260,
            height: 40,
            child: ElevatedButton.icon(
              onPressed:
                  openingAd ? null : openChest,
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.amber[700],
                foregroundColor:
                    purpleDark,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(11),
                ),
                elevation: 3,
              ),
              icon: const Icon(
                Icons.card_giftcard_rounded,
                size: 21,
              ),
              label: Text(
                openingAd
                    ? "جاري فتح الإعلان..."
                    : isChestOpen
                        ? "تم فتح الصندوق!"
                        : "شاهد إعلان وافتح الصندوق",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 2),
        ],
      ),
    );
  }
}