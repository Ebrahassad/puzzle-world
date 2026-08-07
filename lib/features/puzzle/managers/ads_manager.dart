import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

import '../managers/puzzle_progress_manager.dart';

class AdsManager {
  AdsManager._();

  static final AdsManager _instance = AdsManager._();

  factory AdsManager() => _instance;

  //==================================================
  // 🎮 Unity Ads
  //==================================================

  static const String _gameId = '800194786';

  static const String rewardedPlacementId =
      'Rewarded_Android';

  static const String interstitialPlacementId =
      'Interstitial_Android';

  static const String bannerPlacementId =
      'Banner_Android';

  static const bool testMode = true;

  //==================================================
  // ⚙️ الحالة
  //==================================================

  bool _initialized = false;

  bool get isInitialized => _initialized;

  bool _isShowing = false;

  bool get isShowing => _isShowing;

  bool _rewardedReady = false;

  bool _interstitialReady = false;

  //==================================================
  // 🚀 تهيئة الإعلانات
  //==================================================

  Future<void> initAds() async {
    if (_initialized) {
      return;
    }

    final completer = Completer<void>();

    UnityAds.init(
      gameId: _gameId,
      testMode: testMode,

      onComplete: () {
        _initialized = true;

        debugPrint(
          '✅ Unity Ads initialized',
        );

        loadAds();

        if (!completer.isCompleted) {
          completer.complete();
        }
      },

      onFailed: (error, message) {
        debugPrint(
          '❌ Unity Ads init failed: $message',
        );

        if (!completer.isCompleted) {
          completer.complete();
        }
      },
    );

    return completer.future;
  }

  //==================================================
  // 📦 تحميل الإعلانات
  //==================================================

  void loadAds() {
    // Rewarded
    UnityAds.load(
      placementId: rewardedPlacementId,

      onComplete: (placementId) {
        _rewardedReady = true;

        debugPrint(
          '✅ Rewarded ad ready',
        );
      },

      onFailed: (
        placementId,
        error,
        message,
      ) {
        _rewardedReady = false;

        debugPrint(
          '❌ Rewarded ad failed: $message',
        );
      },
    );

    // Interstitial
    UnityAds.load(
      placementId: interstitialPlacementId,

      onComplete: (placementId) {
        _interstitialReady = true;

        debugPrint(
          '✅ Interstitial ad ready',
        );
      },

      onFailed: (
        placementId,
        error,
        message,
      ) {
        _interstitialReady = false;

        debugPrint(
          '❌ Interstitial ad failed: $message',
        );
      },
    );
  }

  //==================================================
  // 📺 الإعلان المكافئ
  //
  // كل إعلان مكتمل = مشاهدة واحدة فقط
  // لا يفتح مرحلة أو جزيرة مباشرة.
  //
  // المشاهدة تذهب إلى:
  // PuzzleProgressManager.adsBalance
  //
  // ثم يستخدمها المتجر لشراء:
  // 🪙 العملات
  // ⭐ النجوم
  // 💎 الجواهر
  //==================================================

  void showRewardedAd({
    required VoidCallback onRewardEarned,
    VoidCallback? onAdFailed,
  }) {
    if (!_initialized) {
      onAdFailed?.call();
      return;
    }

    if (!_rewardedReady) {
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
        // منع تكرار المكافأة
        _isShowing = false;
        _rewardedReady = false;

        // إعادة تحميل إعلان جديد
        loadAds();

        // مشاهدة واحدة فقط
        await PuzzleProgressManager.addAdsBalance(1);

        debugPrint(
          '📺 +1 ad balance',
        );

        // إبلاغ الشاشة أن المكافأة وصلت
        onRewardEarned();
      },

      onFailed: (_, __, ___) {
        _isShowing = false;
        _rewardedReady = false;

        loadAds();

        debugPrint(
          '❌ Rewarded ad failed',
        );

        onAdFailed?.call();
      },
    );
  }

  //==================================================
  // 📺 إعلان Interstitial
  //
  // لا يمنح أي عملة أو مشاهدة.
  //==================================================

  void showInterstitialAd({
    required VoidCallback onAdClosed,
  }) {
    if (!_initialized) {
      onAdClosed();
      return;
    }

    if (!_interstitialReady) {
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

  //==================================================
  // 📢 Banner
  //==================================================

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