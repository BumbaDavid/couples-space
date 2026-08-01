import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/notification_service.dart';
import '../data/reminder.dart';
import '../data/reminder_repository.dart';

/// Overridden in main.dart with the instance created at startup (needs an
/// async SharedPreferences load + timezone init before first use).
final notificationServiceProvider = Provider<NotificationService>((ref) {
  throw UnimplementedError('notificationServiceProvider not overridden');
});

final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  throw UnimplementedError('reminderRepositoryProvider not overridden');
});

final remindersProvider = StreamProvider<List<Reminder>>((ref) {
  return ref.watch(reminderRepositoryProvider).watchAll();
});

final notificationPermissionProvider = FutureProvider.autoDispose<bool>((ref) {
  return ref.watch(notificationServiceProvider).hasPermission();
});

final exactAlarmPermissionProvider = FutureProvider.autoDispose<bool>((ref) {
  return ref.watch(notificationServiceProvider).hasExactAlarmPermission();
});
