import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy HH:mm').format(dateTime);
  }

  static String formatShortDate(DateTime dateTime) {
    return DateFormat('MMM dd').format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // Additional formatters referenced in the codebase
  static String toDateTimeFormat(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  static String toDisplayFormat(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy').format(dateTime);
  }

  static String toFullFormat(DateTime dateTime) {
    return DateFormat('EEEE, MMMM dd, yyyy').format(dateTime);
  }

  static String getRelativeTime(DateTime dateTime) {
    return formatRelativeTime(dateTime);
  }

  static String fileDate(DateTime dateTime) {
    return DateFormat('yyyyMMdd_HHmmss').format(dateTime);
  }
}