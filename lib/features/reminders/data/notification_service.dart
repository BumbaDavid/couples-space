import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'reminder.dart';

/// Schedules and cancels local (on-device) weekly-recurring notifications
/// for [Reminder]s. No FCM, no server — everything is scheduled by the OS.
class NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const _channelId = 'reminders';
  static const _channelName = 'Reminders';

  static const _channel = AndroidNotificationChannel(
    _channelId,
    _channelName,
    importance: Importance.high,
  );

  Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();
    final timeZoneInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneInfo.identifier));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      const InitializationSettings(android: androidInit),
    );
    // The channel must exist BEFORE a scheduled notification fires. Alarms are
    // delivered to a background broadcast receiver, and on Android 8+ posting
    // to a non-existent channel is silently dropped — no notification, no
    // error. Creating it here (idempotent) is what makes delivery reliable.
    await _android?.createNotificationChannel(_channel);
    _initialized = true;
  }

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  Future<bool> requestPermission() async =>
      await _android?.requestNotificationsPermission() ?? false;

  Future<bool> hasPermission() async =>
      await _android?.areNotificationsEnabled() ?? false;

  /// Exact alarms need a separate, Settings-screen-only grant on Android 12+.
  /// Falling back to inexact scheduling still works, but the OS is then free
  /// to batch/delay firing by several minutes — noticeable on a reminder app.
  Future<bool> hasExactAlarmPermission() async =>
      await _android?.canScheduleExactNotifications() ?? true;

  Future<void> requestExactAlarmPermission() async =>
      _android?.requestExactAlarmsPermission();

  /// Cancels then re-schedules a reminder's OS notifications (one per
  /// selected weekday), or just cancels them when the reminder is disabled.
  Future<void> syncReminder(Reminder reminder) async {
    await cancelReminder(reminder.id);
    if (!reminder.enabled) return;
    final exact = await hasExactAlarmPermission();
    for (var dayIndex = 0; dayIndex < 7; dayIndex++) {
      if (!reminder.days[dayIndex]) continue;
      final weekday = dayIndex + 1; // DateTime.weekday: Monday=1..Sunday=7
      await _plugin.zonedSchedule(
        _notificationId(reminder.id, dayIndex),
        reminder.message,
        null,
        _nextInstanceOfWeekdayTime(weekday, reminder.hour, reminder.minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: exact
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  Future<void> cancelReminder(String reminderId) async {
    for (var dayIndex = 0; dayIndex < 7; dayIndex++) {
      await _plugin.cancel(_notificationId(reminderId, dayIndex));
    }
  }

  /// Re-schedules every reminder. Android clears all scheduled notifications
  /// on reboot, so this must run once on app launch.
  Future<void> rescheduleAll(List<Reminder> reminders) async {
    for (final reminder in reminders) {
      await syncReminder(reminder);
    }
  }

  /// Deterministic notification id from the reminder's string id + weekday
  /// index, kept well within the Android int32 notification id range.
  int _notificationId(String reminderId, int dayIndex) =>
      (reminderId.hashCode & 0xFFFFFF) * 10 + dayIndex;

  tz.TZDateTime _nextInstanceOfWeekdayTime(int weekday, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    while (scheduled.weekday != weekday || scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
