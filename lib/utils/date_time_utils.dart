import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class DateTimeUtils {
  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('HH:mm').format(dt);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  static DateTime combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  static bool isFutureDate(DateTime date) {
    return date.isAfter(DateTime.now());
  }

  static bool isPastDate(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  static String getRelativeTimeString(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years from now';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months from now';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days from now';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours from now';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes from now';
    } else {
      return 'Now';
    }
  }

  static String getDayOfWeek(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  static String getMonthName(DateTime date) {
    return DateFormat('MMMM').format(date);
  }

  static DateTime getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime getEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  static String formatForApi(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  static String formatForDisplay(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  static String formatTimeForDisplay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('h:mm a').format(dt);
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }

  static int getDaysDifference(DateTime date1, DateTime date2) {
    final difference = date1.difference(date2);
    return difference.inDays;
  }

  static DateTime addDays(DateTime date, int days) {
    return date.add(Duration(days: days));
  }

  static DateTime subtractDays(DateTime date, int days) {
    return date.subtract(Duration(days: days));
  }

  static bool isWeekend(DateTime date) {
    final day = date.weekday;
    return day == DateTime.saturday || day == DateTime.sunday;
  }

  static bool isWeekday(DateTime date) {
    return !isWeekend(date);
  }

  static String getRelativeDateString(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference == -1) {
      return 'Yesterday';
    } else if (difference > 0 && difference < 7) {
      return 'In $difference days';
    } else if (difference < 0 && difference > -7) {
      return '${difference.abs()} days ago';
    } else {
      return formatForDisplay(date);
    }
  }

  static TimeOfDay parseTimeOfDay(String timeString) {
    final format = DateFormat('HH:mm');
    final dt = format.parse(timeString);
    return TimeOfDay.fromDateTime(dt);
  }

  static DateTime parseDate(String dateString) {
    return DateFormat('yyyy-MM-dd').parse(dateString);
  }

  static bool isValidTimeRange(TimeOfDay start, TimeOfDay end) {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    return endMinutes > startMinutes;
  }

  static String getTimeRangeString(TimeOfDay start, TimeOfDay end) {
    return '${formatTime(start)} - ${formatTime(end)}';
  }

  static Duration getDurationBetween(DateTime start, DateTime end) {
    return end.difference(start);
  }

  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '$hours h $minutes min';
    } else {
      return '$minutes min';
    }
  }
}
