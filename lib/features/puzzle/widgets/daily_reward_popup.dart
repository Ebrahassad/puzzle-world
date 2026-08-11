import 'dart:async';

import 'package:flutter/material.dart';

import '../managers/reward_manager.dart';
import '../managers/ads_manager.dart';
import '../managers/puzzle_progress_manager.dart';

class DailyRewardPopup extends StatefulWidget {
  final VoidCallback onRewardClaimed;

  const DailyRewardPopup({
    super.key,
    required this.onRewardClaimed,
  });

  @override
  State<DailyRewardPopup> createState() => _DailyRewardPopupState();
}

class _DailyRewardPopupState extends State<DailyRewardPopup>
    with TickerProviderStateMixin {
  //==================================================
  // 🎬 Animation
  //==================================================

  late AnimationController _mainController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Offset> _positionAnimation;

  //==================================================
  // ✨ Animation وهج المكافأة
  //==================================================

  late AnimationController _rewardGlowController;

  //==================================================
  // 📦 الحالة
  //==================================================

  bool _isOpen = false;
  bool _isClaimed = false;
  bool _showRewardUI = false;
  bool _isDoubling = false;

  // الوهج يظهر فقط في الأسفل عندما تكون المكافأة متاحة
  bool _glowEnabled = true;

  //==================================================
  // 🎁 قيم المكافأة اليومية
  //==================================================

  static const int _targetCoins = 100;
  static const int _targetStars = 1;
  static const int _targetGems = 1;

  int _displayCoins = 0;
  int _displayStars = 0;
  int _displayGems = 0;
  int _displayAdsBalance = 0;

  //==================================================
  // ⏱️ العداد
  //==================================================

  Timer? _countdownTimer;
  Timer? _rewardTimer;

  Duration _remainingTime = Duration.zero;

  bool _dailyRewardAvailable = true;

  //==================================================
  // 🚀 INIT
  //==================================================

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1200,
      ),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.15,
        ).chain(
          CurveTween(
            curve: Curves.easeOut,
          ),
        ),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.15,
          end: 1.0,
        ).chain(
          CurveTween(
            curve: Curves.easeInOut,
          ),
        ),
        weight: 40,
      ),
    ]).animate(
      _mainController,
    );

    //==================================================
    // الصندوق يميل أثناء الحركة فقط ثم ينتهي مستقيم
    //==================================================

    _rotationAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: -0.05,
          end: 0.05,
        ).chain(
          CurveTween(
            curve: Curves.easeInOut,
          ),
        ),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.05,
          end: 0.0,
        ).chain(
          CurveTween(
            curve: Curves.easeOut,
          ),
        ),
        weight: 30,
      ),
    ]).animate(
      _mainController,
    );

    _positionAnimation = Tween<Offset>(
      begin: const Offset(
        -2.0,
        2.0,
      ),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: Curves.easeInOutCubic,
      ),
    );

    _mainController.forward();

    //==================================================
    // ✨ وهج المكافأة
    //==================================================

    _rewardGlowController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1800,
      ),
    )..repeat(
        reverse: true,
      );

    _initializeCountdown();
  }

  //==================================================
  // 🧹 DISPOSE
  //==================================================

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _rewardTimer?.cancel();

    _mainController.dispose();
    _rewardGlowController.dispose();

    super.dispose();
  }

  //==================================================
  // ⏱️ تهيئة العداد
  //==================================================

  Future<void> _initializeCountdown() async {
    await _updateDailyRewardStatus();

    if (!mounted) {
      return;
    }

    _countdownTimer?.cancel();

    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) async {
        await _tickCountdown();
      },
    );
  }

  //==================================================
  // ⏱️ تحديث حالة المكافأة
  //==================================================

  Future<void> _updateDailyRewardStatus() async {
    try {
      final available =
          await RewardManager.canClaimDailyReward();

      if (!mounted) {
        return;
      }

      if (available) {
        setState(() {
          _dailyRewardAvailable = true;
          _remainingTime = Duration.zero;

          _isOpen = false;
          _isClaimed = false;
          _showRewardUI = false;
          _isDoubling = false;

          _displayCoins = 0;
          _displayStars = 0;
          _displayGems = 0;
          _displayAdsBalance = 0;

          _glowEnabled = true;
        });

        return;
      }

      // ==============================================
      // ⏱️ المتبقي من 24 ساعة منذ استلام المكافأة
      // ==============================================

      final remaining =
          await RewardManager.getDailyRewardRemaining();

      if (!mounted) {
        return;
      }

      setState(() {
        _dailyRewardAvailable =
            remaining <= Duration.zero;

        _remainingTime =
            remaining <= Duration.zero
                ? Duration.zero
                : remaining;

        _glowEnabled =
            remaining <= Duration.zero;
      });
    } catch (_) {}
  }

  //==================================================
  // ⏱️ نبضة العداد
  //==================================================

  Future<void> _tickCountdown() async {
    if (!mounted) {
      return;
    }

    if (_dailyRewardAvailable) {
      return;
    }

    final newRemaining =
        await RewardManager.getDailyRewardRemaining();

    if (!mounted) {
      return;
    }

    if (newRemaining <= Duration.zero) {
      setState(() {
        _remainingTime = Duration.zero;

        _dailyRewardAvailable = true;

        _isOpen = false;
        _isClaimed = false;
        _showRewardUI = false;
        _isDoubling = false;

        _displayCoins = 0;
        _displayStars = 0;
        _displayGems = 0;
        _displayAdsBalance = 0;

        _glowEnabled = true;
      });

      return;
    }

    setState(() {
      _remainingTime = newRemaining;
      _glowEnabled = false;
    });
  }

  //==================================================
  // ⏱️ تنسيق الوقت
  //==================================================

  String _formatRemainingTime() {
    if (_remainingTime <= Duration.zero) {
      return '00:00:00';
    }

    final hours = _remainingTime.inHours;

    final minutes =
        _remainingTime.inMinutes.remainder(60);

    final seconds =
        _remainingTime.inSeconds.remainder(60);

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  //==================================================
  // ✨ وهج أسفل الصندوق فقط
  //==================================================

  BoxDecoration _rewardGlowDecoration() {
    final glowStrength =
        0.55 +
        (_rewardGlowController.value * 0.30);

    return BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.amber.withOpacity(
            glowStrength,
          ),
          blurRadius: 18,
          spreadRadius: 3,
          offset: const Offset(
            0,
            8,
          ),
        ),
      ],
    );
  }

  //==================================================
  // ⏱️ واجهة العداد تحت الصندوق
  //==================================================

  Widget _buildCountdown() {
    if (_dailyRewardAvailable) {
      return AnimatedBuilder(
        animation: _rewardGlowController,
        builder: (
          context,
          child,
        ) {
          return Container(
            margin: const EdgeInsets.only(
              top: 12,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 8,
            ),
            decoration: _glowEnabled
                ? _rewardGlowDecoration().copyWith(
                    color: const Color(
                      0xFF2A1B3D,
                    ),
                  )
                : const BoxDecoration(
                    color: Color(
                      0xFF2A1B3D,
                    ),
                    borderRadius:
                        BorderRadius.all(
                      Radius.circular(14),
                    ),
                  ),
            child: child,
          );
        },
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.card_giftcard_rounded,
              color: Colors.amber,
              size: 20,
            ),
            SizedBox(
              width: 8,
            ),
            Text(
              'المكافأة متاحة الآن',
              style: TextStyle(
                color: Colors.amber,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(
        top: 12,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(
          0xFF2A1B3D,
        ),
        borderRadius: BorderRadius.circular(
          14,
        ),
        border: Border.all(
          color: Colors.white.withOpacity(
            0.25,
          ),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              0.25,
            ),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'المكافأة التالية بعد',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(
            height: 3,
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.timer_outlined,
                color: Colors.amber,
                size: 20,
              ),
              const SizedBox(
                width: 7,
              ),
              Text(
                _formatRemainingTime(),
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  //==================================================
  // 🎁 الضغط على الصندوق
  //==================================================

  Future<void> _onBoxTap() async {
    if (_isOpen ||
        _isClaimed ||
        _isDoubling ||
        !_dailyRewardAvailable) {
      return;
    }

    //==================================================
    // ❌ إيقاف الوهج فور الضغط
    //==================================================

    if (mounted) {
      setState(() {
        _glowEnabled = false;
      });
    }

    //==================================================
    // تحريك الصندوق للمنتصف
    //==================================================

    await _mainController.forward();

    if (!mounted) {
      return;
    }

    //==================================================
    // 🎁 مكافأة البداية
    //==================================================

    final firstReward =
        await PuzzleProgressManager.claimFirstDailyReward();

    if (firstReward) {
      await RewardManager.addStars(10);
      await RewardManager.addGems(5);

      // بدء عداد 24 ساعة من لحظة استلام مكافأة البداية
      await RewardManager.startDailyRewardCooldown();

      if (!mounted) {
        return;
      }

      setState(() {
        _isOpen = true;

        _dailyRewardAvailable = false;

        _remainingTime =
            const Duration(hours: 24);

        _displayCoins = 0;
        _displayStars = 0;
        _displayGems = 0;
        _displayAdsBalance = 0;

        _showRewardUI = false;
        _isClaimed = false;

        _glowEnabled = false;
      });

      _startCountingFirstReward();

      return;
    }

    //==================================================
    // 🎁 المكافأة اليومية
    //==================================================

    final reward =
        await RewardManager.claimDailyReward();

    if (reward == null) {
      await _updateDailyRewardStatus();
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isOpen = true;

      _dailyRewardAvailable = false;

      _remainingTime =
          const Duration(hours: 24);

      _displayCoins = 0;
      _displayStars = 0;
      _displayGems = 0;
      _displayAdsBalance = 0;

      _showRewardUI = false;
      _isClaimed = false;

      _glowEnabled = false;
    });

    _startCountingReward();
  }

  //==================================================
  // 🔢 عد المكافأة
  //==================================================

  void _startCountingReward() {
    _rewardTimer?.cancel();

    int step = 0;

    _rewardTimer = Timer.periodic(
      const Duration(
        milliseconds: 50,
      ),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        step++;

        final progress =
            (step / 20).clamp(
          0.0,
          1.0,
        );

        setState(() {
          _displayCoins =
              (_targetCoins * progress).round();

          _displayStars =
              (_targetStars * progress).round();

          _displayGems =
              (_targetGems * progress).round();

          _displayAdsBalance = 0;
        });

        if (step >= 20) {
          timer.cancel();

          if (!mounted) {
            return;
          }

          setState(() {
            _displayCoins = _targetCoins;
            _displayStars = _targetStars;
            _displayGems = _targetGems;
            _displayAdsBalance = 0;

            _showRewardUI = true;
          });
        }
      },
    );
  }

  //==================================================
  // 🎁 عد مكافأة البداية
  //==================================================

  void _startCountingFirstReward() {
    _rewardTimer?.cancel();

    int step = 0;

    const int firstRewardAdsBalance = 500;
    const int firstRewardStars = 10;
    const int firstRewardGems = 5;

    _rewardTimer = Timer.periodic(
      const Duration(
        milliseconds: 20,
      ),
      (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        step++;

        final progress =
            (step / 25).clamp(
          0.0,
          1.0,
        );

        setState(() {
          _displayAdsBalance =
              (firstRewardAdsBalance * progress).round();

          _displayCoins = 0;

          _displayStars =
              (firstRewardStars * progress).round();

          _displayGems =
              (firstRewardGems * progress).round();
        });

        if (step >= 25) {
          timer.cancel();

          if (!mounted) {
            return;
          }

          setState(() {
            _displayAdsBalance =
                firstRewardAdsBalance;

            _displayCoins = 0;

            _displayStars =
                firstRewardStars;

            _displayGems =
                firstRewardGems;

            _showRewardUI = true;
          });
        }
      },
    );
  }

  //==================================================
  // 🔄 إعادة الصندوق
  //==================================================

  Future<void> _returnBoxToPosition({
    bool closeDialog = true,
  }) async {
    if (!mounted) {
      return;
    }

    await _mainController.reverse();

    if (!mounted) {
      return;
    }

    setState(() {
      _isOpen = false;
      _showRewardUI = false;
      _isClaimed = false;
      _isDoubling = false;
      _glowEnabled = false;
    });

    widget.onRewardClaimed();

    if (closeDialog && mounted) {
      Navigator.of(context).pop();
    }
  }

  //==================================================
  // ❌ إلغاء / إنهاء المكافأة
  //==================================================

  Future<void> _cancelReward() async {
    if (_isDoubling) {
      return;
    }

    _rewardTimer?.cancel();

    if (!mounted) {
      return;
    }

    setState(() {
      _isClaimed = true;
      _showRewardUI = false;
      _glowEnabled = false;
    });

    await _returnBoxToPosition();
  }

  //==================================================
  // 📺 مضاعفة المكافأة
  //==================================================

  void _watchAdToDouble() {
    if (_isDoubling || _isClaimed) {
      return;
    }

    setState(() {
      _isDoubling = true;
    });

    AdsManager().showRewardedAd(
      onRewardEarned: () async {
        if (_displayAdsBalance > 0) {
          await PuzzleProgressManager.addAdsBalance(
            _displayAdsBalance,
          );

          if (!mounted) {
            return;
          }

          setState(() {
            _displayAdsBalance *= 2;
            _isDoubling = false;
          });
        } else {
          await RewardManager.addCoins(
            _targetCoins,
          );

          await RewardManager.addStars(
            _targetStars,
          );

          await RewardManager.addGems(
            _targetGems,
          );

          if (!mounted) {
            return;
          }

          setState(() {
            _displayCoins =
                _targetCoins * 2;

            _displayStars =
                _targetStars * 2;

            _displayGems =
                _targetGems * 2;

            _isDoubling = false;
          });
        }

        await Future.delayed(
          const Duration(
            milliseconds: 500,
          ),
        );

        if (!mounted) {
          return;
        }

        await _returnBoxToPosition();
      },
      onAdFailed: () {
        if (!mounted) {
          return;
        }

        setState(() {
          _isDoubling = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'الإعلان غير متوفر حالياً',
            ),
          ),
        );
      },
    );
  }

  //==================================================
  // 🎁 عنصر المكافأة
  //==================================================

  Widget _buildRewardItem(
    String emoji,
    String value,
  ) {
    return Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(
            fontSize: 28,
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  //==================================================
  // ✨ وهج الصندوق المتاح
  //==================================================

  Widget _buildAvailableBoxGlow({
    required Widget child,
  }) {
    if (!_dailyRewardAvailable ||
        _isOpen ||
        !_glowEnabled) {
      return child;
    }

    return AnimatedBuilder(
      animation: _rewardGlowController,
      builder: (context, _) {
        final glowStrength =
            0.35 +
            (_rewardGlowController.value * 0.45);

        final blur =
            12 +
            (_rewardGlowController.value * 18);

        return Container(
          width: 220,
          height: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.amber.withOpacity(
                  glowStrength,
                ),
                blurRadius: blur,
                spreadRadius: 5,
              ),
            ],
          ),
          child: child,
        );
      },
    );
  }

  //==================================================
  // 🎨 الصندوق
  //==================================================

  Widget _buildBox() {
    return SlideTransition(
      position: _positionAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: RotationTransition(
          turns: _rotationAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _onBoxTap,
                child: _buildAvailableBoxGlow(
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: AnimatedSwitcher(
                      duration: const Duration(
                        milliseconds: 350,
                      ),
                      transitionBuilder: (
                        child,
                        animation,
                      ) {
                        return ScaleTransition(
                          scale: animation,
                          child: FadeTransition(
                            opacity: animation,
                            child: child,
                          ),
                        );
                      },
                      child: Image.asset(
                        _isOpen
                            ? 'assets/images/rewards/daly_box_open.png'
                            : 'assets/images/rewards/daly_box_close.png',
                        key: ValueKey<bool>(
                          _isOpen,
                        ),
                        fit: BoxFit.contain,
                        errorBuilder: (
                          _,
                          __,
                          ___,
                        ) {
                          return Icon(
                            _isOpen
                                ? Icons.card_giftcard_rounded
                                : Icons.card_giftcard_outlined,
                            size: 100,
                            color: Colors.amber,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              if (!_isOpen &&
                  _dailyRewardAvailable)
                const Padding(
                  padding: EdgeInsets.only(
                    top: 16,
                  ),
                  child: Text(
                    'انقر لفتح المكافأة اليومية!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              _buildCountdown(),
            ],
          ),
        ),
      ),
    );
  }

  //==================================================
  // 🎁 لوحة المكافأة
  //==================================================

  Widget _buildRewardPanel() {
    if (!_isOpen ||
        _isClaimed) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 20,
      right: 20,
      bottom: 90,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.0,
        ),
        duration: const Duration(
          milliseconds: 400,
        ),
        builder: (
          context,
          value,
          child,
        ) {
          return Transform.scale(
            scale: value,
            child: Opacity(
              opacity: value,
              child: child,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(
            20,
          ),
          decoration: BoxDecoration(
            color: const Color(
              0xFF2A1B3D,
            ),
            borderRadius:
                BorderRadius.circular(
              20,
            ),
            border: Border.all(
              color: Colors.amber,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    Colors.black.withOpacity(
                  0.5,
                ),
                blurRadius: 15,
                offset: const Offset(
                  0,
                  5,
                ),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'مبروك! حصلت على مكافأتك',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 15,
              ),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceAround,
                children: [
                  _buildRewardItem(
                    _displayAdsBalance > 0
                        ? '📺'
                        : '🪙',
                    _displayAdsBalance > 0
                        ? '$_displayAdsBalance'
                        : '$_displayCoins',
                  ),
                  _buildRewardItem(
                    '⭐',
                    '$_displayStars',
                  ),
                  _buildRewardItem(
                    '💎',
                    '$_displayGems',
                  ),
                ],
              ),

              if (_showRewardUI) ...[
                const SizedBox(
                  height: 20,
                ),

                //==================================================
                // 📺 مكافأة إضافية
                //==================================================

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.amber,
                      foregroundColor:
                          Colors.black,
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                      ),
                    ),
                    onPressed:
                        _isDoubling ||
                                _isClaimed
                            ? null
                            : _watchAdToDouble,
                    child: _isDoubling
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : const Text(
                            'مكافأة إضافية 🎥',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                //==================================================
                // ❌ إلغاء
                //==================================================

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed:
                        _isDoubling ||
                                _isClaimed
                            ? null
                            : _cancelReward,
                    style:
                        OutlinedButton.styleFrom(
                      foregroundColor:
                          Colors.white,
                      side: BorderSide(
                        color:
                            Colors.white.withOpacity(
                          0.5,
                        ),
                      ),
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 11,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                      ),
                    ),
                    child: const Text(
                      'إلغاء',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  //==================================================
  // 🖥️ BUILD
  //==================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Dialog(
      backgroundColor:
          Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: SizedBox.expand(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              color:
                  Colors.black.withOpacity(
                0.7,
              ),
            ),

            _buildBox(),

            _buildRewardPanel(),
          ],
        ),
      ),
    );
  }
}
