import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'puzzle_game_screen.dart';
import '../managers/ads_manager.dart';

/// شاشة "الجزيرة الغامضة".
///
/// تسمح للمستخدم باختيار صورة من الجهاز وتحويلها إلى
/// Puzzle قابل للعب بدرجة الصعوبة التي يختارها.
class PrivateIslandScreen extends StatefulWidget {
  const PrivateIslandScreen({super.key});

  @override
  State<PrivateIslandScreen> createState() => _PrivateIslandScreenState();
}

class _PrivateIslandScreenState extends State<PrivateIslandScreen>
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
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

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

  Future<void> _openImageStudio() async {
    if (_isPicking) return;

    setState(() {
      _isPicking = true;
    });

    try {
      // ============================================================
      // 📺 محاولة تشغيل إعلان مكافأة
      //
      // إذا كان الإعلان جاهزًا:
      //     → يظهر الإعلان
      //     → بعد اكتماله يفتح الاستوديو
      //
      // إذا لم يكن جاهزًا أو حدث خطأ:
      //     → يفتح الاستوديو مباشرة
      //
      // الإعلان لا يمنع المستخدم من دخول الاستوديو بأي حال.
      // ============================================================

      bool studioOpened = false;

      Future<void> openStudio() async {
        if (studioOpened || !mounted) return;

        studioOpened = true;

        setState(() {
          _isPicking = false;
        });

        final XFile? picked = await _imagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 90,
        );

        if (!mounted) return;

        if (picked == null) {
          return;
        }

        final int? gridSize = await _showDifficultyDialog();

        if (!mounted || gridSize == null) {
          return;
        }

        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PuzzleGameScreen(
              customImagePath: picked.path,
              isCustomImage: true,
              customGridSize: gridSize,
            ),
          ),
        );
      }

      AdsManager().showRewardedAd(
        // الإعلان اكتمل بنجاح
        onRewardEarned: () {
          openStudio();
        },

        // الإعلان غير جاهز أو فشل
        // لا ننتظر الإعلان، ندخل الاستوديو مباشرة
        onAdFailed: () {
          openStudio();
        },
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isPicking = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'تعذر فتح الاستوديو. حاول مرة أخرى.',
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // 🎯 نافذة اختيار الصعوبة (تتضمن مستوى الخبير المخصص)
  // ============================================================

  Future<int?> _showDifficultyDialog() {
    return showDialog<int>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: const Color(0xFF1B2A3A),
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
                const Text(
                  'اختر مستوى الصعوبة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'حدد حجم الشبكة التي تريد اللعب بها',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 24),
                _DifficultyOption(
                  label: 'سهل',
                  subtitle: '4×4 (16 قطعة)',
                  icon: Icons.sentiment_satisfied_alt,
                  color: const Color(0xFF4CAF7D),
                  onTap: () => Navigator.of(dialogContext).pop(4),
                ),
                const SizedBox(height: 12),
                _DifficultyOption(
                  label: 'متوسط',
                  subtitle: '6×6 (36 قطعة)',
                  icon: Icons.extension,
                  color: const Color(0xFFE0A63A),
                  onTap: () => Navigator.of(dialogContext).pop(6),
                ),
                const SizedBox(height: 12),
                _DifficultyOption(
                  label: 'خبير',
                  subtitle: '8×8 (64 قطعة)',
                  icon: Icons.local_fire_department,
                  color: const Color(0xFFD9534F),
                  onTap: () => Navigator.of(dialogContext).pop(8),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
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
            // 1. الخلفية على كبر الشاشة مع الشفافية
            Positioned.fill(
              child: Image.asset(
                'assets/images/background/private_bacgraund.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(color: const Color(0xFF0D1B2A));
                },
              ),
            ),
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.35),
              ),
            ),

            // 2. صورة الجزيرة في أعلى وسط الشاشة مع حركة طفو
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 90),
                child: AnimatedBuilder(
                  animation: _floatingAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _floatingAnimation.value),
                      child: child,
                    );
                  },
                  child: SizedBox(
                    width: 180,
                    height: 180,
                    child: Image.asset(
                      'assets/images/islands/private_island.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
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

            // 3. المحتوى المنسق بدون تمرير
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // الشريط العلوي (الفسيفساء الملكي والحواف النحاسية)
                  _buildHeaderBar(context),

                  const Spacer(flex: 1),

                  // بطاقة استوديو الصور والمستويات
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildStudioCard(),
                        const SizedBox(height: 24),
                        _buildLevelsSection(),
                      ],
                    ),
                  ),

                  const Spacer(flex: 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // 🏷️ الشريط العلوي (الفسيفساء الملكي + النحاسي)
  // ============================================================

  Widget _buildHeaderBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF2E1A47), // لون الفسيفساء الملكي
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFB8860B), // حواف نحاسية
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // أيقونة add_pic على يسار الشريط (أو اليمين بحسب الاتجاه العربي)
          SizedBox(
            width: 32,
            height: 32,
            child: Image.asset(
              'assets/images/ui/add_pic.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.add_photo_alternate,
                  color: Colors.white,
                  size: 28,
                );
              },
            ),
          ),
          const SizedBox(width: 12),

          // العنوان في المنتصف: الجزيرة الغامضة
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

          const SizedBox(width: 12),

          // زر الرجوع
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white70,
              size: 20,
            ),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🖼️ بطاقة الاستوديو
  // ============================================================

  Widget _buildStudioCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1B3A57),
            Color(0xFF12293F),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'استوديو الصور',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'اختر صورة من جهازك وحوّلها إلى لغز تفاعلي',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 18),

          // زر "افتح الاستوديو"
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isPicking ? null : _openImageStudio,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE0A63A),
                disabledBackgroundColor:
                    const Color(0xFFE0A63A).withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: _isPicking
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'افتح الاستوديو',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🔒 مستويات الجزيرة (تمت إزالة "قريباً" والمربع الأزرق)
  // ============================================================

  Widget _buildLevelsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'اختر المستوى',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 6,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.2,
          ),
          itemBuilder: (context, index) {
            return _LevelSlot(index: index + 1);
          },
        ),
      ],
    );
  }
}

// ============================================================================
// 🎯 خيار الصعوبة داخل النافذة المنبثقة
// ============================================================================

class _DifficultyOption extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.18),
              ),
              child: Icon(
                icon,
                color: color,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.arrow_back_ios,
              color: Colors.white.withOpacity(0.3),
              size: 12,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 🔒 فتح مستوى الجزيرة
// ============================================================================

class _LevelSlot extends StatelessWidget {
  final int index;

  const _LevelSlot({required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline,
            color: Colors.white.withOpacity(0.25),
            size: 22,
          ),
          const SizedBox(height: 6),
          Text(
            'مستوى $index',
            style: TextStyle(
              color: Colors.white.withOpacity(0.35),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
