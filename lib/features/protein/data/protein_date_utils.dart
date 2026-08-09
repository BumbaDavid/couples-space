import 'package:intl/intl.dart';

/// Day/week helpers for the protein feature.
///
/// Grouped in a class rather than exposed as top-level functions so these
/// never collide with `workout_date_utils.dart`'s `weekStart` / `weekLabel`.
///
/// The canonical day key is `yyyy-MM-dd`. Every conversion between a
/// `DateTime` and that key lives here, so the format is defined in one place.
abstract class ProteinDates {
  static final DateFormat _key = DateFormat('yyyy-MM-dd');
  static final DateFormat _shortDay = DateFormat('EEE d MMM');
  static final DateFormat _shortRange = DateFormat('d MMM');
  static final DateFormat _full = DateFormat('EEEE d MMMM');

  /// `DateTime` → `yyyy-MM-dd`, discarding the time component.
  static String dayKey(DateTime date) => _key.format(date);

  /// `yyyy-MM-dd` → local midnight `DateTime`.
  static DateTime fromDayKey(String key) => _key.parseStrict(key);

  static DateTime today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Whole days between [date] and today. 0 = today, 1 = yesterday.
  static int daysAgo(DateTime date) =>
      today().difference(DateTime(date.year, date.month, date.day)).inDays;

  /// Screen title: "Today", "Yesterday", or "Sat 1 Aug".
  static String dayTitle(DateTime date) => switch (daysAgo(date)) {
    0 => 'Today',
    1 => 'Yesterday',
    _ => _shortDay.format(date),
  };

  /// Under the ring: "logged today" / "logged yesterday" / "logged that day".
  static String loggedLabel(DateTime date) => switch (daysAgo(date)) {
    0 => 'logged today',
    1 => 'logged yesterday',
    _ => 'logged that day',
  };

  /// Log section heading: "TODAY'S LOG" on today, "THE LOG" otherwise.
  static String logHeading(DateTime date) =>
      daysAgo(date) == 0 ? "TODAY'S LOG" : 'THE LOG';

  /// Full date for the entry editor: "Saturday 1 August".
  static String fullDate(DateTime date) => _full.format(date);

  /// Monday of [date]'s week, at midnight.
  static DateTime weekStart(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return DateTime(monday.year, monday.month, monday.day);
  }

  /// Sunday of the week beginning [start], at midnight.
  static DateTime weekEnd(DateTime start) =>
      start.add(const Duration(days: 6));

  /// "This week", or "28 Jul – 3 Aug".
  static String weekLabel(DateTime start) {
    if (start == weekStart(DateTime.now())) return 'This week';
    final end = weekEnd(start);
    return '${_shortRange.format(start)} – ${_shortRange.format(end)}';
  }

  /// The seven day keys of the week beginning [start], Monday first.
  static List<String> weekDayKeys(DateTime start) =>
      List.generate(7, (i) => dayKey(start.add(Duration(days: i))));

  /// True when [date] is today or later — used to make the forward arrow inert.
  static bool isTodayOrLater(DateTime date) => daysAgo(date) <= 0;

  /// True when [start] is the current week or later.
  static bool isCurrentWeekOrLater(DateTime start) =>
      !start.isBefore(weekStart(DateTime.now()));
}
