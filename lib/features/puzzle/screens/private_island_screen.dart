import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'puzzle_game_screen.dart';
import '../managers/ads_manager.dart';
import '../../../core/language/app_language_manager.dart';

/// شاشة "جزيرتك الخاصة".
///
/// تسمح للمستخدم باختيار صورة من الجهاز وتحويلها إلى
/// Puzzle قابل للعب بدرجة الصعوبة التي يختارها.
class PrivateIslandScreen extends StatefulWidget {
  const PrivateIslandScreen({
    super.key,
  });

  @override
  State<PrivateIslandScreen> createState() =>
      _PrivateIslandScreenState();
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
  // 🌐 Language
  // ============================================================

  AppLanguageManager get _language =>
      AppLanguageManager.instance;

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
    if (_isPicking) {
      return;
    }

    setState(() {
      _isPicking = true;
    });

    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (!mounted) {
        return;
      }

      if (picked == null) {
        setState(() {
          _isPicking = false;
        });

        return;
      }

      final int? gridSize =
          await _showDifficultyDialog();

      if (!mounted) {
        return;
      }

      setState(() {
        _isPicking = false;
      });

      if (gridSize == null) {
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
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isPicking = false;
      });

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

  // ============================================================
  // 🎯 نافذة اختيار الصعوبة
  // ============================================================

  Future<int?> _showDifficultyDialog() {
    return showDialog<int>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Directionality(
          textDirection: _language.textDirection,
          child: Dialog(
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
                    onTap: () {
                      Navigator.of(dialogContext).pop(4);
                    },
                  ),

                  const SizedBox(height: 12),

                  _DifficultyOption(
                    label: 'متوسط',
                    subtitle: '6×6 (36 قطعة)',
                    icon: Icons.extension,
                    color: const Color(0xFFE0A63A),
                    onTap: () {
                      Navigator.of(dialogContext).pop(6);
                    },
                  ),

                  const SizedBox(height: 12),

                  _DifficultyOption(
                    label: 'خبير',
                    subtitle: '8×8 (64 قطعة)',
                    icon: Icons.local_fire_department,
                    color: const Color(0xFFD9534F),
                    onTap: () {
                      Navigator.of(dialogContext).pop(8);
                    },
                  ),

                  const SizedBox(height: 16),

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
    return ValueListenableBuilder<Locale>(
      valueListenable: _language.localeNotifier,
      builder: (context, locale, child) {
        return Directionality(
          textDirection: _language.textDirection,
          child: Scaffold(
            backgroundColor: const Color(0xFF0D1B2A),
            body: SafeArea(
              child: Stack(
                children: [
                  _buildAmbientBackground(),

                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(context),

                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(
                            20,
                            12,
                            20,
                            32,
                          ),
                          child: Column(
                            children: [
                              const SizedBox(height: 12),

                              _buildStudioCard(),

                              const SizedBox(height: 32),

                              _buildFutureLevelsSection(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // 🌌 الخلفية
  // ============================================================

  Widget _buildAmbientBackground() {
    return Positioned.fill(
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background/prave_bacgraund.png',
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

          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.25),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🏷️ HEADER
  // ============================================================

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        12,
        8,
        20,
        8,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.of(context).maybePop();
            },
            icon: Icon(
              _language.isArabic
                  ? Icons.arrow_forward_ios
                  : Icons.arrow_back_ios_new,
              color: Colors.white70,
              size: 20,
            ),
          ),

          const SizedBox(width: 4),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'مملكتك الخاصة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  'حوّل صورك الخاصة إلى ألغاز فريدة',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
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
      padding: const EdgeInsets.all(24),
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
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _floatingAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(
                  0,
                  _floatingAnimation.value,
                ),
                child: child,
              );
            },
            child: SizedBox(
              width: 85,
              height: 85,
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
                    color: Colors.white70,
                    size: 70,
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 18),

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
            'اختر صورة من جهازك وحوّلها إلى لغز تفاعلي بحجم\n'
            'الشبكة الذي تختاره',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 13,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 22),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed:
                  _isPicking ? null : _openImageStudio,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFFE0A63A),
                disabledBackgroundColor:
                    const Color(0xFFE0A63A)
                        .withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(16),
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
                      'فتح استوديو الصور',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 60,
            width: double.infinity,
            child: Center(
              child: AdsManager().banner(),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🔒 المستويات المستقبلية
  // ============================================================

  Widget _buildFutureLevelsSection() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'مستويات الجزيرة',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(width: 8),

            Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius:
                    BorderRadius.circular(8),
              ),
              child: Text(
                'قريباً',
                style: TextStyle(
                  color:
                      Colors.white.withOpacity(0.7),
                  fontSize: 11,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        GridView.builder(
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          itemCount: 6,
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemBuilder: (context, index) {
            return _FutureLevelSlot(
              index: index + 1,
            );
          },
        ),
      ],
    );
  }
}

// ============================================================================
// 🎯 خيار الصعوبة
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
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius:
              BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    color.withOpacity(0.18),
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),

            const SizedBox(width: 14),

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
                color:
                    Colors.white.withOpacity(0.5),
                fontSize: 14,
                fontWeight:
                    FontWeight.w500,
              ),
            ),

            const SizedBox(width: 6),

            Icon(
              AppLanguageManager
                      .instance
                      .isArabic
                  ? Icons.arrow_back_ios
                  : Icons.arrow_forward_ios,
              color:
                  Colors.white.withOpacity(0.3),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 🔒 مستوى مستقبلي
// ============================================================================

class _FutureLevelSlot extends StatelessWidget {
  final int index;

  const _FutureLevelSlot({
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.06),
        ),
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline,
            color:
                Colors.white.withOpacity(0.25),
            size: 26,
          ),

          const SizedBox(height: 8),

          Text(
            'مستوى $index',
            style: TextStyle(
              color:
                  Colors.white.withOpacity(0.35),
              fontSize: 12,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
