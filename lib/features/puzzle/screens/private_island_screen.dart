import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'puzzle_game_screen.dart';
import '../managers/ads_manager.dart';
import '../managers/puzzle_progress_manager.dart';

/// ===============================================================
/// 🏝️ الجزيرة الغامضة
///
/// شاشة مستقلة عن مستويات البازل العادية.
///
/// الوظائف:
/// 1. اختيار صورة من الجهاز.
/// 2. تجهيز الصورة لتكون مربعة بدون قص المحتوى.
/// 3. اختيار مستوى الصعوبة:
///      4 × 4
///      6 × 6
///      8 × 8
/// 4. حفظ مسار الصورة في نظام الجزيرة الخاصة.
/// 5. الانتقال إلى PuzzleGameScreen.
/// 6. اكتشاف وجود لعبة محفوظة سابقًا (نفس نظام حفظ الجزيرة
///    الخاصة المستقل: privateIslandGameStateKey +
///    privateIslandImagePathKey) وعرض خيار "متابعة" مباشرة
///    بدل إجبار المستخدم على اختيار صورة جديدة في كل مرة.
///
/// ===============================================================
class PrivateIslandScreen extends StatefulWidget {
  const PrivateIslandScreen({super.key});

  @override
  State<PrivateIslandScreen> createState() =>
      _PrivateIslandScreenState();
}

