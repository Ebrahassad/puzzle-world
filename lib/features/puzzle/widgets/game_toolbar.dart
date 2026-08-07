import 'package:flutter/material.dart';

import '../screens/wallet_screen.dart';
import '../managers/reward_manager.dart';
import '../models/reward_result_model.dart';
import '../managers/ads_manager.dart';

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

class _GameToolbarState extends State<GameToolbar> with SingleTickerProviderStateMixin {
  RewardResultModel reward = const RewardResultModel();
  
  // تعريف متغيرات الأنيميشن لزر الإعدادات
  late AnimationController _settingsAnimController;
  late Animation<double> _settingsScaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // تهيئة الأنيميشن
    _settingsAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _settingsScaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
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

  void showSettings(BuildContext context) {
    bool sound = widget.soundEnabled;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              title: const Row(
                children: [
                  Icon(
                    Icons.settings_rounded,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    "الإعدادات",
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SwitchListTile(
                      title: const Text(
                        "الصوت",
                      ),
                      secondary: Icon(
                        sound ? Icons.volume_up : Icons.volume_off,
                      ),
                      value: sound,
                      onChanged: (value) {
                        setDialogState(() {
                          sound = value;
                        });
                        widget.onSoundChanged?.call(value);
                      },
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: Center(
                        child: AdsManager().banner(),
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.save_rounded),
                      title: const Text("حفظ اللعبة"),
                      onTap: () async {
                        Navigator.pop(context);
                        await Future.delayed(
                          const Duration(milliseconds: 200),
                        );
                        widget.onSave?.call();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.restart_alt_rounded),
                      title: const Text("إعادة اللعبة"),
                      onTap: () {
                        Navigator.pop(context);
                        widget.onRestart?.call();
                      },
                    ),
                    ListTile(
                      leading: const Icon(
                        Icons.exit_to_app_rounded,
                      ),
                      title: const Text(
                        "خروج",
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        widget.onExit?.call();
                      },
                    ),
                    const Divider(),
                    const Text(
                      "Puzzle World\nالإصدار 1.0.0",
                      textAlign: TextAlign.center,
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

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // العدادات في الطرف الأيمن (العملات مع المحفظة المفتوحة، النجوم، الجواهر)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.translate(
                  offset: const Offset(-6, 0),
                  child: Transform.scale(
                    scale: 1.35,
                    child: Image.asset(
                      "assets/images/ui/open_wallet.png",
                      width: 42,
                      height: 42,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                const SizedBox(width: 4),

                Container(
                  key: widget.coinKey,
                  child: CoinCounterBox(
                    value: reward.coins,
                  ),
                ),
                const SizedBox(
                  width: 6,
                ),
                Container(
                  key: widget.starKey,
                  child: AnimatedStarCounter(
                    value: reward.stars,
                  ),
                ),
                const SizedBox(
                  width: 6,
                ),
                Container(
                  key: widget.gemKey,
                  child: ImageCounterBox(
                    image: "assets/images/rewards/gem.png",
                    value: reward.gems,
                  ),
                ),
              ],
            ),

            // زر الإعدادات في الطرف الأيسر مع تأثير الأنيميشن عند الضغط
            GestureDetector(
              behavior: HitTestBehavior.opaque,

              onTapDown: (_) {
                _settingsAnimController.forward();
              },

              onTapUp: (_) {
                _settingsAnimController.reverse();
                showSettings(context);
              },

              onTapCancel: () {
                _settingsAnimController.reverse();
              },
              child: ScaleTransition(
                scale: _settingsScaleAnimation,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.35),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.settings_rounded,
                    color: Colors.white,
                    size: 24,
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
  void didUpdateWidget(covariant AnimatedStarCounter oldWidget) {
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
            const SizedBox(width: 4),
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
          const SizedBox(width: 4),
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


class CoinCounterBox extends StatelessWidget {
  final int value;

  const CoinCounterBox({
    super.key,
    required this.value,
  });

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
          // صورة العملة
          Image.asset(
  "assets/images/rewards/puzzle_coin.png",
  width: 28,
  height: 28,
),
          const SizedBox(width: 5),
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
