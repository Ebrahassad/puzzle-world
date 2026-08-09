import 'dart:async';

import 'package:flutter/material.dart';

import '../managers/reward_manager.dart';
import '../managers/ads_manager.dart';

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
  // 📦 الحالة
  //==================================================

  bool _isOpen = false;
  bool _isClaimed = false;
  bool _showRewardUI = false;
  bool _isDoubling = false;

  //==================================================
  // 🎁 قيم المكافأة اليومية
  //==================================================

  static const int _targetCoins = 100;
  static const int _targetStars = 1;
  static const int _targetGems = 1;

  int _displayCoins = 0;
  int _displayStars = 0;
  int _displayGems = 0;

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

    //==================================================
    // 🎬 حركة دخول الصندوق
    //==================================================

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

    _rotationAnimation = Tween<double>(
      begin: -0.05,
      end: 0.05,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: Curves.easeInOutSine,
      ),
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
        curve: const Interval(
          0.0,
          1.0,
          curve: Curves.easeInOutCubic,
        ),
      ),
    );

    _mainController.forward();

    //==================================================
    // ⏱️ تشغيل العداد
    //==================================================

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
      (_) {
        _updateDailyRewardStatus();
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

      final now = DateTime.now();

      // بداية اليوم التالي
      final tomorrow = DateTime(
        now.year,
        now.month,
        now.day + 1,
      );

      final remaining = tomorrow.difference(now);

      setState(() {
        _dailyRewardAvailable = available;

        if (available) {
          _remainingTime = Duration.zero;
        } else {
          _remainingTime = remaining;
        }
      });
    } catch (_) {
      // لا نوقف الواجهة في حالة حدوث خطأ.
    }
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
  // ⏱️ واجهة العداد تحت الصندوق
  //==================================================

  Widget _buildCountdown() {
    //==================================================
    // 🎁 المكافأة متاحة
    //==================================================

    if (_dailyRewardAvailable) {
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
            color: Colors.amber,
            width: 1.5,
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

    //==================================================
    // ⏳ المكافأة غير متاحة
    //==================================================

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
      _remainingTime = _getTimeUntilTomorrow();
    });

    _startCountingReward();
  }

  //==================================================
  // ⏰ حساب الوقت حتى اليوم التالي
  //==================================================

  Duration _getTimeUntilTomorrow() {
    final now = DateTime.now();

    final tomorrow = DateTime(
      now.year,
      now.month,
      now.day + 1,
    );

    return tomorrow.difference(now);
  }

  //==================================================
  // 🔢 عد المكافأة تدريجياً
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

            _showRewardUI = true;
          });
        }
      },
    );
  }

  //==================================================
  // ✅ استلام المكافأة
  //==================================================

  void _claimReward() {
    if (_isClaimed || _isDoubling) {
      return;
    }

    _rewardTimer?.cancel();

    setState(() {
      _isClaimed = true;
    });

    _mainController.reverse().then(
      (_) {
        if (!mounted) {
          return;
        }

        widget.onRewardClaimed();

        Navigator.of(context).pop();
      },
    );
  }

  //==================================================
  // 📺 مضاعفة المكافأة بالإعلان
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
        //==================================================
        // المكافأة الأصلية تمت إضافتها عند فتح الصندوق.
        //
        // نضيف هنا فقط النسخة الإضافية.
        //==================================================

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

        //==================================================
        // عرض المكافأة المضاعفة قليلاً
        //==================================================

        await Future.delayed(
          const Duration(
            milliseconds: 500,
          ),
        );

        if (!mounted) {
          return;
        }

        _claimReward();
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
              //==================================================
              // 📦 الصندوق
              //==================================================

              GestureDetector(
                onTap: _onBoxTap,
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

              //==================================================
              // 👆 رسالة فتح الصندوق
              //==================================================

              if (!_isOpen)
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

              //==================================================
              // ⏱️ العداد تحت الصندوق
              //==================================================

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
    if (!_isOpen) {
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
              //==================================================
              // 🎉 العنوان
              //==================================================

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

              //==================================================
              // 🪙 ⭐ 💎
              //==================================================

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceAround,
                children: [
                  _buildRewardItem(
                    '🪙',
                    '$_displayCoins',
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

              //==================================================
              // 🎮 الأزرار
              //==================================================

              if (_showRewardUI) ...[
                const SizedBox(
                  height: 20,
                ),

                //==================================================
                // ✅ استلام
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
                            : _claimReward,
                    child: const Text(
                      'استلام المكافأة',
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
                // 📺 مضاعفة المكافأة
                //==================================================

                TextButton(
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
                            color:
                                Colors.amberAccent,
                          ),
                        )
                      : const Text(
                          'مضاعفة المكافأة عبر الفيديو 🎥',
                          style: TextStyle(
                            color:
                                Colors.amberAccent,
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
            //==================================================
            // 🌑 الخلفية
            //==================================================

            Container(
              color:
                  Colors.black.withOpacity(
                0.7,
              ),
            ),

            //==================================================
            // 🎁 الصندوق + العداد
            //==================================================

            _buildBox(),

            //==================================================
            // 🎁 لوحة المكافأة
            //==================================================

            _buildRewardPanel(),
          ],
        ),
      ),
    );
  }
}