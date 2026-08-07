import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';
import '../managers/puzzle_progress_manager.dart';


class AdsManager {
  AdsManager._();

  static final AdsManager _instance = AdsManager._();

  factory AdsManager() => _instance;

  static const String _gameId = '800194786';

  static const String rewardedPlacementId = 'Rewarded_Android';
  static const String interstitialPlacementId = 'Interstitial_Android';
  static const String bannerPlacementId = 'Banner_Android';

  static const bool testMode = true;

  bool _initialized = false;

  bool get isInitialized => _initialized;

  bool _isShowing = false;

  bool get isShowing => _isShowing;

  bool _rewardedReady = false;
  bool _interstitialReady = false;
  bool _bannerReady = false;

  Future<void> initAds() async {

    if (_initialized) return;

    final completer = Completer<void>();

    UnityAds.init(
      gameId: _gameId,
      testMode: testMode,

      onComplete: () {
        _initialized = true;
        debugPrint('✅ Unity Ads initialized');
        loadAds();
        completer.complete();
      },

      onFailed: (error, message) {
        debugPrint('❌ Unity Ads init failed: $message');
        completer.complete();
      },
    );

    return completer.future;
  }

  void loadAds() {

    UnityAds.load(
      placementId: rewardedPlacementId,
      onComplete: (placementId) {
        _rewardedReady = true;
      },
      onFailed: (placementId, error, message) {
        debugPrint("Rewarded failed: $message");
      },
    );


    UnityAds.load(
      placementId: interstitialPlacementId,
      onComplete: (placementId) {
        _interstitialReady = true;
      },
      onFailed: (placementId, error, message) {
        debugPrint("Interstitial failed: $message");
      },
    );

  }

  void showRewardedAd({
    required VoidCallback onRewardEarned,
    VoidCallback? onAdFailed,
  }) {

    if (!_initialized || !_rewardedReady) {
      onAdFailed?.call();
      return;
    }

    if (_isShowing) {
      onAdFailed?.call();
      return;
    }

    _isShowing = true;

    UnityAds.showVideoAd(
      placementId: rewardedPlacementId,

      onComplete: (_) async {

  _isShowing = false;
  _rewardedReady = false;
  loadAds();

  // إضافة مشاهدة واحدة إلى الرصيد العام
  await PuzzleProgressManager.addAdsBalance(1);

  onRewardEarned();

},

      onFailed: (_, __, ___) {

        _isShowing = false;
        _rewardedReady = false;

        loadAds();

        onAdFailed?.call();

      },
    );
  }

  void showInterstitialAd({
    required VoidCallback onAdClosed,
  }) {

    if (!_initialized || !_interstitialReady) {
      onAdClosed();
      return;
    }

    if (_isShowing) {
      onAdClosed();
      return;
    }

    _isShowing = true;

    UnityAds.showVideoAd(
      placementId: interstitialPlacementId,

      onComplete: (_) {

        _isShowing = false;
        _interstitialReady = false;
        loadAds();

        onAdClosed();

      },

      onFailed: (_, __, ___) {

        _isShowing = false;
        _interstitialReady = false;

        loadAds();

        onAdClosed();

      },

    );
  }

  Widget banner() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: UnityBannerAd(
        placementId: bannerPlacementId,
      ),
    );
  }
}
