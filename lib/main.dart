import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:couples_space/app.dart';
import 'package:couples_space/features/reminders/data/notification_service.dart';
import 'package:couples_space/features/reminders/data/reminder_repository.dart';
import 'package:couples_space/features/reminders/providers/reminder_providers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  final prefs = await SharedPreferences.getInstance();
  final notificationService = NotificationService();
  await notificationService.init();

  final reminderRepository = ReminderRepository(
    prefs: prefs,
    notifications: notificationService,
  );
  // Android clears all scheduled notifications on reboot, so enabled
  // reminders must be re-scheduled every time the app launches.
  await reminderRepository.rescheduleAll();

  runApp(ProviderScope(
    overrides: [
      notificationServiceProvider.overrideWithValue(notificationService),
      reminderRepositoryProvider.overrideWithValue(reminderRepository),
    ],
    child: const CouplesNotesApp(),
  ));
}
