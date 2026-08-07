import 'package:shared_preferences/shared_preferences.dart';

class DailyRewardManager {
  static const String _lastClaimKey = 'last_daily_reward_claim_time';
  static const Duration rewardCooldown = Duration(hours: 24);

  // التحقق مما إذا كان الوقت قد حان لاستلام المكافأة
  static Future<bool> canClaimReward() async {
    final prefs = await SharedPreferences.getInstance();
    final String? lastClaimString = prefs.getString(_lastClaimKey);
    
    if (lastClaimString == null) return true;

    final DateTime lastClaimTime = DateTime.parse(lastClaimString);
    final DateTime nextAvailableTime = lastClaimTime.add(rewardCooldown);
    
    return DateTime.now().isAfter(nextAvailableTime);
  }

  // حفظ وقت استلام المكافأة الحالي
  static Future<void> saveClaimTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastClaimKey, DateTime.now().toIso8601String());
  }

  // حساب الوقت المتبقي حتى المكافأة القادمة
  static Future<Duration> getRemainingTime() async {
    final prefs = await SharedPreferences.getInstance();
    final String? lastClaimString = prefs.getString(_lastClaimKey);
    
    if (lastClaimString == null) return Duration.zero;

    final DateTime lastClaimTime = DateTime.parse(lastClaimString);
    final DateTime nextAvailableTime = lastClaimTime.add(rewardCooldown);
    final Duration remaining = nextAvailableTime.difference(DateTime.now());

    return remaining.isNegative ? Duration.zero : remaining;
  }
}
