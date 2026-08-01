import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'notification_service.dart';
import 'reminder.dart';

/// Reminders are stored on-device only (not Firestore) — per the design
/// decision, they are personal and not shared between partners, and are
/// lost on reinstall.
class ReminderRepository {
  // Public param names (prefs/notifications) can't match the private fields
  // they populate, so this can't use initializing formals.
  ReminderRepository({
    required SharedPreferences prefs,
    required NotificationService notifications,
    // ignore: prefer_initializing_formals
  })  : _prefs = prefs,
        // ignore: prefer_initializing_formals
        _notifications = notifications {
    _reminders = _load();
    _controller = StreamController<List<Reminder>>.broadcast(
      onListen: () => _emit(),
    );
  }

  static const _key = 'reminders';
  static const _uuid = Uuid();

  final SharedPreferences _prefs;
  final NotificationService _notifications;
  late List<Reminder> _reminders;
  late final StreamController<List<Reminder>> _controller;

  Stream<List<Reminder>> watchAll() => _controller.stream;

  List<Reminder> _load() {
    final raw = _prefs.getStringList(_key) ?? [];
    return raw
        .map((s) => Reminder.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  Future<void> _persist() async {
    await _prefs.setStringList(
      _key,
      _reminders.map((r) => jsonEncode(r.toJson())).toList(),
    );
    _emit();
  }

  void _emit() {
    if (!_controller.isClosed) _controller.add(List.unmodifiable(_reminders));
  }

  Future<void> rescheduleAll() => _notifications.rescheduleAll(_reminders);

  Future<void> create({
    required String message,
    required int hour,
    required int minute,
    required List<bool> days,
  }) async {
    final reminder = Reminder(
      id: _uuid.v4(),
      message: message.trim().isEmpty ? 'Reminder' : message.trim(),
      hour: hour,
      minute: minute,
      days: days,
    );
    _reminders = [..._reminders, reminder];
    await _persist();
    await _notifications.syncReminder(reminder);
  }

  Future<void> update(Reminder reminder) async {
    _reminders = [
      for (final r in _reminders)
        if (r.id == reminder.id) reminder else r,
    ];
    await _persist();
    await _notifications.syncReminder(reminder);
  }

  Future<void> setEnabled(String id, bool enabled) async {
    final reminder = _reminders.firstWhere((r) => r.id == id);
    await update(reminder.copyWith(enabled: enabled));
  }

  Future<void> delete(String id) async {
    _reminders = _reminders.where((r) => r.id != id).toList();
    await _persist();
    await _notifications.cancelReminder(id);
  }
}
