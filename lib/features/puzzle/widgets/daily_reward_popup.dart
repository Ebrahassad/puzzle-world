import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  // ============================================================
  // 🎬 Controllers
  // ============================================================

  late AnimationController _boxController;
  late AnimationController _rewardController;
  late AnimationController _returnController;

  late Animation<Offset> _boxPosition;
  late Animation<double> _boxScale;
  late Animation<double> _boxRotation;

  // ============================================================
  // 📦 الحالة
  // ============================================================

  bool _isOpen = false;
  bool _isClaimed = false;
  bool _showRewardUI = false;
  bool _isWatchingAd = false;

  // ============================================================
  // 🎁 القيم المعروضة
  // ============================================================

  int _displayCoins = 0;
  int _displayStars = 0;
  int _displayGems = 0;

  static const int _targetCoins = 100;
  static const int _targetStars = 1;
  static const int _targetGems = 1;

  // ============================================================
  // ⏱️ عداد المكافأة اليومية
  // ============================================================

  Timer? _rewardTimer;
  Timer? _dailyCountdownTimer;

  Duration _remainingTime = Duration.zero;

  bool _dailyRewardAvailable = true;

  // نفس المفتاح الموجود في RewardManager
  static const String _dailyRewardKey =
      RewardManager.dailyRewardKey;

  // ============================================================
  // 🚀 INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    // ----------------------------------------------------------
    // حركة الصندوق من أعلى اليسار إلى المنتصف
    // ----------------------------------------------------------

    _boxController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 900,
      ),
    );

    _boxPosition = Tween<Offset>(
      begin: const Offset(
        -1.15,
        -3.0,
      ),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _boxController,
        curve: Curves.easeOutBack,
      ),
    );

    _boxScale = Tween<double>(
      begin: 0.55,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _boxController,
        curve: Curves.easeOutBack,
      ),
    );

    _boxRotation = Tween<double>(
      begin: -0.08,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _boxController,
        curve: Curves.easeOutCubic,
      ),
    );

    // ----------------------------------------------------------
    // حركة المكافآت نحو المحفظة
    // ----------------------------------------------------------

    _rewardController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1100,
      ),
    );

    // ----------------------------------------------------------
    // رجوع الصندوق إلى أعلى اليسار
    // ----------------------------------------------------------

    _returnController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 750,
      ),
    );

    // ----------------------------------------------------------
    // فحص حالة المكافأة والعداد
    // ----------------------------------------------------------

    _loadDailyRewardStatus();

    // ----------------------------------------------------------
    // بدء حركة الصندوق
    // ----------------------------------------------------------

    _boxController.forward();
  }

  // ============================================================
  // ⏱️ تحميل حالة المكافأة اليومية
  // ============================================================

  Future<void> _loadDailyRewardStatus() async {
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
        });

        _stopDailyCountdown();
        return;
      }

      final prefs =
          await SharedPreferences.getInstance();

      final saved =
          prefs.getString(_dailyRewardKey);

      if (saved == null) {
        _setRewardAvailable();
        return;
      }

      final lastClaim =
          DateTime.tryParse(saved);

      if (lastClaim == null) {
        _setRewardAvailable();
        return;
      }

      _startDailyCountdown(lastClaim);
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _dailyRewardAvailable = true;
        _remainingTime = Duration.zero;
      });
    }
  }

  // ============================================================
  // ⏱️ بدء عداد اليوم التالي
  // ============================================================

  void _startDailyCountdown(DateTime lastClaim) {
    _dailyCountdownTimer?.cancel();

    void updateCountdown() {
      final now = DateTime.now();

      final nextReward = DateTime(
        now.year,
        now.month,
        now.day + 1,
      );

      final remaining =
          nextReward.difference(now);

      if (remaining <= Duration.zero) {
        _setRewardAvailable();
        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _dailyRewardAvailable = false;
        _remainingTime = remaining;
      });
    }

    updateCountdown();

    _dailyCountdownTimer =
        Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        updateCountdown();
      },
    );
  }

  // ============================================================
  // 🎁 جعل المكافأة متاحة
  // ============================================================

  void _setRewardAvailable() {
    _dailyCountdownTimer?.cancel();
    _dailyCountdownTimer = null;

    if (!mounted) {
      return;
    }

    setState(() {
      _dailyRewardAvailable = true;
      _remainingTime = Duration.zero;
    });
  }

  // ============================================================
  // 🛑 إيقاف عداد اليوم
  // ============================================================

  void _stopDailyCountdown() {
    _dailyCountdownTimer?.cancel();
    _dailyCountdownTimer = null;
  }

  // ============================================================
  // 🕐 تنسيق الوقت
  // ============================================================

  String _formatRemainingTime(Duration duration) {
    final hours =
        duration.inHours
            .remainder(24)
            .toString()
            .padLeft(2, '0');

    final minutes =
        duration.inMinutes
            .remainder(60)
            .toString()
            .padLeft(2, '0');

    final seconds =
        duration.inSeconds
            .remainder(60)
            .toString()
            .padLeft(2, '0');

    return '$hours:$minutes:$seconds';
  }

  // ============================================================
  // 🧹 DISPOSE
  // ============================================================

  @override
  void dispose() {
    _rewardTimer?.cancel();
    _dailyCountdownTimer?.cancel();

    _boxController.dispose();
    _rewardController.dispose();
    _returnController.dispose();

    super.dispose();
  }

  // ============================================================
  // 📦 الضغط على الصندوق
  // ============================================================

  Future<void> _onBoxTap() async {
    if (_isOpen ||
        _isClaimed ||
        _isWatchingAd ||
        !_dailyRewardAvailable) {
      return;
    }

    try {
      final reward =
          await RewardManager.claimDailyReward();

      if (reward == null) {
        await _loadDailyRewardStatus();
        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _isOpen = true;
        _dailyRewardAvailable = false;
      });

      _stopDailyCountdown();

      // --------------------------------------------------------
      // فتح الصندوق
      // --------------------------------------------------------

      await Future.delayed(
        const Duration(
          milliseconds: 250,
        ),
      );

      if (!mounted) {
        return;
      }

      _startCountingReward();
    } catch (_) {}
  }

  // ============================================================
  // 🔢 عد المكافأة
  // ============================================================

  void _startCountingReward() {
    _rewardTimer?.cancel();

    int step = 0;

    _rewardTimer = Timer.periodic(
      const Duration(
        milliseconds: 45,
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
          _displayCoins =
              (_targetCoins * progress).round();

          _displayStars =
              (_targetStars * progress).round();

          _displayGems =
              (_targetGems * progress).round();
        });

        if (step >= 25) {
          timer.cancel();

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

  // ============================================================
  // 🎁 استلام المكافأة
  // ============================================================

  Future<void> _claimReward() async {
    if (_isClaimed || _isWatchingAd) {
      return;
    }

    _rewardTimer?.cancel();

    if (!mounted) {
      return;
    }

    setState(() {
      _isClaimed = true;
    });

    // ----------------------------------------------------------
    // تشغيل حركة المكافآت نحو المحفظة
    // ----------------------------------------------------------

    await _rewardController.forward();

    if (!mounted) {
      return;
    }

    // ----------------------------------------------------------
    // بدء عداد المكافأة التالية
    // ----------------------------------------------------------

    final now = DateTime.now();

    _startDailyCountdown(now);

    // ----------------------------------------------------------
    // رجوع الصندوق إلى أعلى اليسار
    // ----------------------------------------------------------

    await _returnController.forward();

    if (!mounted) {
      return;
    }

    // ----------------------------------------------------------
    // إغلاق النافذة
    // ----------------------------------------------------------

    widget.onRewardClaimed();

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  // ============================================================
  // 📺 مضاعفة المكافأة
  // ============================================================

  void _watchAdToDouble() {
    if (_isWatchingAd || _isClaimed) {
      return;
    }

    setState(() {
      _isWatchingAd = true;
    });

    AdsManager().showRewardedAd(
      onRewardEarned: () async {
        // ------------------------------------------------------
        // المكافأة الأساسية تمت إضافتها عند فتح الصندوق.
        //
        // هنا نضيف فقط النسخة الإضافية.
        // ------------------------------------------------------

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

          _isWatchingAd = false;
          _showRewardUI = false;
        });

        await Future.delayed(
          const Duration(
            milliseconds: 350,
          ),
        );

        if (!mounted) {
          return;
        }

        setState(() {
          _showRewardUI = true;
        });
      },
      onAdFailed: () {
        if (!mounted) {
          return;
        }

        setState(() {
          _isWatchingAd = false;
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

  // ============================================================
  // 📦 مكان الصندوق
  // ============================================================

  Widget _buildBox() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _boxController,
        _returnController,
      ]),
      builder: (
        context,
        child,
      ) {
        final double returnValue =
            _returnController.value;

        final Offset startPosition =
            _boxPosition.value;

        final Offset currentPosition =
            Offset.lerp(
              startPosition,
              const Offset(
                -1.15,
                -3.0,
              ),
              returnValue,
            ) ??
            startPosition;

        final double scale =
            Tween<double>(
          begin: _boxScale.value,
          end: 0.55,
        ).transform(returnValue);

        return FractionalTranslation(
          translation: currentPosition,
          child: Transform.scale(
            scale: scale,
            child: Transform.rotate(
              angle: _boxRotation.value,
              child: child,
            ),
          ),
        );
      },
      child: GestureDetector(
        onTap: _onBoxTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ----------------------------------------------------
            // 📦 الصندوق
            // ----------------------------------------------------

            SizedBox(
              width: 190,
              height: 190,
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
                      ? "assets/images/rewards/daly_box_open.png"
                      : "assets/images/rewards/daly_box_close.png",
                  key: ValueKey<bool>(
                    _isOpen,
                  ),
                  fit: BoxFit.contain,
                  errorBuilder: (
                    context,
                    error,
                    stack,
                  ) {
                    return Icon(
                      _isOpen
                          ? Icons.card_giftcard_rounded
                          : Icons.inventory_2_rounded,
                      color: Colors.amber,
                      size: 110,
                    );
                  },
                ),
              ),
            ),

            // ----------------------------------------------------
            // 👆 النص قبل الفتح
            // ----------------------------------------------------

            if (!_isOpen &&
                _dailyRewardAvailable)
              const Padding(
                padding: EdgeInsets.only(
                  top: 14,
                ),
                child: Text(
                  "انقر لفتح المكافأة اليومية",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            // ----------------------------------------------------
            // ⏱️ عداد المكافأة التالية
            // ----------------------------------------------------

            if (!_dailyRewardAvailable)
              _buildCountdown(),

            // ----------------------------------------------------
            // 🎁 متاحة الآن
            // ----------------------------------------------------

            if (_dailyRewardAvailable &&
                !_isOpen)
              const Padding(
                padding: EdgeInsets.only(
                  top: 8,
                ),
                child: Text(
                  "المكافأة متاحة الآن 🎁",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ⏱️ Widget العداد
  // ============================================================

  Widget _buildCountdown() {
    return Padding(
      padding: const EdgeInsets.only(
        top: 12,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: const Color(
            0xFF2A1B3D,
          ),
          borderRadius:
              BorderRadius.circular(
            14,
          ),
          border: Border.all(
            color: Colors.amber.withOpacity(
              0.75,
            ),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                0.35,
              ),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "المكافأة التالية بعد",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(
              height: 4,
            ),

            Text(
              _formatRemainingTime(
                _remainingTime,
              ),
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 🎁 لوحة المكافأة
  // ============================================================

  Widget _buildRewardPanel() {
    if (!_isOpen) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 20,
      right: 20,
      bottom: 80,
      child: AnimatedOpacity(
        opacity: _isOpen ? 1.0 : 0.0,
        duration: const Duration(
          milliseconds: 350,
        ),
        child: Container(
          padding: const EdgeInsets.all(
            18,
          ),
          decoration: BoxDecoration(
            color: const Color(
              0xFF2A1B3D,
            ),
            borderRadius:
                BorderRadius.circular(
              22,
            ),
            border: Border.all(
              color: Colors.amber,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  0.45,
                ),
                blurRadius: 18,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "مبروك! حصلت على مكافأتك",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 18,
              ),

              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly,
                children: [
                  _buildRewardItem(
                    "🪙",
                    _displayCoins,
                  ),
                  _buildRewardItem(
                    "⭐",
                    _displayStars,
                  ),
                  _buildRewardItem(
                    "💎",
                    _displayGems,
                  ),
                ],
              ),

              if (_showRewardUI) ...[
                const SizedBox(
                  height: 20,
                ),

                // ------------------------------------------------
                // استلام
                // ------------------------------------------------

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed:
                        _isWatchingAd
                            ? null
                            : _claimReward,
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.amber,
                      foregroundColor:
                          const Color(
                        0xFF1A0B2E,
                      ),
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 13,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                      ),
                    ),
                    child: const Text(
                      "استلام المكافأة",
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                // ------------------------------------------------
                // مضاعفة
                // ------------------------------------------------

                TextButton(
                  onPressed:
                      _isWatchingAd
                          ? null
                          : _watchAdToDouble,
                  child: Text(
                    _isWatchingAd
                        ? "جاري تحميل الإعلان..."
                        : "مضاعفة المكافأة عبر الفيديو 🎥",
                    style: const TextStyle(
                      color: Colors.amberAccent,
                      fontWeight:
                          FontWeight.w600,
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

  // ============================================================
  // 🪙 ⭐ 💎 عنصر المكافأة
  // ============================================================

  Widget _buildRewardItem(
    String icon,
    int value,
  ) {
    return Column(
      children: [
        Text(
          icon,
          style: const TextStyle(
            fontSize: 30,
          ),
        ),

        const SizedBox(
          height: 5,
        ),

        Text(
          "$value",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // 🚀 حركة المكافآت إلى المحفظة
  // ============================================================

  Widget _buildFlyingRewards() {
    if (!_isClaimed) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _rewardController,
      builder: (
        context,
        child,
      ) {
        final double value =
            Curves.easeInCubic.transform(
          _rewardController.value,
        );

        return Stack(
          children: [
            _flyingReward(
              icon: "🪙",
              begin: const Offset(
                0,
                0,
              ),
              end: const Offset(
                -0.85,
                1.9,
              ),
              value: value,
              delay: 0.0,
            ),

            _flyingReward(
              icon: "⭐",
              begin: const Offset(
                0,
                0,
              ),
              end: const Offset(
                -0.20,
                1.9,
              ),
              value: value,
              delay: 0.08,
            ),

            _flyingReward(
              icon: "💎",
              begin: const Offset(
                0,
                0,
              ),
              end: const Offset(
                0.45,
                1.9,
              ),
              value: value,
              delay: 0.16,
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // 🎯 حركة عنصر مكافأة واحد
  // ============================================================

  Widget _flyingReward({
    required String icon,
    required Offset begin,
    required Offset end,
    required double value,
    required double delay,
  }) {
    final double progress =
        ((value - delay) /
                (1 - delay))
            .clamp(
      0.0,
      1.0,
    );

    final curved =
        Curves.easeInOut.transform(
      progress,
    );

    final Offset position =
        Offset.lerp(
          begin,
          end,
          curved,
        ) ??
        begin;

    final double scale =
        1.0 -
        (curved * 0.45);

    final double opacity =
        progress < 0.8
            ? 1.0
            : 1.0 -
                ((progress - 0.8) / 0.2);

    return Align(
      alignment: Alignment.center,
      child: FractionalTranslation(
        translation: position,
        child: Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: Text(
              icon,
              style: const TextStyle(
                fontSize: 32,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // 🖥️ BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: SizedBox.expand(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ----------------------------------------------------
            // 🌑 الخلفية
            // ----------------------------------------------------

            Container(
              color: Colors.black.withOpacity(
                0.72,
              ),
            ),

            // ----------------------------------------------------
            // 📦 الصندوق + العداد
            // ----------------------------------------------------

            _buildBox(),

            // ----------------------------------------------------
            // 🎁 لوحة المكافأة
            // ----------------------------------------------------

            _buildRewardPanel(),

            // ----------------------------------------------------
            // 🚀 المكافآت الطائرة
            // ----------------------------------------------------

            if (_isClaimed)
              _buildFlyingRewards(),
          ],
        ),
      ),
    );
  }
}