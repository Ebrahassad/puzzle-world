// ... (باقي الكود كما هو)

  @override
  void initState() {
    super.initState();

    islands = PuzzleData.puzzles;
    audioPlayer = AudioPlayer();

    // إزالة initAds المكررة هنا، بما أن main.dart يقوم بها بالفعل.

    loadIslandState();
    loadPrivateIslandState();

    worldController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..forward(from: 0.0);
    
    worldController.repeat(reverse: true);

    worldScale = Tween<double>(
      begin: 1.00,
      end: 1.035,
    ).animate(
      CurvedAnimation(
        parent: worldController,
        curve: Curves.easeInOut,
      ),
    );

    worldTranslateY = Tween<double>(
      begin: -10,
      end: 10,
    ).animate(
      CurvedAnimation(
        parent: worldController,
        curve: Curves.easeInOut,
      ),
    );

    cloudControllers = _clouds
        .map(
          (cloud) => AnimationController(
            vsync: this,
            duration: cloud.duration,
          )..repeat(),
        )
        .toList();
  }

  // دالة عامة لتحديث حالة الجزر في الواجهة
  Future<void> refreshIslandState() async {
    if (!mounted) return;
    // تحديث الحالة العامة للجزر (للفضاء أو غيره)
    await loadIslandState();
    setState(() {});
  }

// ... (باقي الدوال)

  Future<void> openIsland(PuzzleModel island) async {

    final unlocked =
        await PuzzleProgressManager.isIslandUnlocked(
          island.id,
        );

    if(unlocked){
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => IslandScreen(
            island: island,
          ),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context){
        return AlertDialog(
          title: const Text("🔒 الجزيرة مغلقة"),
          content: FutureBuilder<List<dynamic>>(
            future: Future.wait([
              Future.value(PuzzleProgressManager.getIslandRequiredAds(island.id)),
              PuzzleProgressManager.getAdsBalance(),
            ]),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox(height: 40, child: Center(child: CircularProgressIndicator()));
              }
              final required = snapshot.data![0] as int;
              final balance = snapshot.data![1] as int;
              return Text("رصيدك: $balance مشاهدة\nالمطلوب: $required مشاهدة");
            },
          ),
          actions: [
            TextButton(
              child: const Text("إلغاء"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              child: const Text("📺 مشاهدة إعلان"),
              onPressed: openingAd ? null : () async {
                if (openingAd) return;
                setState(() => openingAd = true);
                Navigator.pop(context);

                if (!AdsManager().isInitialized) {
                  await AdsManager().initAds();
                }

                AdsManager().showRewardedAd(
                  onRewardEarned: () async {
                    await PuzzleProgressManager.addAdsBalance(1);
                    final balance = await PuzzleProgressManager.getAdsBalance();
                    final required = PuzzleProgressManager.getIslandRequiredAds(island.id);

                    if(balance >= required){
                      await PuzzleProgressManager.unlockIsland(island.id);
                      
                      // استخدام الدالة الجديدة لتحديث الحالة
                      await refreshIslandState();

                      if(!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("🎉 تم فتح الجزيرة!")),
                      );
                    } else {
                      if(!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("تمت إضافة مشاهدة الإعلان\nالرصيد: $balance / $required")),
                      );
                    }
                    if(!mounted) return;
                    setState(() => openingAd = false);
                  },
                  onAdFailed: () {
                    if(!mounted) return;
                    setState(() => openingAd = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("الإعلان غير متوفر حالياً")),
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
