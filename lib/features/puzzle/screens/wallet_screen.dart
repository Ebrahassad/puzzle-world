import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../../core/language/app_language_manager.dart';
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
  // 🌍 اللغة
  //==================================================

  AppLanguageManager get language =>
      AppLanguageManager.instance;

  String tr({
    required String ar,
    required String en,
  }) {
    return language.text(
      ar: ar,
      en: en,
    );
  }

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
      duration: const Duration(milliseconds: 300),
    );

    chestScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.25,
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

      // إبقاء reward مستخدماً حتى لا نغيّر
      // أي نظام مكافآت آخر موجود بالمشروع.
      // ignore: unnecessary_statements
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
      tr(
        ar: "🪙 تم شراء $coinsReward عملة",
        en: "🪙 $coinsReward coins purchased",
      ),
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
      tr(
        ar: "⭐ تم شراء نجمة واحدة",
        en: "⭐ One star purchased",
      ),
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
      tr(
        ar: "💎 تم شراء جوهرة واحدة",
        en: "💎 One gem purchased",
      ),
    );
  }

  //==================================================
  // ❌ رصيد إعلانات غير كافٍ
  //==================================================

  void showNotEnoughAdsMessage(int required) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          tr(
            ar: "📺 تحتاج إلى $required مشاهدة إعلان",
            en: "📺 You need $required ad views",
          ),
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

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              tr(
                ar: "الإعلان غير متوفر حالياً",
                en: "The ad is currently unavailable",
              ),
            ),
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
          backgroundColor: const Color(0xff2A1B3D),

          title: Text(
            tr(
              ar: "🎁 مكافأة الصندوق",
              en: "🎁 Chest Reward",
            ),
            style: const TextStyle(
              color: Colors.amber,
            ),
          ),

          content: Text(
            tr(
              ar:
                  "🪙 العملات: ${reward.coins}\n"
                  "⭐ النجوم: ${reward.stars}\n"
                  "💎 الجواهر: ${reward.gems}",
              en:
                  "🪙 Coins: ${reward.coins}\n"
                  "⭐ Stars: ${reward.stars}\n"
                  "💎 Gems: ${reward.gems}",
            ),
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
        backgroundColor: Color(0xFF1A0B2E),
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.amber,
          ),
        ),
      );
    }

    return Directionality(
      textDirection: language.textDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFF1A0B2E),

        //================================================
        // APP BAR
        //================================================

        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: triggerWalletOpeningAnimation,

                child: Image.asset(
                  isWalletOpeningAnim
                      ? "assets/images/ui/open_wallet.png"
                      : "assets/images/ui/close_wallet.png",

                  width: 38,
                  height: 38,

                  fit: BoxFit.contain,

                  errorBuilder: (_, __, ___) {
                    return const Icon(
                      Icons.wallet,
                      color: Colors.amber,
                      size: 38,
                    );
                  },
                ),
              ),

              const SizedBox(width: 10),

              Text(
                tr(
                  ar: "المتجر والمحفظة",
                  en: "Store & Wallet",
                ),
                style: const TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),

          centerTitle: true,

          backgroundColor:
              const Color(0xFF2A1B3D),

          elevation: 4,

          iconTheme:
              const IconThemeData(
            color: Colors.amber,
          ),
        ),

        //================================================
        // BODY
        //================================================

        body: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight:
                          constraints.maxHeight,
                    ),

                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),

                      child: Column(
                        children: [
                          //================================
                          // 📺 رصيد المشاهدات
                          //================================

                          adsBalanceCard(),

                          const SizedBox(height: 14),

                          //================================
                          // 🛒 المتجر
                          //================================

                          Text(
                            tr(
                              ar: "🛒 متجر المكافآت",
                              en: "🛒 Reward Store",
                            ),
                            style: const TextStyle(
                              color: Colors.amber,
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            tr(
                              ar:
                                  "استخدم رصيد المشاهدات لشراء العملات والنجوم والجواهر",
                              en:
                                  "Use your ad-view balance to buy coins, stars, and gems",
                            ),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 12),

                          //================================
                          // 🪙 العملات
                          //================================

                          walletCard(
                            title: tr(
                              ar: "العملات",
                              en: "Coins",
                            ),
                            value: coins,
                            assetPath:
                                "assets/images/rewards/puzzle_coin.png",
                            priceText:
                                tr(
                              ar: "50 مشاهدة",
                              en: "50 views",
                            ),
                            onBuy:
                                buyingCoins
                                    ? null
                                    : buyCoins,
                            loading:
                                buyingCoins,
                          ),

                          const SizedBox(height: 10),

                          //================================
                          // ⭐ النجوم
                          //================================

                          walletCard(
                            title: tr(
                              ar: "النجوم",
                              en: "Stars",
                            ),
                            value: stars,
                            assetPath:
                                "assets/images/rewards/Star_gold.png",
                            priceText:
                                tr(
                              ar: "50 مشاهدة",
                              en: "50 views",
                            ),
                            onBuy:
                                buyingStars
                                    ? null
                                    : buyStars,
                            loading:
                                buyingStars,
                          ),

                          const SizedBox(height: 10),

                          //================================
                          // 💎 الجواهر
                          //================================

                          walletCard(
                            title: tr(
                              ar: "الجواهر",
                              en: "Gems",
                            ),
                            value: gems,
                            assetPath:
                                "assets/images/rewards/gem.png",
                            priceText:
                                tr(
                              ar: "100 مشاهدة",
                              en: "100 views",
                            ),
                            onBuy:
                                buyingGems
                                    ? null
                                    : buyGems,
                            loading:
                                buyingGems,
                          ),

                          const SizedBox(height: 18),

                          //================================
                          // 🎁 صندوق المكافأة
                          //================================

                          rewardChestCard(),

                          const SizedBox(height: 14),

                          //================================
                          // 📢 الإعلان
                          //================================

                          AdsManager().banner(),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
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
                  color:
                      Colors.black.withOpacity(0.6),

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

      padding:
          const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 15,
      ),

      decoration: BoxDecoration(
        gradient:
            const LinearGradient(
          colors: [
            Color(0xFF46305E),
            Color(0xFF241535),
          ],

          begin:
              Alignment.centerLeft,

          end:
              Alignment.centerRight,
        ),

        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color:
              Colors.amber.withOpacity(0.8),
          width: 2,
        ),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.45),
            blurRadius: 8,
            offset:
                const Offset(0, 4),
          ),
        ],
      ),

      child: Row(
        children: [
          Image.asset(
            "assets/images/rewards/ad.png",

            width: 48,
            height: 48,

            fit: BoxFit.contain,

            errorBuilder:
                (_, __, ___) {
              return const Icon(
                Icons.ondemand_video,
                color: Colors.amber,
                size: 48,
              );
            },
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  tr(
                    ar: "رصيد المشاهدات",
                    en: "Ad Views Balance",
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  tr(
                    ar: "عملة المتجر",
                    en: "Store Currency",
                  ),
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          Text(
            adsBalance.toString(),

            style: const TextStyle(
              color: Colors.amber,
              fontSize: 27,
              fontWeight:
                  FontWeight.bold,
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

      padding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),

      decoration: BoxDecoration(
        gradient:
            const LinearGradient(
          colors: [
            Color(0xFF311E4B),
            Color(0xFF221335),
          ],

          begin:
              Alignment.centerLeft,

          end:
              Alignment.centerRight,
        ),

        borderRadius:
            BorderRadius.circular(18),

        border: Border.all(
          color:
              Colors.amber.withOpacity(0.5),

          width: 1.5,
        ),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.3),

            blurRadius: 5,

            offset:
                const Offset(0, 2),
          ),
        ],
      ),

      child: Row(
        children: [
          Image.asset(
            assetPath,

            width: 52,
            height: 52,

            fit: BoxFit.contain,

            errorBuilder:
                (_, __, ___) {
              return const Icon(
                Icons.star,
                color: Colors.amber,
                size: 50,
              );
            },
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [
                Text(
                  title,

                  style:
                      const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  tr(
                    ar: "الرصيد: $value",
                    en: "Balance: $value",
                  ),

                  style:
                      const TextStyle(
                    color: Colors.amber,
                    fontSize: 15,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Column(
            children: [
              ElevatedButton(
                onPressed: onBuy,

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.amber[700],

                  foregroundColor:
                      const Color(
                    0xFF1A0B2E,
                  ),

                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 7,
                  ),

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      10,
                    ),
                  ),
                ),

                child: loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color:
                              Color(0xFF1A0B2E),
                        ),
                      )
                    : Text(
                        tr(
                          ar: "شراء",
                          en: "Buy",
                        ),
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
              ),

              const SizedBox(height: 3),

              Text(
                priceText,

                style:
                    const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
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

      padding:
          const EdgeInsets.all(14),

      decoration: BoxDecoration(
        gradient:
            const LinearGradient(
          colors: [
            Color(0xFF35224E),
            Color(0xFF211333),
          ],

          begin:
              Alignment.topCenter,

          end:
              Alignment.bottomCenter,
        ),

        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color:
              Colors.amber.withOpacity(0.6),

          width: 2,
        ),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.5),

            blurRadius: 8,

            offset:
                const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [
              Image.asset(
                "assets/images/rewards/reward_chest_closed.png",

                width: 34,
                height: 34,

                fit: BoxFit.contain,

                errorBuilder:
                    (_, __, ___) {
                  return const SizedBox.shrink();
                },
              ),

              const SizedBox(width: 8),

              Text(
                tr(
                  ar: "صندوق المكافأة الملكي",
                  en: "Royal Reward Chest",
                ),

                style: const TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          Text(
            tr(
              ar:
                  "شاهد إعلاناً وافتح الصندوق للحصول على مكافأة عشوائية",
              en:
                  "Watch an ad and open the chest to receive a random reward",
            ),

            textAlign:
                TextAlign.center,

            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),

          const SizedBox(height: 10),

          GestureDetector(
            onTap:
                openingAd
                    ? null
                    : openChest,

            child: ScaleTransition(
              scale:
                  chestScaleAnimation,

              child:
                  AnimatedSwitcher(
                duration:
                    const Duration(
                  milliseconds: 300,
                ),

                child: Image.asset(
                  isChestOpen
                      ? "assets/images/rewards/reward_chest_open.png"
                      : "assets/images/rewards/reward_chest_closed.png",

                  key:
                      ValueKey<bool>(
                    isChestOpen,
                  ),

                  height: 120,
                  width: 120,

                  fit: BoxFit.contain,

                  errorBuilder:
                      (_, __, ___) {
                    return Icon(
                      isChestOpen
                          ? Icons.lock_open
                          : Icons.lock,

                      size: 80,

                      color:
                          Colors.amber,
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

            child:
                ElevatedButton.icon(
              onPressed:
                  openingAd
                      ? null
                      : openChest,

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.amber[700],

                foregroundColor:
                    const Color(
                  0xFF1A0B2E,
                ),

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),

                elevation: 4,
              ),

              icon: const Icon(
                Icons.card_giftcard_rounded,
                size: 24,
              ),

              label: Text(
                openingAd
                    ? tr(
                        ar: "جاري فتح الإعلان...",
                        en: "Loading ad...",
                      )
                    : isChestOpen
                        ? tr(
                            ar: "تم فتح الصندوق!",
                            en: "Chest opened!",
                          )
                        : tr(
                            ar:
                                "شاهد إعلان وافتح الصندوق",
                            en:
                                "Watch Ad & Open Chest",
                          ),

                style:
                    const TextStyle(
                  fontSize: 16,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}