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

  late final AnimationController _settingsAnimController;
  late final Animation<double> _settingsScaleAnimation;

  @override
  void initState() {
    super.initState();

    _settingsAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 1.0,
    );

    _settingsScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.88,
    ).animate(
      CurvedAnimation(
        parent: _settingsAnimController,
        curve: Curves.easeOut,
      ),
    );

    RewardManager.rewardNotifier.addListener(
      refreshReward,
    );

    loadToolbarData();
  }

  @override
  void dispose() {
    RewardManager.rewardNotifier.removeListener(
      refreshReward,
    );

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

  void openWallet() {
    if (!mounted) return;

    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => const WalletScreen(),
      ),
    )
        .then((_) {
      if (mounted) {
        loadToolbarData();
      }
    });
  }

  // ============================================================
  // ⚙️ Settings
  // ============================================================

  Future<void> openSettings() async {
    if (!mounted) return;

    bool sound = widget.soundEnabled;

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      useSafeArea: true,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            dialogContext,
            setDialogState,
          ) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: AlertDialog(
                backgroundColor:
                    const Color(0xFF2A1B3D),
                surfaceTintColor:
                    Colors.transparent,
                elevation: 24,
                insetPadding:
                    const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(25),
                  side: BorderSide(
                    color: Colors.white
                        .withOpacity(0.12),
                    width: 1,
                  ),
                ),
                titlePadding:
                    const EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  8,
                ),
                contentPadding:
                    const EdgeInsets.fromLTRB(
                  12,
                  8,
                  12,
                  18,
                ),
                title: const Row(
                  children: [
                    Icon(
                      Icons.settings_rounded,
                      color: Colors.amber,
                      size: 28,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'الإعدادات',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                content:
                    SingleChildScrollView(
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      // ==================================================
                      // 🔊 الصوت
                      // ==================================================

                      Container(
                        margin:
                            const EdgeInsets.only(
                          bottom: 6,
                        ),
                        decoration:
                            BoxDecoration(
                          color: Colors.white
                              .withOpacity(0.06),
                          borderRadius:
                              BorderRadius.circular(
                            15,
                          ),
                        ),
                        child:
                            SwitchListTile(
                          contentPadding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 12,
                          ),
                          title: const Text(
                            'الصوت',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),
                          secondary: Icon(
                            sound
                                ? Icons
                                    .volume_up_rounded
                                : Icons
                                    .volume_off_rounded,
                            color:
                                Colors.amber,
                          ),
                          activeColor:
                              Colors.amber,
                          value: sound,
                          onChanged:
                              (value) {
                            setDialogState(
                              () {
                                sound = value;
                              },
                            );

                            widget
                                .onSoundChanged
                                ?.call(value);
                          },
                        ),
                      ),

                      const Divider(
                        color: Colors.white24,
                        height: 18,
                      ),

                      // ==================================================
                      // 💾 حفظ اللعبة
                      // ==================================================

                      _SettingsItem(
                        icon:
                            Icons.save_rounded,
                        title:
                            'حفظ اللعبة',
                        onTap: () {
                          Navigator.of(
                            dialogContext,
                          ).pop();

                          Future.delayed(
                            const Duration(
                              milliseconds: 100,
                            ),
                            () {
                              if (mounted) {
                                widget.onSave
                                    ?.call();
                              }
                            },
                          );
                        },
                      ),

                      // ==================================================
                      // 🔄 إعادة اللعبة
                      // ==================================================

                      _SettingsItem(
                        icon: Icons
                            .restart_alt_rounded,
                        title:
                            'إعادة اللعبة',
                        onTap: () {
                          Navigator.of(
                            dialogContext,
                          ).pop();

                          Future.delayed(
                            const Duration(
                              milliseconds: 100,
                            ),
                            () {
                              if (mounted) {
                                widget
                                    .onRestart
                                    ?.call();
                              }
                            },
                          );
                        },
                      ),

                      // ==================================================
                      // 🚪 خروج
                      // ==================================================

                      _SettingsItem(
                        icon: Icons
                            .exit_to_app_rounded,
                        title: 'خروج',
                        iconColor:
                            Colors.redAccent,
                        onTap: () {
                          Navigator.of(
                            dialogContext,
                          ).pop();

                          Future.delayed(
                            const Duration(
                              milliseconds: 100,
                            ),
                            () {
                              if (mounted) {
                                widget.onExit
                                    ?.call();
                              }
                            },
                          );
                        },
                      ),

                      const Divider(
                        color: Colors.white24,
                        height: 22,
                      ),

                      const Text(
                        'Puzzle World\nالإصدار 1.0.0',
                        textAlign:
                            TextAlign.center,
                        style: TextStyle(
                          color:
                              Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
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
    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        bottom: false,
        child: Container(
          margin:
              const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          padding:
              const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 6,
          ),
          decoration:
              BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black
                    .withOpacity(0.58),
                Colors.black
                    .withOpacity(0.38),
              ],
              begin:
                  Alignment.topCenter,
              end:
                  Alignment.bottomCenter,
            ),
            borderRadius:
                BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white
                  .withOpacity(0.25),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black
                    .withOpacity(0.4),
                blurRadius: 16,
                offset:
                    const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,
            crossAxisAlignment:
                CrossAxisAlignment.center,
            children: [
              // ====================================================
              // 💰 العدادات + المحفظة
              // ====================================================

              Row(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  // ------------------------------------------------
                  // 👛 Wallet
                  // ------------------------------------------------

                  Material(
                    color:
                        Colors.transparent,
                    child: InkWell(
                      borderRadius:
                          BorderRadius
                              .circular(20),
                      onTap: openWallet,
                      child:
                          Transform.translate(
                        offset:
                            const Offset(
                          -4,
                          0,
                        ),
                        child:
                            Transform.scale(
                          scale: 1.05,
                          child:
                              Image.asset(
                            'assets/images/ui/open_wallet.png',
                            width: 36,
                            height: 36,
                            fit: BoxFit
                                .contain,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  // ------------------------------------------------
                  // 🪙 Coins
                  // ------------------------------------------------

                  Container(
                    key: widget.coinKey,
                    child:
                        CoinCounterBox(
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
                    child:
                        AnimatedStarCounter(
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
                    child:
                        ImageCounterBox(
                      image:
                          'assets/images/rewards/gem.png',
                      value: reward.gems,
                    ),
                  ),
                ],
              ),

              // ====================================================
              // ⚙️ Settings
              // ====================================================

              Material(
                color:
                    Colors.transparent,
                child: InkWell(
                  borderRadius:
                      BorderRadius.circular(
                    24,
                  ),
                  splashColor:
                      Colors.amber
                          .withOpacity(0.18),
                  highlightColor:
                      Colors.white
                          .withOpacity(0.08),

                  onTap: () {
                    openSettings();
                  },

                  child: ScaleTransition(
                    scale:
                        _settingsScaleAnimation,
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: Center(
                        child:
                            Image.asset(
                          'assets/images/ui/seting_icon.png',
                          width: 34,
                          height: 34,
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
      ),
    );
  }
}

// ================================================================
// ⚙️ Settings Item
// ================================================================

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color iconColor;

  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius:
            BorderRadius.circular(15),
        onTap: onTap,
        child: Padding(
          padding:
              const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 14,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 25,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style:
                      const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_left_rounded,
                color: Colors.white38,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================================================================
// ⭐ Animated Star Counter
// ================================================================

class AnimatedStarCounter
    extends StatefulWidget {
  final int value;

  const AnimatedStarCounter({
    super.key,
    required this.value,
  });

  @override
  State<AnimatedStarCounter>
      createState() =>
          _AnimatedStarCounterState();
}

class _AnimatedStarCounterState
    extends State<AnimatedStarCounter>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> scale;

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(
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
    super.didUpdateWidget(
      oldWidget,
    );

    if (oldWidget.value !=
        widget.value) {
      controller.forward(
        from: 0,
      );
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return ScaleTransition(
      scale: scale,
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 2,
          vertical: 2,
        ),
        child: Row(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/rewards/Star_gold.png',
              width: 28,
              height: 28,
            ),
            const SizedBox(
              width: 4,
            ),
            Text(
              '${widget.value}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight:
                    FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black,
                    blurRadius: 3,
                    offset:
                        Offset(0, 1),
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

class ImageCounterBox
    extends StatelessWidget {
  final String image;
  final int value;

  const ImageCounterBox({
    super.key,
    required this.image,
    required this.value,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 2,
        vertical: 2,
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
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
            '$value',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight:
                  FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black,
                  blurRadius: 3,
                  offset:
                      Offset(0, 1),
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

class CoinCounterBox
    extends StatelessWidget {
  final int value;

  const CoinCounterBox({
    super.key,
    required this.value,
  });

  String formatNumber(
    int number,
  ) {
    if (number >= 1000000) {
      final double result =
          number / 1000000;

      return '${result.toStringAsFixed(
        result % 1 == 0 ? 0 : 1,
      )}M';
    }

    if (number >= 1000) {
      final double result =
          number / 1000;

      return '${result.toStringAsFixed(
        result % 1 == 0 ? 0 : 1,
      )}K';
    }

    return number.toString();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.white.withOpacity(
          0.12,
        ),
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color:
              Colors.white.withOpacity(
            0.2,
          ),
        ),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/rewards/puzzle_coin.png',
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
              fontWeight:
                  FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black,
                  blurRadius: 3,
                  offset:
                      Offset(0, 1),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
