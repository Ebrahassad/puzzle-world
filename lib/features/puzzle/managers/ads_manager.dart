import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class AdsManager {
  AdsManager._();

  static final AdsManager _instance = AdsManager._();

  factory AdsManager() => _instance;

  static const String _gameId = '80019478';

  static const String rewardedPlacementId = 'Rewarded_Android';
  static const String interstitialPlacementId = 'Interstitial_Android';
  static const String bannerPlacementId = 'Banner_Android';

  static const bool testMode = true;

  bool _initialized = false;

  bool get isInitialized => _initialized;

  bool _isShowing = false;

  bool get isShowing => _isShowing;

  Future<void> initAds() async {

    if (_initialized) return;

    final completer = Completer<void>();

    UnityAds.init(
      gameId: _gameId,
      testMode: testMode,

      onComplete: () {
        _initialized = true;
        debugPrint('✅ Unity Ads initialized');
        completer.complete();
      },

      onFailed: (error, message) {
        debugPrint('❌ Unity Ads init failed: $message');
        completer.complete();
      },
    );

    return completer.future;
  }

  void showRewardedAd({
    required VoidCallback onRewardEarned,
    VoidCallback? onAdFailed,
  }) {

    if (!_initialized) {
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

      onComplete: (_) {

        _isShowing = false;

        onRewardEarned();

      },

      onFailed: (_, __, ___) {

        _isShowing = false;

        onAdFailed?.call();

      },
    );
  }

  void showInterstitialAd({
    required VoidCallback onAdClosed,
  }) {

    if (!_initialized) {
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

        onAdClosed();

      },

      onFailed: (_, __, ___) {

        _isShowing = false;

        onAdClosed();

      },

    );
  }

  Widget getBannerAd() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: UnityBannerAd(
        placementId: bannerPlacementId,
      ),
    );
  }
}
