import 'dart:async';
import 'package:flutter/material.dart';
import '../managers/daily_reward_manager.dart';
import '../../managers/ads_manager.dart';

class DailyRewardPopup extends StatefulWidget {
  final VoidCallback onRewardClaimed;

  const DailyRewardPopup({super.key, required this.onRewardClaimed});

  @override
  State<DailyRewardPopup> createState() => _DailyRewardPopupState();
}

class _DailyRewardPopupState extends State<DailyRewardPopup>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<Offset> _positionAnimation;

  bool _isOpen = false;
  bool _isClaimed = false;
  bool _showRewardUI = false;

  // أرقام المكافأة الوهمية
  int _displayCoins = 0;
  int _displayStars = 0;
  int _displayGems = 0;

  final int _targetCoins = 500;
  final int _targetStars = 10;
  final int _targetGems = 5;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
          tween: Tween<double>(begin: 0.0, end: 1.15)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 60),
      TweenSequenceItem(
          tween: Tween<double>(begin: 1.15, end: 1.0)
              .chain(CurveTween(curve: Curves.easeInOut)),
          weight: 40),
    ]).animate(_mainController);

    _rotationAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: Curves.easeInOutSine,
      ),
    );

    // حركة الانتقال من المنتصف إلى أعلى يسار الشاشة
    _positionAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1.2, -1.8),
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.7, 1.0, curve: Curves.easeInOutCubic),
    ));

    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  void _onBoxTap() async {
    if (_isOpen || _isClaimed) return;

    setState(() {
      _isOpen = true;
    });

    // بدء عداد زيادة الرصيد تدريجياً ببطء
    _startCountingReward();
  }

  void _startCountingReward() {
    const duration = Duration(milliseconds: 50);
    int step = 0;
    Timer.periodic(duration, (timer) {
      step++;
      setState(() {
        _displayCoins = (_targetCoins * (step / 30)).clamp(0, _targetCoins).toInt();
        _displayStars = (_targetStars * (step / 30)).clamp(0, _targetStars).toInt();
        _displayGems = (_targetGems * (step / 30)).clamp(0, _targetGems).toInt();
      });

      if (step >= 30) {
        timer.cancel();
        setState(() {
          _showRewardUI = true;
        });
      }
    });
  }

  void _claimReward({bool doubled = false}) async {
    await DailyRewardManager.saveClaimTime();
    setState(() {
      _isClaimed = true;
    });

    // تشغيل حركة الإغلاق والعودة للخلف
    _mainController.reverse().then((_) {
      widget.onRewardClaimed();
      Navigator.of(context).pop();
    });
  }

  void _watchAdToDouble() {
    AdsManager().showRewardedAd(
      onRewarded: () {
        setState(() {
          _displayCoins *= 2;
          _displayStars *= 2;
          _displayGems *= 2;
        });
        _claimReward(doubled: true);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // طبقة خلفية معتمة
          Container(
            color: Colors.black.withOpacity(0.7),
          ),
          
          // محتوى الصندوق والحركات
          SlideTransition(
            position: _positionAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: RotationTransition(
                turns: _rotationAnimation,
                child: GestureDetector(
                  onTap: _onBoxTap,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 220,
                        height: 220,
                        child: Image.asset(
                          _isOpen
                              ? 'assets/images/rewards/daly_box_open.png'
                              : 'assets/images/rewards/daly_box_close.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      if (!_isOpen)
                        const Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: Text(
                            'انقر لفتح الصندوق!',
                            style: TextStyle(
                              color: Colors.amber,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // واجهة المحفظة والزيادة التدريجية للعملات عند فتح الصندوق
          if (_isOpen)
            Positioned(
              bottom: 80,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 500),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Opacity(
                      opacity: value,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B2A3A),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.amber, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'مبروك! حصلت على مكافأتك اليومية',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildRewardItem('🪙', '$_displayCoins'),
                          _buildRewardItem('⭐', '$_displayStars'),
                          _buildRewardItem('💎', '$_displayGems'),
                        ],
                      ),
                      if (_showRewardUI) ...[
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => _claimReward(),
                          child: const Text(
                            'استلام المكافأة',
                            style: TextStyle(
                                color: Colors.black, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: _watchAdToDouble,
                          child: const Text(
                            'مضاعفة المكافأة عبر الفيديو 🎥',
                            style: TextStyle(color: Colors.amberAccent),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRewardItem(String emoji, String value) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 5),
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
}
