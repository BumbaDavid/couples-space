import 'package:freezed_annotation/freezed_annotation.dart';

part 'reminder.freezed.dart';
part 'reminder.g.dart';

@freezed
abstract class Reminder with _$Reminder {
  const factory Reminder({
    required String id,
    required String message,
    required int hour,
    required int minute,
    @Default([false, false, false, false, false, false, false])
    List<bool> days,
    @Default(true) bool enabled,
  }) = _Reminder;

  factory Reminder.fromJson(Map<String, dynamic> json) =>
      _$ReminderFromJson(json);
}

const _shortDayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

extension ReminderX on Reminder {
  /// Precedence: all days -> "Every day", none -> "No days", Mon-Fri only ->
  /// "Weekdays", Sat+Sun only -> "Weekends", otherwise comma-joined names.
  String get repeatLabel {
    if (days.every((d) => d)) return 'Every day';
    if (days.every((d) => !d)) return 'No days';
    final weekdays = days.sublist(0, 5);
    final weekend = days.sublist(5);
    if (weekdays.every((d) => d) && weekend.every((d) => !d)) {
      return 'Weekdays';
    }
    if (weekend.every((d) => d) && weekdays.every((d) => !d)) {
      return 'Weekends';
    }
    return [
      for (var i = 0; i < 7; i++)
        if (days[i]) _shortDayNames[i],
    ].join(', ');
  }

  String get timeLabel =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}
