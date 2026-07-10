import 'package:intl/intl.dart';

String formatEntryDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(date.year, date.month, date.day);
  final diff = today.difference(day).inDays;
  if (diff == 0) return 'Today';
  return DateFormat('MMM d').format(date);
}

DateTime weekStart(DateTime date) {
  final monday = date.subtract(Duration(days: date.weekday - 1));
  return DateTime(monday.year, monday.month, monday.day);
}

DateTime weekEnd(DateTime start) =>
    start.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

String weekLabel(DateTime start) {
  final currentStart = weekStart(DateTime.now());
  if (start == currentStart) return 'This week';
  final end = start.add(const Duration(days: 6));
  final fmt = DateFormat('MMM d');
  return '${fmt.format(start)} – ${fmt.format(end)}';
}
