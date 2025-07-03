import 'package:intl/intl.dart';

/// Utility class for formatting dates
class DateFormatter {
  /// Format a date to a readable string
  static String formatDate(DateTime date) {
    final formatter = DateFormat('yyyy-MM-dd HH:mm');
    return formatter.format(date);
  }
  
  /// Format a date to a readable string with only the date
  static String formatDateOnly(DateTime date) {
    final formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(date);
  }
  
  /// Format a date to a readable string with only the time
  static String formatTimeOnly(DateTime date) {
    final formatter = DateFormat('HH:mm');
    return formatter.format(date);
  }
  
  /// Format a date to a relative string (e.g. "2 days ago")
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} ${(difference.inDays / 365).floor() == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} ${(difference.inDays / 30).floor() == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
}
