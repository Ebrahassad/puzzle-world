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

  bool get isRewardedReady => _rewardedReady;

  bool _interstitialReady = false;

  bool get isInterstitialReady => _interstitialReady;

  //==================================================
  // 🔄 إعادة تحميل الإعلانات
  //==================================================

  Timer? _rewardedRetryTimer;

  Timer? _interstitialRetryTimer;

  bool _rewardedLoading = false;

  bool _interstitialLoading = false;

  int _rewardedRetryCount = 0;

  int _interstitialRetryCount = 0;

  //==================================================
  // ⏱️ أوقات إعادة المحاولة
  //
  // المحاولة الأولى بعد 3 ثوانٍ
  // ثم 5
  // ثم 10
  // ثم 20
  // ثم 30 كحد أقصى
  //==================================================

  Duration _retryDelay(int retryCount) {
    switch (retryCount) {
      case 0:
        return const Duration(seconds: 3);

      case 1:
        return const Duration(seconds: 5);

      case 2:
        return const Duration(seconds: 10);

      case 3:
        return const Duration(seconds: 20);

      default:
        return const Duration(seconds: 30);
    }
  }

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

        // بدء تحميل الإعلانات في الخلفية
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
  //
  // يتم تشغيله مرة واحدة ثم يتولى النظام
  // إعادة المحاولة تلقائيًا عند الفشل.
  //==================================================

  void loadAds() {
    if (!_initialized) {
      return;
    }

    _loadRewardedAd();
    _loadInterstitialAd();
  }

  //==================================================
  // 📺 تحميل Rewarded
  //==================================================

  void _loadRewardedAd() {
    if (!_initialized) {
      return;
    }

    if (_rewardedReady) {
      return;
    }

    if (_rewardedLoading) {
      return;
    }

    _rewardedLoading = true;

    debugPrint(
      '📥 Loading Rewarded ad...',
    );

    UnityAds.load(
      placementId: rewardedPlacementId,

      onComplete: (placementId) {
        _rewardedLoading = false;

        _rewardedReady = true;

        _rewardedRetryCount = 0;

        _rewardedRetryTimer?.cancel();
        _rewardedRetryTimer = null;

        debugPrint(
          '✅ Rewarded ad ready',
        );
      },

      onFailed: (
        placementId,
        error,
        message,
      ) {
        _rewardedLoading = false;

        _rewardedReady = false;

        debugPrint(
          '❌ Rewarded ad failed: $message',
        );

        _scheduleRewardedRetry();
      },
    );
  }

  //==================================================
  // 🔄 إعادة محاولة Rewarded
  //==================================================

  void _scheduleRewardedRetry() {
    if (!_initialized) {
      return;
    }

    if (_rewardedReady) {
      return;
    }

    if (_rewardedLoading) {
      return;
    }

    if (_rewardedRetryTimer != null) {
      return;
    }

    final Duration delay =
        _retryDelay(_rewardedRetryCount);

    debugPrint(
      '🔄 Rewarded retry in ${delay.inSeconds}s',
    );

    _rewardedRetryTimer = Timer(
      delay,
      () {
        _rewardedRetryTimer = null;

        _rewardedRetryCount++;

        _loadRewardedAd();
      },
    );
  }

  //==================================================
  // 📺 تحميل Interstitial
  //==================================================

  void _loadInterstitialAd() {
    if (!_initialized) {
      return;
    }

    if (_interstitialReady) {
      return;
    }

    if (_interstitialLoading) {
      return;
    }

    _interstitialLoading = true;

    debugPrint(
      '📥 Loading Interstitial ad...',
    );

    UnityAds.load(
      placementId: interstitialPlacementId,

      onComplete: (placementId) {
        _interstitialLoading = false;

        _interstitialReady = true;

        _interstitialRetryCount = 0;

        _interstitialRetryTimer?.cancel();
        _interstitialRetryTimer = null;

        debugPrint(
          '✅ Interstitial ad ready',
        );
      },

      onFailed: (
        placementId,
        error,
        message,
      ) {
        _interstitialLoading = false;

        _interstitialReady = false;

        debugPrint(
          '❌ Interstitial ad failed: $message',
        );

        _scheduleInterstitialRetry();
      },
    );
  }

  //==================================================
  // 🔄 إعادة محاولة Interstitial
  //==================================================

  void _scheduleInterstitialRetry() {
    if (!_initialized) {
      return;
    }

    if (_interstitialReady) {
      return;
    }

    if (_interstitialLoading) {
      return;
    }

    if (_interstitialRetryTimer != null) {
      return;
    }

    final Duration delay =
        _retryDelay(_interstitialRetryCount);

    debugPrint(
      '🔄 Interstitial retry in ${delay.inSeconds}s',
    );

    _interstitialRetryTimer = Timer(
      delay,
      () {
        _interstitialRetryTimer = null;

        _interstitialRetryCount++;

        _loadInterstitialAd();
      },
    );
  }

  //==================================================
  // 📺 الإعلان المكافئ
  //
  // إذا كان جاهزًا:
  //     يظهر الإعلان.
  //
  // إذا لم يكن جاهزًا:
  //     onAdFailed يعمل مباشرة.
  //
  // لا يتم انتظار الإعلان.
  //==================================================

  void showRewardedAd({
    required VoidCallback onRewardEarned,
    VoidCallback? onAdFailed,
  }) {
    if (!_initialized) {
      onAdFailed?.call();

      // نحاول تحميله في الخلفية
      _loadRewardedAd();

      return;
    }

    if (!_rewardedReady) {
      onAdFailed?.call();

      // يبدأ التحميل في الخلفية إذا لم يكن هناك تحميل حالي
      _loadRewardedAd();

      return;
    }

    if (_isShowing) {
      onAdFailed?.call();
      return;
    }

    _isShowing = true;

    _rewardedReady = false;

    UnityAds.showVideoAd(
      placementId: rewardedPlacementId,

      onComplete: (_) async {
        _isShowing = false;

        debugPrint(
          '✅ Rewarded ad completed',
        );

        // تسجيل المشاهدة
        await PuzzleProgressManager.addAdsBalance(1);

        debugPrint(
          '📺 +1 ad balance',
        );

        // إبلاغ الشاشة بالمكافأة
        onRewardEarned();

        // تحميل إعلان جديد في الخلفية
        _loadRewardedAd();
      },

      onFailed: (_, __, ___) {
        _isShowing = false;

        debugPrint(
          '❌ Rewarded ad failed while showing',
        );

        // تحميل إعلان جديد في الخلفية
        _loadRewardedAd();

        onAdFailed?.call();
      },
    );
  }

  //==================================================
  // 📺 إعلان Interstitial
  //==================================================

  void showInterstitialAd({
    required VoidCallback onAdClosed,
  }) {
    if (!_initialized) {
      onAdClosed();

      _loadInterstitialAd();

      return;
    }

    if (!_interstitialReady) {
      onAdClosed();

      _loadInterstitialAd();

      return;
    }

    if (_isShowing) {
      onAdClosed();
      return;
    }

    _isShowing = true;

    _interstitialReady = false;

    UnityAds.showVideoAd(
      placementId: interstitialPlacementId,

      onComplete: (_) {
        _isShowing = false;

        debugPrint(
          '✅ Interstitial completed',
        );

        // تحميل إعلان جديد في الخلفية
        _loadInterstitialAd();

        onAdClosed();
      },

      onFailed: (_, __, ___) {
        _isShowing = false;

        debugPrint(
          '❌ Interstitial failed',
        );

        // إعادة التحميل في الخلفية
        _loadInterstitialAd();

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