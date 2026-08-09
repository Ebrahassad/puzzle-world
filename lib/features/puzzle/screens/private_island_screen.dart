import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'puzzle_game_screen.dart';
import '../managers/ads_manager.dart';

/// ============================================================
/// 🏝️ Private Island Screen
///
/// الجزيرة الغامضة.
///
/// الوظيفة الوحيدة للشاشة:
///
/// 1. فتح معرض الصور.
/// 2. اختيار صورة من الجهاز.
/// 3. اختيار درجة صعوبة اللغز.
/// 4. الانتقال مباشرة إلى PuzzleGameScreen.
///
/// جميع درجات الصعوبة متاحة مباشرة.
/// لا توجد مستويات مقفلة أو مربعات مستويات.
/// ============================================================

class PrivateIslandScreen extends StatefulWidget {
  const PrivateIslandScreen({
    super.key,
  });

  @override
  State<PrivateIslandScreen> createState() =>
      _PrivateIslandScreenState();
}

class _PrivateIslandScreenState
    extends State<PrivateIslandScreen>
    with TickerProviderStateMixin {
  // ============================================================
  // 🎞️ Animation
  // ============================================================

  late final AnimationController _floatingController;

  late final Animation<double> _floatingAnimation;

  // ============================================================
  // 🖼️ Image Picker
  // ============================================================

  final ImagePicker _imagePicker = ImagePicker();

  bool _isPicking = false;

  // ============================================================
  // 🚀 INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 3,
      ),
    )..repeat(
        reverse: true,
      );

    _floatingAnimation = Tween<double>(
      begin: -8.0,
      end: 8.0,
    ).animate(
      CurvedAnimation(
        parent: _floatingController,
        curve: Curves.easeInOut,
      ),
    );
  }

  // ============================================================
  // 🧹 DISPOSE
  // ============================================================

  @override
  void dispose() {
    _floatingController.dispose();

    super.dispose();
  }

  // ============================================================
  // 🖼️ فتح استوديو الصور
  // ============================================================
  //
  // الإعلان اختياري:
  //
  // إذا كان Rewarded جاهزًا:
  //     → يظهر الإعلان
  //     → بعد انتهاء الإعلان يفتح الاستوديو.
  //
  // إذا لم يكن جاهزًا:
  //     → يفتح الاستوديو مباشرة.
  //
  // الإعلان لا يمنع دخول المستخدم للاستوديو.
  // ============================================================

  Future<void> _openImageStudio() async {
    if (_isPicking) {
      return;
    }

    setState(() {
      _isPicking = true;
    });

    bool studioOpened = false;

    Future<void> openStudio() async {
      if (studioOpened || !mounted) {
        return;
      }

      studioOpened = true;

      setState(() {
        _isPicking = false;
      });

      try {
        // ======================================================
        // 🖼️ اختيار الصورة
        // ======================================================

        final XFile? picked =
            await _imagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 90,
        );

        if (!mounted) {
          return;
        }

        // المستخدم ألغى اختيار الصورة
        if (picked == null) {
          return;
        }

        // ======================================================
        // 🎯 اختيار الصعوبة
        // ======================================================

        final int? gridSize =
            await _showDifficultyDialog();

        if (!mounted) {
          return;
        }

        if (gridSize == null) {
          return;
        }

        // ======================================================
        // 🧩 الانتقال مباشرة إلى لعبة البازل
        // ======================================================

        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PuzzleGameScreen(
              customImagePath: picked.path,
              isCustomImage: true,
              customGridSize: gridSize,
            ),
          ),
        );
      } catch (_) {
        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'تعذر اختيار الصورة. حاول مرة أخرى.',
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }

    try {
      // ========================================================
      // 📺 محاولة تشغيل إعلان مكافأة
      //
      // الإعلان اختياري بالكامل.
      // ========================================================

      AdsManager().showRewardedAd(
        onRewardEarned: () {
          openStudio();
        },
        onAdFailed: () {
          openStudio();
        },
      );
    } catch (_) {
      // ========================================================
      // إذا حدث أي خطأ في الإعلانات:
      // نفتح الاستوديو مباشرة.
      // ========================================================

      await openStudio();
    }
  }

  // ============================================================
  // 🎯 نافذة اختيار الصعوبة
  // ============================================================

  Future<int?> _showDifficultyDialog() {
    return showDialog<int>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor:
              const Color(0xFF1B2A3A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 28,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ==================================================
                // العنوان
                // ==================================================

                const Text(
                  'اختر مستوى الصعوبة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                Text(
                  'اختر عدد قطع البازل',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),

                const SizedBox(
                  height: 24,
                ),

                // ==================================================
                // 🟢 سهل
                // ==================================================

                _DifficultyOption(
                  label: 'سهل',
                  subtitle: '4×4 • 16 قطعة',
                  icon: Icons.sentiment_satisfied_alt,
                  color: const Color(0xFF4CAF7D),
                  onTap: () {
                    Navigator.of(dialogContext).pop(4);
                  },
                ),

                const SizedBox(
                  height: 12,
                ),

                // ==================================================
                // 🟡 متوسط
                // ==================================================

                _DifficultyOption(
                  label: 'متوسط',
                  subtitle: '6×6 • 36 قطعة',
                  icon: Icons.extension,
                  color: const Color(0xFFE0A63A),
                  onTap: () {
                    Navigator.of(dialogContext).pop(6);
                  },
                ),

                const SizedBox(
                  height: 12,
                ),

                // ==================================================
                // 🔴 خبير
                // ==================================================

                _DifficultyOption(
                  label: 'خبير',
                  subtitle: '8×8 • 64 قطعة',
                  icon: Icons.local_fire_department,
                  color: const Color(0xFFD9534F),
                  onTap: () {
                    Navigator.of(dialogContext).pop(8);
                  },
                ),

                const SizedBox(
                  height: 16,
                ),

                // ==================================================
                // إلغاء
                // ==================================================

                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text(
                    'إلغاء',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // 🏗️ BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            // ======================================================
            // 🌌 الخلفية
            // ======================================================

            Positioned.fill(
              child: Image.asset(
                'assets/images/background/'
                'private_bacgraund.png',
                fit: BoxFit.cover,
                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {
                  return Container(
                    color: const Color(0xFF0D1B2A),
                  );
                },
              ),
            ),

            // ======================================================
            // 🌑 طبقة تعتيم
            // ======================================================

            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.35),
              ),
            ),

            // ======================================================
            // 🏝️ الجزيرة العائمة
            // ======================================================

            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 90,
                ),
                child: AnimatedBuilder(
                  animation: _floatingAnimation,
                  builder: (
                    context,
                    child,
                  ) {
                    return Transform.translate(
                      offset: Offset(
                        0,
                        _floatingAnimation.value,
                      ),
                      child: child,
                    );
                  },
                  child: SizedBox(
                    width: 180,
                    height: 180,
                    child: Image.asset(
                      'assets/images/islands/'
                      'private_island.png',
                      fit: BoxFit.contain,
                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return const Icon(
                          Icons.landscape,
                          color: Colors.white70,
                          size: 80,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            // ======================================================
            // 📱 المحتوى
            // ======================================================

            SafeArea(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  // ==================================================
                  // 🏷️ الشريط العلوي
                  // ==================================================

                  _buildHeaderBar(context),

                  const Spacer(
                    flex: 1,
                  ),

                  // ==================================================
                  // 🖼️ بطاقة الاستوديو
                  // ==================================================

                  Padding(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: _buildStudioCard(),
                  ),

                  const Spacer(
                    flex: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 🏷️ الشريط العلوي
  // ============================================================

  Widget _buildHeaderBar(
    BuildContext context,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        0,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF2E1A47),
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFB8860B),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // ======================================================
          // 📷 أيقونة الصورة
          // ======================================================

          SizedBox(
            width: 32,
            height: 32,
            child: Image.asset(
              'assets/images/ui/add_pic.png',
              fit: BoxFit.contain,
              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return const Icon(
                  Icons.add_photo_alternate,
                  color: Colors.white,
                  size: 28,
                );
              },
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          // ======================================================
          // 🏝️ العنوان
          // ======================================================

          const Expanded(
            child: Text(
              'الجزيرة الغامضة',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          // ======================================================
          // ↩️ الرجوع
          // ======================================================

          IconButton(
            onPressed: () {
              Navigator.of(context).maybePop();
            },
            icon: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white70,
              size: 20,
            ),
            constraints:
                const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🖼️ بطاقة استوديو الصور
  // ============================================================

  Widget _buildStudioCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(24),
        gradient:
            const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1B3A57),
            Color(0xFF12293F),
          ],
        ),
        border: Border.all(
          color:
              Colors.white.withOpacity(0.12),
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.45),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // ======================================================
          // 📷 العنوان
          // ======================================================

          const Text(
            'استوديو الصور',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(
            height: 6,
          ),

          // ======================================================
          // الوصف
          // ======================================================

          Text(
            'اختر صورة من جهازك وحوّلها إلى لغز تفاعلي',
            textAlign: TextAlign.center,
            style: TextStyle(
              color:
                  Colors.white.withOpacity(0.7),
              fontSize: 13,
            ),
          ),

          const SizedBox(
            height: 18,
          ),

          // ======================================================
          // 🚀 زر فتح الاستوديو
          // ======================================================

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isPicking
                  ? null
                  : _openImageStudio,
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFFE0A63A),
                disabledBackgroundColor:
                    const Color(0xFFE0A63A)
                        .withOpacity(0.5),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: _isPicking
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'افتح الاستوديو',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 🎯 خيار الصعوبة
// ============================================================================

class _DifficultyOption
    extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DifficultyOption({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(14),
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color:
              Colors.white.withOpacity(0.04),
          borderRadius:
              BorderRadius.circular(14),
          border: Border.all(
            color:
                Colors.white.withOpacity(0.08),
          ),
        ),
        child: Row(
          children: [
            // ====================================================
            // 🎯 الأيقونة
            // ====================================================

            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    color.withOpacity(0.18),
              ),
              child: Icon(
                icon,
                color: color,
                size: 18,
              ),
            ),

            const SizedBox(
              width: 12,
            ),

            // ====================================================
            // 🏷️ اسم الصعوبة
            // ====================================================

            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),

            // ====================================================
            // 🔢 عدد القطع
            // ====================================================

            Text(
              subtitle,
              style: TextStyle(
                color:
                    Colors.white.withOpacity(0.5),
                fontSize: 13,
                fontWeight:
                    FontWeight.w500,
              ),
            ),

            const SizedBox(
              width: 6,
            ),

            const Icon(
              Icons.arrow_back_ios,
              color: Colors.white30,
              size: 12,
            ),
          ],
        ),
      ),
    );
  }
}