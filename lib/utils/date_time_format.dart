import 'package:intl/intl.dart';

String formatDateTime(String isoString) {
  try {
    final dateTime = DateTime.parse(
      isoString,
    ).toLocal(); // Convert to local timezone
    return DateFormat(
      'EEE, MMM d, y',
    ).format(dateTime); // Output: Sat, Sep 6, 2025
  } catch (e) {
    return isoString; // fallback in case of parsing error
  }
}


// i need like 
