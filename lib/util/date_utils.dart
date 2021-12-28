import 'package:intl/intl.dart';

class CustomDateUtils {

  static DateTime backOneWeek(DateTime date) {
    return date.subtract(Duration(days: 7));
  }

  static DateTime forwardOneWeek(DateTime date) {
    return date.add(Duration(days: 7));
  }

  static DateTime startOfWeek(DateTime date) {
    date = DateTime(date.year, date.month, date.day, 0, 0, 0); // set to midnight
    return date.subtract(Duration(days: date.weekday - 1));
  }

  static DateTime endOfWeek(DateTime date) {
    date = DateTime(date.year, date.month, date.day, 23, 59, 59);
    return date.add(Duration(days: 7 - date.weekday));
  }

  static String formatWeekRange(DateTime date) {
    DateFormat formatter = DateFormat('MMMd');
    return formatter.format(startOfWeek(date)) + ' - ' + formatter.format(endOfWeek(date));
  }
}