class _PrivateIslandScreenState
    extends State<PrivateIslandScreen>
    with TickerProviderStateMixin {
  // ============================================================
  // 🎈 Animation
  // ============================================================

  late final AnimationController _floatingController;
  late final Animation<double> _floatingAnimation;

  // ============================================================
  // 🖼️ Image Picker
  // ============================================================

  final ImagePicker _imagePicker = ImagePicker();

  bool _isPicking = false;

  // ============================================================
  // 🔄 حالة الحفظ السابق للجزيرة الخاصة
  // ============================================================

  bool _checkingSavedGame = true;
  bool _hasSavedGame = false;
  String? _savedImagePath;
  int _savedGridSize = 4;

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

    _checkSavedGame();
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
  // 🔄 فحص وجود لعبة جزيرة خاصة محفوظة
  // ============================================================

  Future<void> _checkSavedGame() async {
    final isValid =
        await PuzzleProgressManager.hasValidPrivateIslandSave();

    if (!isValid) {
      // ينظف فقط إذا كان هناك حفظ ناقص/تالف (مثلًا حالة بازل
      // بدون صورة، أو صورة بدون حالة بازل، أو صورة محذوفة).
      await PuzzleProgressManager
          .clearInvalidPrivateIslandSave();

      if (!mounted) {
        return;
      }

      setState(() {
        _checkingSavedGame = false;
        _hasSavedGame = false;
        _savedImagePath = null;
      });

      return;
    }

    final imagePath =
        await PuzzleProgressManager
            .getPrivateIslandImagePath();

    final state =
        await PuzzleProgressManager
            .loadPrivateIslandGameState();

    int gridSize = 4;

    final savedSize = state?["customGridSize"];

    if (savedSize is num && savedSize.toInt() >= 2) {
      gridSize = savedSize.toInt();
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _checkingSavedGame = false;
      _hasSavedGame = true;
      _savedImagePath = imagePath;
      _savedGridSize = gridSize;
    });
  }

  // ============================================================
  // ▶️ متابعة اللعبة المحفوظة
  // ============================================================

  Future<void> _continueSavedGame() async {
    final imagePath = _savedImagePath;

    if (imagePath == null || imagePath.isEmpty) {
      return;
    }

    // ----------------------------------------------------------
    // 🔒 تحقق أخير وآمن من وجود الملف قبل فتح اللعبة، تفاديًا
    // لأي احتمال أن يكون الملف قد حُذف بعد فحصنا الأول.
    // ----------------------------------------------------------

    bool exists = false;

    try {
      exists = await File(imagePath).exists();
    } catch (_) {
      exists = false;
    }

    if (!exists) {
      await PuzzleProgressManager
          .clearInvalidPrivateIslandSave();

      if (!mounted) {
        return;
      }

      setState(() {
        _hasSavedGame = false;
        _savedImagePath = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "تعذر العثور على اللعبة المحفوظة، الصورة لم تعد متوفرة.",
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PuzzleGameScreen(
          customImagePath: imagePath,
          isCustomImage: true,
          customGridSize: _savedGridSize,
        ),
      ),
    );

    // ----------------------------------------------------------
    // عند العودة من اللعبة، نعيد فحص حالة الحفظ (قد يكون
    // المستخدم أنهى اللعبة أو بدأ لعبة جديدة).
    // ----------------------------------------------------------

    if (!mounted) {
      return;
    }

    setState(() {
      _checkingSavedGame = true;
    });

    await _checkSavedGame();
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
        // 🪄 تجهيز الصورة لتكون مربعة
        // بدون قص أي جزء من الصورة.
        // ======================================================

        final String preparedPath =
            await _prepareSquareImage(
          picked.path,
        );

        if (!mounted) {
          return;
        }

        // ======================================================
        // 🎯 اختيار مستوى الصعوبة
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
        // 🆕 صورة جديدة = لعبة جديدة.
        //
        // نحذف أي حفظ سابق للجزيرة الخاصة (إن وُجد) قبل بدء
        // اللعبة بصورة مختلفة، حتى لا يحاول PuzzleGameScreen
        // مطابقة حالة بازل قديمة مع صورة جديدة عن طريق الخطأ.
        // (لا نلمس progressKey إطلاقًا هنا).
        // ======================================================

        await PuzzleProgressManager
            .clearPrivateIslandGameState();

        // ======================================================
        // 🔄 حفظ صورة الجزيرة الخاصة
        //
        // هذه الدالة موجودة فعليًا في PuzzleProgressManager الحالي.
        //
        // ولا علاقة لها بحفظ المراحل العادية.
        // ======================================================

        await PuzzleProgressManager
            .savePrivateIslandImagePath(
          preparedPath,
        );

        if (!mounted) {
          return;
        }

        setState(() {
          _isPicking = false;
        });

        // ======================================================
        // 🎮 فتح لعبة الجزيرة الخاصة
        // ======================================================

        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                PuzzleGameScreen(
              customImagePath: preparedPath,
              isCustomImage: true,
              customGridSize: gridSize,
            ),
          ),
        );

        // ======================================================
        // تحديث حالة الحفظ بعد العودة من اللعبة
        // ======================================================

        if (!mounted) {
          return;
        }

        setState(() {
          _checkingSavedGame = true;
        });

        await _checkSavedGame();
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
  // 🪄 تجهيز الصورة المربعة
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

    // ============================================================
    // الصورة مربعة أصلًا
    // ============================================================

    if (sourceWidth == sourceHeight) {
      sourceImage.dispose();
      codec.dispose();

      return sourcePath;
    }

    // ============================================================
    // أكبر ضلع يصبح حجم الصورة الجديدة
    // ============================================================

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

    // ============================================================
    // الخلفية
    // ============================================================

    final Paint backgroundPaint =
        Paint()
          ..color =
              const Color(0xFF101827);

    canvas.drawRect(
      outputRect,
      backgroundPaint,
    );

    // ============================================================
    // وضع الصورة في المنتصف بدون قص
    // ============================================================

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
          ..filterQuality =
              FilterQuality.high;

    canvas.drawImageRect(
      sourceImage,
      sourceRect,
      destinationRect,
      imagePaint,
    );

    // ============================================================
    // إنشاء الصورة النهائية
    // ============================================================

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

    // ============================================================
    // حفظ نسخة مؤقتة
    // ============================================================

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
  // 🎯 اختيار مستوى الصعوبة
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

                const SizedBox(height: 18),

                // ==================================================
                // 4 × 4
                // ==================================================

                _DifficultyOption(
                  label: 'سهل',
                  subtitle: '4 × 4',
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
                  subtitle: '6 × 6',
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
                  subtitle: '8 × 8',
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
  // 🏗️ BUILD
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
            // 🏞️ الخلفية
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
                    Colors.black.withOpacity(
                  0.35,
                ),
              ),
            ),

            // ======================================================
            // 🏝️ الجزيرة العائمة
            // ======================================================

            Builder(
              builder: (context) {
                final Size screenSize =
                    MediaQuery.sizeOf(context);

                final double islandSize =
                    (screenSize.width * 0.62)
                        .clamp(
                  220.0,
                  300.0,
                );

                final double islandTop =
                    (screenSize.height * 0.13)
                        .clamp(
                  115.0,
                  145.0,
                );

                return Align(
                  alignment:
                      Alignment.topCenter,
                  child: Padding(
                    padding:
                        EdgeInsets.only(
                      top: islandTop,
                    ),
                    child: AnimatedBuilder(
                      animation:
                          _floatingAnimation,
                      builder: (
                        context,
                        child,
                      ) {
                        return Transform.translate(
                          offset: Offset(
                            0,
                            _floatingAnimation
                                .value,
                          ),
                          child: child,
                        );
                      },
                      child: SizedBox(
                        width: islandSize,
                        height: islandSize,
                        child: Image.asset(
                          'assets/images/islands/private_island.png',
                          fit:
                              BoxFit.contain,
                          errorBuilder: (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return const Icon(
                              Icons.landscape,
                              color:
                                  Colors.white70,
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
            // 📋 المحتوى
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

                  if (!_checkingSavedGame &&
                      _hasSavedGame)
                    Padding(
                      padding:
                          const EdgeInsets
                              .fromLTRB(
                        20,
                        0,
                        20,
                        14,
                      ),
                      child:
                          _buildContinueCard(),
                    ),

                  Padding(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 20,
                    ),
                    child:
                        _buildStudioCard(),
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
  // 🔝 الشريط العلوي
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
                  color:
                      Colors.white,
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
            padding:
                EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ▶️ بطاقة متابعة اللعبة المحفوظة
  // ============================================================

  Widget _buildContinueCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF1B3A57),
        border: Border.all(
          color: const Color(0xFF4CAF7D).withOpacity(0.6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_savedImagePath != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 48,
                height: 48,
                child: Image.file(
                  File(_savedImagePath!),
                  fit: BoxFit.cover,
                  errorBuilder: (
                    context,
                    error,
                    stackTrace,
                  ) {
                    return const Icon(
                      Icons.image_not_supported,
                      color: Colors.white54,
                    );
                  },
                ),
              ),
            ),

          const SizedBox(width: 12),

          const Expanded(
            child: Text(
              'لديك لعبة محفوظة في الجزيرة الغامضة',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(width: 10),

          ElevatedButton(
            onPressed: _continueSavedGame,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF7D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'متابعة',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
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
              Colors.white.withOpacity(
            0.12,
          ),
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
            _hasSavedGame
                ? 'اختر صورة جديدة لبدء لغز مختلف'
                : 'اختر صورة من جهازك وحوّلها إلى لغز تفاعلي',
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
                      'فتح استوديو الصور',
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