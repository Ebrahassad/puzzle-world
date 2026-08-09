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
  // ⏱️ Timer العد
  // ============================================================

  Timer? _rewardTimer;

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

    _boxController.forward();
  }

  // ============================================================
  // 🧹 DISPOSE
  // ============================================================

  @override
  void dispose() {
    _rewardTimer?.cancel();

    _boxController.dispose();
    _rewardController.dispose();
    _returnController.dispose();

    super.dispose();
  }

  // ============================================================
  // 📦 الضغط على الصندوق
  // ============================================================

  Future<void> _onBoxTap() async {
    if (_isOpen || _isClaimed || _isWatchingAd) {
      return;
    }

    try {
      final reward = await RewardManager.claimDailyReward();

      if (reward == null) {
        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _isOpen = true;
      });

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

        final progress = (step / 25).clamp(
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
    // رجوع الصندوق إلى مكانه أعلى الشاشة
    // ----------------------------------------------------------

    await _returnController.forward();

    if (!mounted) {
      return;
    }

    // ----------------------------------------------------------
    // إغلاق النافذة وإظهار الصندوق المصغر في WorldMapScreen
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
        // لا نستدعي claimDailyReward مرة أخرى.
        //
        // المكافأة الأساسية تم استلامها بالفعل عند فتح الصندوق.
        // هنا نضيف فقط المكافأة الإضافية.
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
          _displayCoins = _targetCoins * 2;
          _displayStars = _targetStars * 2;
          _displayGems = _targetGems * 2;
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
              "الإعلان غير متوفر حالياً",
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

        final Offset currentPosition = Offset.lerp(
              startPosition,
              const Offset(
                -1.15,
                -3.0,
              ),
              returnValue,
            ) ??
            startPosition;

        final double scale = Tween<double>(
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
            // النص قبل الفتح
            // ----------------------------------------------------

            if (!_isOpen)
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
            borderRadius: BorderRadius.circular(
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
                        _isWatchingAd ? null : _claimReward,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
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

  Widget _flyingReward({
    required String icon,
    required Offset begin,
    required Offset end,
    required double value,
    required double delay,
  }) {
    final double progress =
        ((value - delay) / (1 - delay))
            .clamp(0.0, 1.0);

    final curved =
        Curves.easeInOut.transform(
      progress,
    );

    final Offset position = Offset.lerp(
          begin,
          end,
          curved,
        ) ??
        begin;

    final double scale =
        1.0 - (curved * 0.45);

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
            // خلفية
            // ----------------------------------------------------

            Container(
              color: Colors.black.withOpacity(
                0.72,
              ),
            ),

            // ----------------------------------------------------
            // الصندوق
            // ----------------------------------------------------

            _buildBox(),

            // ----------------------------------------------------
            // لوحة المكافأة
            // ----------------------------------------------------

            _buildRewardPanel(),

            // ----------------------------------------------------
            // المكافآت الطائرة
            // ----------------------------------------------------

            if (_isClaimed)
              _buildFlyingRewards(),
          ],
        ),
      ),
    );
  }
}