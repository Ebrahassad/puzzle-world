import 'dart:async';
import 'package:flutter/material.dart';
import '../managers/reward_manager.dart';
import '../managers/ads_manager.dart';

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

  int _displayCoins = 0;
  int _displayStars = 0;
  int _displayGems = 0;

  final int _targetCoins = 100;
  final int _targetStars = 1;
  final int _targetGems = 1;

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

    // حركة تبدأ من أسفل اليسار (مكان المحفظة أو الصندوق) إلى منتصف الشاشة
    _positionAnimation = Tween<Offset>(
      begin: const Offset(-2.0, 2.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 1.0, curve: Curves.easeInOutCubic),
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

    // استدعاء دالة المطالبة بالمكافأة اليومية من مدير المكافآت الموجود لديك
    final reward = await RewardManager.claimDailyReward();
    if (reward == null) return;

    setState(() {
      _isOpen = true;
    });

    _startCountingReward();
  }

  void _startCountingReward() {
    const duration = Duration(milliseconds: 50);
    int step = 0;
    Timer.periodic(duration, (timer) {
      step++;
      setState(() {
        _displayCoins = (_targetCoins * (step / 20)).clamp(0, _targetCoins).toInt();
        _displayStars = (_targetStars * (step / 20)).clamp(0, _targetStars).toInt();
        _displayGems = (_targetGems * (step / 20)).clamp(0, _targetGems).toInt();
      });

      if (step >= 20) {
        timer.cancel();
        setState(() {
          _showRewardUI = true;
        });
      }
    });
  }

  void _claimReward() {
    setState(() {
      _isClaimed = true;
    });

    _mainController.reverse().then((_) {
      widget.onRewardClaimed();
      Navigator.of(context).pop();
    });
  }

  void _watchAdToDouble() {
    AdsManager().showRewardedAd(
      onRewardEarned: () async {
        // مضاعفة المكافأة عبر RewardManager
        final currentReward = await RewardManager.getReward();
        // أو مضاعفة القيم المعروضة مباشرة وإضافتها
        setState(() {
          _displayCoins *= 2;
          _displayStars *= 2;
          _displayGems *= 2;
        });
        
        await RewardManager.addCoins(_targetCoins);
        await RewardManager.addGems(_targetGems);
        await RewardManager.addStars(_targetStars);

        _claimReward();
      },
      onAdFailed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("الإعلان غير متوفر حالياً")),
        );
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
          Container(
            color: Colors.black.withOpacity(0.7),
          ),
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
                        width: 200,
                        height: 200,
                        child: Image.asset(
                          _isOpen
                              ? 'assets/images/ui/open_wallet.png'
                              : 'assets/images/ui/close_wallet.png',
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Icon(
                            _isOpen ? Icons.lock_open : Icons.lock,
                            size: 100,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                      if (!_isOpen)
                        const Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: Text(
                            'انقر لفتح المحفظة والمكافأة!',
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
          if (_isOpen)
            Positioned(
              bottom: 100,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 400),
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
                    color: const Color(0xFF2A1B3D),
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
                        'مبروك! حصلت على مكافأتك',
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
                          onPressed: _claimReward,
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
