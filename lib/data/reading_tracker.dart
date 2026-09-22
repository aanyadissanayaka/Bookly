import 'package:shared_preferences/shared_preferences.dart';

class ReadingTracker {
  static const String _totalMinutesKey = 'reading_total_minutes';
  static const String _lastReadDateKey = 'reading_last_date';
  static const String _streakKey = 'reading_streak';

  // --------------------------------------------------
  // GET TOTAL READING MINUTES
  // --------------------------------------------------
  static Future<int> getTotalMinutes() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getInt(_totalMinutesKey) ?? 0;
  }

  // --------------------------------------------------
  // GET CURRENT STREAK
  // --------------------------------------------------
  static Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getInt(_streakKey) ?? 0;
  }

  // --------------------------------------------------
  // ADD READING SESSION
  // --------------------------------------------------
  static Future<void> addReadingSession(int minutes) async {
    if (minutes <= 0) return;

    final prefs = await SharedPreferences.getInstance();

    // කලින් save කරලා තියෙන total reading minutes.
    final currentTotal = prefs.getInt(_totalMinutesKey) ?? 0;

    // New session එක total එකට add කරනවා.
    await prefs.setInt(_totalMinutesKey, currentTotal + minutes);

    // Streak එකත් update කරනවා.
    await _updateStreak(prefs);
  }

  // --------------------------------------------------
  // UPDATE DAY STREAK
  // --------------------------------------------------
  static Future<void> _updateStreak(SharedPreferences prefs) async {
    final today = DateTime.now();

    // Time part එක අයින් කරලා date එක විතරක් ගන්නවා.
    final todayDate = DateTime(today.year, today.month, today.day);

    final savedDateString = prefs.getString(_lastReadDateKey);

    final currentStreak = prefs.getInt(_streakKey) ?? 0;

    // කලින් reading date එකක් නැත්නම්
    // අද first reading day එක.
    if (savedDateString == null) {
      await prefs.setInt(_streakKey, 1);

      await prefs.setString(_lastReadDateKey, todayDate.toIso8601String());

      return;
    }

    final lastReadDate = DateTime.parse(savedDateString);

    final difference = todayDate.difference(lastReadDate).inDays;

    // අදම කලින් reading session එකක් කරලා තියෙනවා.
    // Streak එක ආයෙ increase කරන්නෙ නැහැ.
    if (difference == 0) {
      return;
    }

    // ඊයේ read කරලා අදත් read කරනවා නම්
    // streak එක +1.
    if (difference == 1) {
      await prefs.setInt(_streakKey, currentStreak + 1);
    }
    // Day එකක් miss වෙලා නම් streak reset.
    else {
      await prefs.setInt(_streakKey, 1);
    }

    // Last reading date එක අද date එකට update කරනවා.
    await prefs.setString(_lastReadDateKey, todayDate.toIso8601String());
  }

  // --------------------------------------------------
  // FORMAT READING TIME
  // --------------------------------------------------
  static String formatReadingTime(int totalMinutes) {
    if (totalMinutes < 60) {
      return '${totalMinutes}m';
    }

    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (minutes == 0) {
      return '${hours}h';
    }

    return '${hours}h ${minutes}m';
  }
}
