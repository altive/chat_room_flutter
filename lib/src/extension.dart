import 'package:clock/clock.dart';
import 'package:intl/intl.dart';

/// DateTime 向けの拡張機能 DateTimeExtension。
extension DateTimeExtension on DateTime {
  /// 時刻表示用文字列（H:mm）
  ///
  /// e.g. 1:01
  String get timeText {
    return DateFormat('H:mm').format(toLocal());
  }

  /// 日付表示用文字列（M月d日(EE)）
  ///
  /// 今日と昨日の場合以外は日付表記になる。
  /// e.g. 今日、昨日、1月1日(日)
  String get dateText {
    final now = clock.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    final dateTime = toLocal();
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);
    if (date == today) {
      return 'Today';
    }
    if (date == yesterday) {
      return 'Yesterday';
    }

    return DateFormat('MMM d (E)', 'en').format(dateTime);
  }
}

/// Duration 向けの拡張機能 DurationExtension。
extension DurationExtension on Duration {
  /// 時間表示用文字列
  ///
  /// 60分以上は h:mm:ss、60分未満は mm:ssで表示する。
  /// e.g. 1:01:01、01:01
  String get hmmssText {
    final minutes = inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = inSeconds.remainder(60).toString().padLeft(2, '0');

    return inHours > 0 ? '$inHours:$minutes:$seconds' : '$minutes:$seconds';
  }
}
