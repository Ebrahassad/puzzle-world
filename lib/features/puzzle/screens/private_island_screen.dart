import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';


import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'puzzle_game_screen.dart';
import '../managers/ads_manager.dart';

/// ===============================================================
/// 🏝️ الجزيرة الغامضة
///
/// هذه الشاشة مستقلة عن مستويات البازل العادية.
///
/// الوظيفة:
/// 1. اختيار صورة من الجهاز.
/// 2. تجهيز الصورة لتكون مربعة بدون قص محتواها.
/// 3. اختيار مستوى:
///      4 × 4
///      6 × 6
///      8 × 8
/// 4. الانتقال مباشرة إلى PuzzleGameScreen.
///
/// ملاحظة:
/// لا يتم تعديل PuzzleGenerator أو PuzzleController أو
/// مستويات اللعبة الأساسية.
/// ===============================================================
class PrivateIslandScreen extends StatefulWidget {
  const PrivateIslandScreen({super.key});

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
      begin: -8,
      end: 8,
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
  // 🖼️ فتح الاستوديو
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

      try {
        // ======================================================
        // 🖼️ اختيار الصورة
        // ======================================================

        final XFile? picked =
            await _imagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 100,
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

        // ======================================================
        // 🟪 تجهيز الصورة لتكون مربعة
        //
        // مهم:
        // لا نقص الصورة.
        //
        // إذا كانت:
        // 1920 × 1080
        //
        // تصبح:
        // 1920 × 1920
        //
        // مع وضع الصورة في المنتصف وخلفية مناسبة.
        //
        // بهذا PuzzleGameScreen الذي يستخدم BoxFit.cover
        // لن يقص أجزاء من صورة المستخدم.
        // ======================================================

        final String preparedPath =
            await _prepareSquareImage(
          picked.path,
        );

        if (!mounted) {
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
          setState(() {
            _isPicking = false;
          });

          return;
        }

        // ======================================================
        // 🎮 الانتقال إلى لعبة البازل
        // ======================================================

        setState(() {
          _isPicking = false;
        });

        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PuzzleGameScreen(
              customImagePath: preparedPath,

              // هذه هي النقطة التي تجعل اللعبة
              // تستخدم نظام الجزيرة الغامضة.
              isCustomImage: true,

              // 4 أو 6 أو 8
              //
              // عند 8:
              // rows = 8
              // cols = 8
              // 8 × 8 = 64 قطعة.
              customGridSize: gridSize,
            ),
          ),
        );
      } catch (error, stackTrace) {
        debugPrint(
          '❌ Private Island image error: $error',
        );

        debugPrint(
          '$stackTrace',
        );

        if (!mounted) {
          return;
        }

        setState(() {
          _isPicking = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تعذر فتح الصورة. حاول مرة أخرى.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }

    // ============================================================
    // 📺 الإعلان المكافئ
    //
    // الإعلان اختياري:
    // - إذا نجح → نفتح الاستوديو.
    // - إذا فشل أو غير جاهز → نفتح الاستوديو مباشرة.
    //
    // لا نمنع المستخدم من استخدام الجزيرة الغامضة.
    // ============================================================

    AdsManager().showRewardedAd(
      onRewardEarned: () {
        openStudio();
      },
      onAdFailed: () {
        openStudio();
      },
    );
  }

  // ============================================================
  // 🟪 تجهيز الصورة المربعة
  // ============================================================
  //
  // الهدف:
  //
  // صورة المستخدم:
  //
  //   ┌───────────────────────┐
  //   │       الصورة          │
  //   └───────────────────────┘
  //
  // تصبح داخل Canvas مربع:
  //
  //   ┌───────────────────────┐
  //   │       مساحة           │
  //   │   ┌───────────────┐   │
  //   │   │    الصورة     │   │
  //   │   └───────────────┘   │
  //   │       مساحة           │
  //   └───────────────────────┘
  //
  // بدون فقدان أي جزء من الصورة.
  //
  // ============================================================

  Future<String> _prepareSquareImage(
    String sourcePath,
  ) async {
    final File sourceFile = File(sourcePath);

    if (!await sourceFile.exists()) {
      throw Exception(
        'Source image does not exist.',
      );
    }

    final Uint8List bytes =
        await sourceFile.readAsBytes();

    final ui.Codec codec =
        await ui.instantiateImageCodec(bytes);

    final ui.FrameInfo frame =
        await codec.getNextFrame();

    final ui.Image sourceImage =
        frame.image;

    final int sourceWidth =
        sourceImage.width;

    final int sourceHeight =
        sourceImage.height;

    // ------------------------------------------------------------
    // إذا كانت الصورة مربعة أصلًا:
    // لا نحتاج إلى إعادة تصنيعها.
    // ------------------------------------------------------------

    if (sourceWidth == sourceHeight) {
      sourceImage.dispose();
      codec.dispose();

      return sourcePath;
    }

    // ------------------------------------------------------------
    // أكبر ضلع يصبح حجم الصورة الجديدة.
    // ------------------------------------------------------------

    final int squareSize =
        sourceWidth > sourceHeight
            ? sourceWidth
            : sourceHeight;

    final ui.PictureRecorder recorder =
        ui.PictureRecorder();

    final Canvas canvas =
        Canvas(recorder);

    final Rect outputRect =
        Rect.fromLTWH(
      0,
      0,
      squareSize.toDouble(),
      squareSize.toDouble(),
    );

    // ------------------------------------------------------------
    // خلفية بسيطة.
    //
    // يمكن تغييرها لاحقًا إذا أردت تصميمًا معينًا.
    // ------------------------------------------------------------

    final Paint backgroundPaint =
        Paint()
          ..color = const Color(0xFF101827);

    canvas.drawRect(
      outputRect,
      backgroundPaint,
    );

    // ------------------------------------------------------------
    // حساب مكان الصورة في منتصف المربع.
    // ------------------------------------------------------------

    final double dx =
        (squareSize - sourceWidth) / 2;

    final double dy =
        (squareSize - sourceHeight) / 2;

    final Rect sourceRect =
        Rect.fromLTWH(
      0,
      0,
      sourceWidth.toDouble(),
      sourceHeight.toDouble(),
    );

    final Rect destinationRect =
        Rect.fromLTWH(
      dx,
      dy,
      sourceWidth.toDouble(),
      sourceHeight.toDouble(),
    );

    final Paint imagePaint =
        Paint()
          ..filterQuality = FilterQuality.high;

    canvas.drawImageRect(
      sourceImage,
      sourceRect,
      destinationRect,
      imagePaint,
    );

    // ------------------------------------------------------------
    // إنشاء الصورة النهائية.
    // ------------------------------------------------------------

    final ui.Picture picture =
        recorder.endRecording();

    final ui.Image squareImage =
        await picture.toImage(
      squareSize,
      squareSize,
    );

    final ByteData? byteData =
        await squareImage.toByteData(
      format: ui.ImageByteFormat.png,
    );

    if (byteData == null) {
      sourceImage.dispose();
      squareImage.dispose();
      codec.dispose();

      throw Exception(
        'Could not encode image.',
      );
    }

    final Uint8List pngBytes =
        byteData.buffer.asUint8List();

    // ------------------------------------------------------------
    // حفظ نسخة مؤقتة.
    //
    // سيتم استخدامها فقط في جلسة الجزيرة الغامضة.
    // ------------------------------------------------------------

    final Directory tempDirectory =
        Directory.systemTemp;

    final String fileName =
        'private_island_${DateTime.now().microsecondsSinceEpoch}.png';

    final File outputFile =
        File(
      '${tempDirectory.path}/$fileName',
    );

    await outputFile.writeAsBytes(
      pngBytes,
      flush: true,
    );

    sourceImage.dispose();
    squareImage.dispose();
    codec.dispose();

    return outputFile.path;
  }

  // ============================================================
  // 🎯 اختيار مستوى البازل
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
            borderRadius:
                BorderRadius.circular(20),
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 28,
            ),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                const Text(
                  'اختر مستوى الصعوبة',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'اختر عدد قطع البازل',
                  textAlign:
                      TextAlign.center,
                  style: TextStyle(
                    color: Colors.white
                        .withOpacity(0.6),
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 24),

                // ==================================================
                // 4 × 4
                // ==================================================

                _DifficultyOption(
                  label: 'سهل',
                  subtitle:
                      '4×4 • 16 قطعة',
                  icon:
                      Icons.sentiment_satisfied_alt,
                  color:
                      const Color(0xFF4CAF7D),
                  onTap: () {
                    Navigator.of(
                      dialogContext,
                    ).pop(4);
                  },
                ),

                const SizedBox(height: 12),

                // ==================================================
                // 6 × 6
                // ==================================================

                _DifficultyOption(
                  label: 'متوسط',
                  subtitle:
                      '6×6 • 36 قطعة',
                  icon: Icons.extension,
                  color:
                      const Color(0xFFE0A63A),
                  onTap: () {
                    Navigator.of(
                      dialogContext,
                    ).pop(6);
                  },
                ),

                const SizedBox(height: 12),

                // ==================================================
                // 8 × 8
                // ==================================================

                _DifficultyOption(
                  label: 'خبير',
                  subtitle:
                      '8×8 • 64 قطعة',
                  icon:
                      Icons.local_fire_department,
                  color:
                      const Color(0xFFD9534F),
                  onTap: () {
                    Navigator.of(
                      dialogContext,
                    ).pop(8);
                  },
                ),

                const SizedBox(height: 16),

                TextButton(
                  onPressed: () {
                    Navigator.of(
                      dialogContext,
                    ).pop();
                  },
                  child: Text(
                    'إلغاء',
                    style: TextStyle(
                      color: Colors.white
                          .withOpacity(0.5),
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
  // 🎨 BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Directionality(
      textDirection:
          TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            // ======================================================
            // 🌌 الخلفية
            // ======================================================

            Positioned.fill(
              child: Image.asset(
                'assets/images/background/private_bacgraund.png',
                fit: BoxFit.cover,
                errorBuilder:
                    (
                  context,
                  error,
                  stackTrace,
                ) {
                  return Container(
                    color:
                        const Color(0xFF0D1B2A),
                  );
                },
              ),
            ),

            Positioned.fill(
              child: Container(
                color:
                    Colors.black
                        .withOpacity(0.35),
              ),
            ),

            // ======================================================
            // 🏝️ الجزيرة العائمة — Responsive
            // ======================================================

            Builder(
              builder: (context) {
                final Size screenSize =
                    MediaQuery.sizeOf(context);

                // حجم الجزيرة يتناسب مع عرض الجهاز.
                // مع حد أدنى وأقصى حتى لا تصبح صغيرة جدًا
                // أو ضخمة جدًا على الأجهزة الكبيرة.
                final double islandSize =
                    (screenSize.width * 0.62)
                        .clamp(220.0, 300.0);

                // موضع الجزيرة يتكيف مع ارتفاع الشاشة.
                // لا نريدها خلف الشريط العلوي.
                final double islandTop =
                    (screenSize.height * 0.13)
                        .clamp(115.0, 145.0);

                return Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: islandTop,
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
                        width: islandSize,
                        height: islandSize,
                        child: Image.asset(
                          'assets/images/islands/private_island.png',
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
                );
              },
            ),

            // ======================================================
            // 📱 المحتوى
            // ======================================================

            SafeArea(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .stretch,
                children: [
                  _buildHeaderBar(
                    context,
                  ),

                  const Spacer(
                    flex: 3,
                  ),

                  Padding(
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: _buildStudioCard(),
                  ),

                  const Spacer(
                    flex: 1,
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
      margin:
          const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        0,
      ),
      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(0xFF2E1A47),
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color:
              const Color(0xFFB8860B),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(
              0.4,
            ),
            blurRadius: 8,
            offset:
                const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 42,
            height: 42,
            child: Image.asset(
              'assets/images/ui/add_pic.png',
              fit: BoxFit.contain,
              errorBuilder:
                  (
                context,
                error,
                stackTrace,
              ) {
                return const Icon(
                  Icons
                      .add_photo_alternate,
                  color: Colors.white,
                  size: 32,
                );
              },
            ),
          ),

          const SizedBox(width: 10),

          const Expanded(
            child: Text(
              'الجزيرة الغامضة',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),

          const SizedBox(width: 12),

          IconButton(
            onPressed: () =>
                Navigator.of(
                  context,
                ).maybePop(),
            icon: const Icon(
              Icons.arrow_forward_ios,
              color:
                  Colors.white70,
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
  // 🖼️ بطاقة الاستوديو
  // ============================================================

  Widget _buildStudioCard() {
    return Container(
      padding:
          const EdgeInsets.all(20),
      decoration:
          BoxDecoration(
        borderRadius:
            BorderRadius.circular(24),
        gradient:
            const LinearGradient(
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
          colors: [
            Color(0xFF1B3A57),
            Color(0xFF12293F),
          ],
        ),
        border: Border.all(
          color:
              Colors.white
                  .withOpacity(0.12),
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(
              0.45,
            ),
            blurRadius: 20,
            offset:
                const Offset(0, 10),
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
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            'اختر صورة من جهازك وحوّلها إلى لغز تفاعلي',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              color: Colors.white
                  .withOpacity(0.7),
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            height: 48,
            child:
                ElevatedButton(
              onPressed:
                  _isPicking
                      ? null
                      : _openImageStudio,
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(
                  0xFFE0A63A,
                ),
                disabledBackgroundColor:
                    const Color(
                  0xFFE0A63A,
                ).withOpacity(0.5),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
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
                        color:
                            Colors.white,
                      ),
                    )
                  : const Text(
                      'افتح الاستوديو',
                      style: TextStyle(
                        color:
                            Colors.white,
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
// 🎯 خيار مستوى الصعوبة
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
        decoration:
            BoxDecoration(
          color: Colors.white
              .withOpacity(0.04),
          borderRadius:
              BorderRadius.circular(14),
          border: Border.all(
            color: Colors.white
                .withOpacity(0.08),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration:
                  BoxDecoration(
                shape:
                    BoxShape.circle,
                color: color
                    .withOpacity(0.18),
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
                style:
                    const TextStyle(
                  color:
                      Colors.white,
                  fontSize: 15,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),

            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white
                    .withOpacity(0.5),
                fontSize: 13,
                fontWeight:
                    FontWeight.w500,
              ),
            ),

            const SizedBox(width: 6),

            Icon(
              Icons.arrow_back_ios,
              color: Colors.white
                  .withOpacity(0.3),
              size: 12,
            ),
          ],
        ),
      ),
    );
  }
}
