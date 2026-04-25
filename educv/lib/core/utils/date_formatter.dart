import 'package:intl/intl.dart';

class DateFormatter {
  // Common date formats
  static final DateFormat _displayFormat = DateFormat('MMM dd, yyyy');
  static final DateFormat _apiFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _fullFormat = DateFormat('MMMM dd, yyyy');
  static final DateFormat _shortFormat = DateFormat('MM/dd/yyyy');
  static final DateFormat _monthYearFormat = DateFormat('MMM yyyy');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _dateTimeFormat = DateFormat('MMM dd, yyyy HH:mm');

  // Format for display (e.g., "Jan 15, 2024")
  static String toDisplayFormat(DateTime date) {
    return _displayFormat.format(date);
  }

  // Format for API (e.g., "2024-01-15")
  static String toApiFormat(DateTime date) {
    return _apiFormat.format(date);
  }

  // Format for full display (e.g., "January 15, 2024")
  static String toFullFormat(DateTime date) {
    return _fullFormat.format(date);
  }

  // Format for short display (e.g., "01/15/2024")
  static String toShortFormat(DateTime date) {
    return _shortFormat.format(date);
  }

  // Format for month and year only (e.g., "Jan 2024")
  static String toMonthYearFormat(DateTime date) {
    return _monthYearFormat.format(date);
  }

  // Format time only (e.g., "14:30")
  static String toTimeFormat(DateTime date) {
    return _timeFormat.format(date);
  }

  // Format date and time (e.g., "Jan 15, 2024 14:30")
  static String toDateTimeFormat(DateTime date) {
    return _dateTimeFormat.format(date);
  }

  // Parse from API format
  static DateTime? fromApiFormat(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return _apiFormat.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  // Parse from display format
  static DateTime? fromDisplayFormat(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      return _displayFormat.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  // Get relative time (e.g., "2 hours ago", "Yesterday")
  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return years == 1 ? '1 year ago' : '$years years ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return months == 1 ? '1 month ago' : '$months months ago';
    } else if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return 'Yesterday';
      } else {
        return '${difference.inDays} days ago';
      }
    } else if (difference.inHours > 0) {
      return difference.inHours == 1 ? '1 hour ago' : '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return difference.inMinutes == 1 ? '1 minute ago' : '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  // Check if date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  // Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day;
  }

  // Get age from birth date
  static int getAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
}