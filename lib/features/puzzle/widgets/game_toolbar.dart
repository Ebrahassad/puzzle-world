import 'package:flutter/material.dart';

import '../screens/wallet_screen.dart';
import '../managers/reward_manager.dart';
import '../models/reward_result_model.dart';

class GameToolbar extends StatefulWidget {
  final VoidCallback? onBack;

  final GlobalKey starKey;
  final GlobalKey gemKey;
  final GlobalKey coinKey;

  final VoidCallback? onSave;
  final VoidCallback? onRestart;
  final VoidCallback? onExit;

  final bool soundEnabled;
  final ValueChanged<bool>? onSoundChanged;

  const GameToolbar({
    super.key,
    required this.starKey,
    required this.gemKey,
    required this.coinKey,
    this.onBack,
    this.onSave,
    this.onRestart,
    this.onExit,
    this.soundEnabled = true,
    this.onSoundChanged,
  });

  @override
  State<GameToolbar> createState() => _GameToolbarState();
}

class _GameToolbarState extends State<GameToolbar>
    with SingleTickerProviderStateMixin {
  RewardResultModel reward = const RewardResultModel();

  // ============================================================
  // ⚙️ Settings animation
  // ============================================================

  late AnimationController _settingsAnimController;
  late Animation<double> _settingsScaleAnimation;

  @override
  void initState() {
    super.initState();

    _settingsAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _settingsScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.86,
    ).animate(
      CurvedAnimation(
        parent: _settingsAnimController,
        curve: Curves.easeInOut,
      ),
    );

    RewardManager.rewardNotifier.addListener(refreshReward);

    loadToolbarData();
  }

  @override
  void dispose() {
    RewardManager.rewardNotifier.removeListener(refreshReward);

    _settingsAnimController.dispose();

    super.dispose();
  }

  // ============================================================
  // 💰 Reward data
  // ============================================================

  Future<void> loadToolbarData() async {
    final data = await RewardManager.getReward();

    if (!mounted) return;

    setState(() {
      reward = data;
    });
  }

  void refreshReward() {
    loadToolbarData();
  }

  // ============================================================
  // 👛 Wallet
  // ============================================================

  void openWallet(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const WalletScreen(),
      ),
    ).then((_) {
      loadToolbarData();
    });
  }

  // ============================================================
  // ⚙️ Settings
  // ============================================================

  void showSettings(BuildContext context) {
    bool sound = widget.soundEnabled;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF2A1B3D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              title: const Row(
                children: [
                  Icon(
                    Icons.settings_rounded,
                    color: Colors.amber,
                  ),
                  SizedBox(width: 8),
                  Text(
                    "الإعدادات",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ==================================================
                    // 🔊 الصوت
                    // ==================================================
                    SwitchListTile(
                      title: const Text(
                        "الصوت",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      secondary: Icon(
                        sound ? Icons.volume_up : Icons.volume_off,
                        color: Colors.amber,
                      ),
                      value: sound,
                      onChanged: (value) {
                        setDialogState(() {
                          sound = value;
                        });
                        widget.onSoundChanged?.call(value);
                      },
                    ),

                    const Divider(
                      color: Colors.white24,
                    ),

                    // ==================================================
                    // 💾 حفظ اللعبة
                    // ==================================================
                    ListTile(
                      leading: const Icon(
                        Icons.save_rounded,
                        color: Colors.white,
                      ),
                      title: const Text(
                        "حفظ اللعبة",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onTap: () async {
                        Navigator.pop(dialogContext);

                        await Future.delayed(
                          const Duration(
                            milliseconds: 200,
                          ),
                        );

                        widget.onSave?.call();
                      },
                    ),

                    // ==================================================
                    // 🔄 إعادة اللعبة
                    // ==================================================
                    ListTile(
                      leading: const Icon(
                        Icons.restart_alt_rounded,
                        color: Colors.white,
                      ),
                      title: const Text(
                        "إعادة اللعبة",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(dialogContext);

                        widget.onRestart?.call();
                      },
                    ),

                    // ==================================================
                    // 🚪 خروج
                    // ==================================================
                    ListTile(
                      leading: const Icon(
                        Icons.exit_to_app_rounded,
                        color: Colors.white,
                      ),
                      title: const Text(
                        "خروج",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(dialogContext);

                        widget.onExit?.call();
                      },
                    ),

                    const Divider(
                      color: Colors.white24,
                    ),

                    const Text(
                      "Puzzle World\nالإصدار 1.0.0",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // 🎨 Build Toolbar
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.55),
              Colors.black.withOpacity(0.35),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: Colors.white.withOpacity(0.25),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),

        // ========================================================
        // 🔄 تم عكس ترتيب الشريط
        //
        // اليمين  ← الإعدادات
        // اليسار  ← المحفظة + العملات
        // ========================================================

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // ====================================================
            // 💰 العدادات + المحفظة
            //
            // أصبحت الآن في الطرف الأيسر
            // ====================================================

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ------------------------------------------------
                // 👛 Wallet
                // ------------------------------------------------

                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    openWallet(context);
                  },
                  child: Transform.translate(
                    offset: const Offset(-4, 0),
                    child: Transform.scale(
                      scale: 1.05,
                      child: Image.asset(
                        "assets/images/ui/open_wallet.png",
                        width: 36,
                        height: 36,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  width: 5,
                ),

                // ------------------------------------------------
                // 🪙 Coins
                // ------------------------------------------------

                Container(
                  key: widget.coinKey,
                  child: CoinCounterBox(
                    value: reward.coins,
                  ),
                ),

                const SizedBox(
                  width: 6,
                ),

                // ------------------------------------------------
                // ⭐ Stars
                // ------------------------------------------------

                Container(
                  key: widget.starKey,
                  child: AnimatedStarCounter(
                    value: reward.stars,
                  ),
                ),

                const SizedBox(
                  width: 6,
                ),

                // ------------------------------------------------
                // 💎 Gems
                // ------------------------------------------------

                Container(
                  key: widget.gemKey,
                  child: ImageCounterBox(
                    image: "assets/images/rewards/gem.png",
                    value: reward.gems,
                  ),
                ),
              ],
            ),

            // ====================================================
            // ⚙️ Settings
            //
            // الآن في الطرف الأيمن
            // ====================================================

            GestureDetector(
              behavior: HitTestBehavior.opaque,

              onTapDown: (_) {
                _settingsAnimController.forward();
              },

              onTapUp: (_) async {
                _settingsAnimController.reverse();

                // فتح الإعدادات مباشرة بعد انتهاء حركة الضغط
                await Future.delayed(
                  const Duration(milliseconds: 50),
                );

                if (!mounted) {
                  return;
                }

                showSettings(context);
              },

              onTapCancel: () {
                _settingsAnimController.reverse();
              },

              child: ScaleTransition(
                scale: _settingsScaleAnimation,
                child: SizedBox(
                  width: 48,
                  height: 48,
                  child: Center(
                    child: Image.asset(
                      "assets/images/ui/seting_icon.png",
                      width: 34,
                      height: 34,
                      fit: BoxFit.contain,
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
}

// ================================================================
// ⭐ Animated Star Counter
// ================================================================

class AnimatedStarCounter extends StatefulWidget {
  final int value;

  const AnimatedStarCounter({
    super.key,
    required this.value,
  });

  @override
  State<AnimatedStarCounter> createState() => _AnimatedStarCounterState();
}

class _AnimatedStarCounterState extends State<AnimatedStarCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scale;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 500,
      ),
    );

    scale = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Curves.elasticOut,
      ),
    );

    controller.forward();
  }

  @override
  void didUpdateWidget(
    covariant AnimatedStarCounter oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value != widget.value) {
      controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scale,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 2,
          vertical: 2,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              "assets/images/rewards/Star_gold.png",
              width: 28,
              height: 28,
            ),
            const SizedBox(
              width: 4,
            ),
            Text(
              "${widget.value}",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black,
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// 💎 Image Counter
// ================================================================

class ImageCounterBox extends StatelessWidget {
  final String image;
  final int value;

  const ImageCounterBox({
    super.key,
    required this.image,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 2,
        vertical: 2,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            image,
            width: 28,
            height: 28,
          ),
          const SizedBox(
            width: 4,
          ),
          Text(
            "$value",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black,
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// 🪙 Coin Counter
// ================================================================

class CoinCounterBox extends StatelessWidget {
  final int value;

  const CoinCounterBox({
    super.key,
    required this.value,
  });

  String formatNumber(int number) {
    if (number >= 1000000) {
      double result = number / 1000000;

      return "${result.toStringAsFixed(
        result % 1 == 0 ? 0 : 1,
      )}M";
    }

    if (number >= 1000) {
      double result = number / 1000;

      return "${result.toStringAsFixed(
        result % 1 == 0 ? 0 : 1,
      )}K";
    }

    return number.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            "assets/images/rewards/puzzle_coin.png",
            width: 28,
            height: 28,
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            formatNumber(value),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black,
                  blurRadius: 3,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
