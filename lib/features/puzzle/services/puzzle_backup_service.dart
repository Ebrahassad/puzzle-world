import '../managers/puzzle_progress_manager.dart';

class PuzzleBackupService {
  const PuzzleBackupService._();

  //==================================================
  // إنشاء نسخة احتياطية
  //==================================================

  static Future<Map<String, dynamic>> createBackup() async {
    return await PuzzleProgressManager.exportData();
  }

  //==================================================
  // استعادة نسخة احتياطية
  //==================================================

  static Future<void> restoreBackup(
    Map<String, dynamic> data,
  ) async {
    await PuzzleProgressManager.importData(
      data,
    );
  }

  //==================================================
  // التحقق من صحة النسخة
  //==================================================

  static bool isValidBackup(
    Map<String, dynamic> data,
  ) {
    return data.isNotEmpty;
  }
}