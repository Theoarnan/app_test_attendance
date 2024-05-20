import 'package:intl/intl.dart';

class UtilHelper {
  /// Format date now
  static String formatDateNow() {
    final date = DateTime.now();
    return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date);
  }

  static DateTime parseDateTime(String dateTimeString) {
    return DateTime.parse(dateTimeString);
  }

  static String formatDateTime(DateTime dateTime) {
    final DateFormat formatter = DateFormat('hh:mm a');
    return formatter.format(dateTime);
  }

  static String getTotalHours(String clockInString, String clockOutString) {
    DateTime clockInTime = DateTime.parse(clockInString);
    DateTime clockOutTime = DateTime.parse(clockOutString);

    // Calculate the difference
    Duration difference = clockOutTime.difference(clockInTime);

    // Get the total hours and minutes
    double totalHours = difference.inMinutes / 60.0;
    return totalHours.floor().toString();
  }
}
