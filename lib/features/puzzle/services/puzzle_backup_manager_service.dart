import 'dart:convert';

import '../managers/puzzle_progress_manager.dart';

class PuzzleBackupManagerService {
  const PuzzleBackupManagerService._();

  //==================================================
  // إنشاء نسخة احتياطية
  //==================================================

  static Future<String> createBackup() async {
    final data =
        await PuzzleProgressManager.exportData();

    return jsonEncode(data);
  }

  //==================================================
  // استعادة نسخة احتياطية
  //==================================================

  static Future<bool> restoreBackup(
    String backup,
  ) async {
    try {
      final decoded = jsonDecode(backup);

      if (decoded is! Map<String, dynamic>) {
        return false;
      }

      await PuzzleProgressManager.importData(
        decoded,
      );

      return true;
    } catch (_) {
      return false;
    }
  }

  //==================================================
  // معاينة النسخة
  //==================================================

  static Map<String, dynamic> preview(
    String backup,
  ) {
    try {
      return Map<String, dynamic>.from(
        jsonDecode(backup),
      );
    } catch (_) {
      return {};
    }
  }

  //==================================================
  // التحقق من صحة النسخة
  //==================================================

  static bool validate(
    String backup,
  ) {
    try {
      final data = jsonDecode(backup);

      return data is Map;
    } catch (_) {
      return false;
    }
  }
}