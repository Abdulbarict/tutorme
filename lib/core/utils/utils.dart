import 'package:intl/intl.dart';

/// Date and time formatting helpers.
class DateUtils {
  DateUtils._();

  static final _dateFormatter = DateFormat('dd MMM yyyy');
  static final _timeFormatter = DateFormat('hh:mm a');
  static final _dateTimeFormatter = DateFormat('dd MMM yyyy, hh:mm a');
  static final _shortDate = DateFormat('dd MMM');
  static final _monthYear = DateFormat('MMMM yyyy');

  static String formatDate(DateTime date) => _dateFormatter.format(date);
  static String formatTime(DateTime date) => _timeFormatter.format(date);
  static String formatDateTime(DateTime date) =>
      _dateTimeFormatter.format(date);
  static String formatShort(DateTime date) => _shortDate.format(date);
  static String formatMonthYear(DateTime date) => _monthYear.format(date);

  /// Returns a human-readable relative label, e.g. "2 days ago", "Just now".
  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return formatDate(date);
  }

  /// Formats seconds into `mm:ss`, used for test timers.
  static String formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// Numeric formatting helpers.
class NumberUtils {
  NumberUtils._();

  /// Format percentage: `0.845` → `"84.5%"`.
  static String percent(double value, {int decimals = 1}) =>
      '${(value * 100).toStringAsFixed(decimals)}%';

  /// Compact large numbers: `1500` → `"1.5K"`.
  static String compact(int value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toString();
  }

  /// Format score display: `42/60`.
  static String score(int obtained, int total) => '$obtained/$total';
}

/// Text processing helpers.
class TextHelpers {
  TextHelpers._();

  /// Capitalise first letter of every word.
  static String toTitleCase(String text) => text
      .split(' ')
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');

  /// Truncate with ellipsis after [maxLength] characters.
  static String truncate(String text, {int maxLength = 80}) =>
      text.length <= maxLength ? text : '${text.substring(0, maxLength)}…';

  /// Sanitise a string to be used as a Firestore document ID.
  static String toFirestoreId(String text) => text
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]'), '_')
      .replaceAll(RegExp(r'_+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
}
