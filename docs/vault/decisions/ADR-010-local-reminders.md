# ADR-010: Local reminders (notifications without a server)

**Date:** 2026-08-01
**Status:** Accepted — shipped in release 1.1.0 (2)

## Decision

Personal reminders fire via **on-device local notifications**
(`flutter_local_notifications`), stored in `shared_preferences`. No FCM, no Cloud
Functions, no Blaze plan, no Firestore involvement.

Scope and UX decisions were settled in [[reminders-feature]]; design handoff lives at
`docs/design/design_reminder/README.md`. This ADR records the *implementation*
decisions and the failure modes discovered while building it.

## Why local, not push

The app has two users and the reminders are personal, not shared. A server round-trip
would buy nothing and would force a paid Firebase plan. The phone can schedule its own
alarms, works offline, and costs nothing.

## Architecture

| Piece | Role |
|-------|------|
| `Reminder` (freezed) | `{id, message, hour, minute, days[7], enabled}` |
| `NotificationService` | Wraps the plugin: init, permissions, schedule/cancel |
| `ReminderRepository` | `shared_preferences` CRUD + broadcast stream; keeps OS alarms in sync on every mutation |
| `reminder_providers.dart` | `notificationServiceProvider` / `reminderRepositoryProvider` are **overridden in `main.dart`** because both need async setup before `runApp` |

One OS notification is scheduled **per selected weekday** (up to 7 per reminder), using
`matchDateTimeComponents: DayOfWeekAndTime` so each repeats weekly. Notification id is
`(reminderId.hashCode & 0xFFFFFF) * 10 + dayIndex` — deterministic, so cancels find the
same ids. Changing that formula orphans every scheduled alarm.

## Failure modes found the hard way

All three of these break reminders **silently** — the alarm fires, no notification
appears, and nothing is written to logcat. Worth knowing they exist.

1. **Undeclared broadcast receivers (the actual root cause).**
   `flutter_local_notifications` does not declare its own receivers; its plugin manifest
   contains only permissions. The app must declare `ScheduledNotificationReceiver` and
   `ScheduledNotificationBootReceiver`. Without them the alarm fires, Android finds no
   registered receiver, drops the broadcast, and consumes the alarm.
2. **Missing notification channel.** On Android 8+, posting to a channel that doesn't
   exist is silently dropped. The channel is now created explicitly in
   `NotificationService.init()` rather than relied on to appear lazily — scheduled
   notifications are posted from a background receiver, which is the worst place to
   discover a missing channel.
3. **Inexact alarms.** `inexactAllowWhileIdle` lets Android batch/delay firing by
   minutes. Acceptable for most apps, wrong for a reminder. Now uses
   `exactAllowWhileIdle` when `SCHEDULE_EXACT_ALARM` is granted, falling back to inexact
   otherwise.

### Diagnosing this class of bug

Since nothing logs, inspect OS state directly:

```bash
adb shell dumpsys alarm | grep -A2 ScheduledNotificationReceiver   # is it scheduled?
adb shell dumpsys notification | grep -A3 couplesspace             # channel + posted
adb shell dumpsys package <pkg> | grep ScheduledNotification       # receiver registered?
```

A useful tell: if an alarm *disappears* from the pending list after its fire time but no
notification appeared, the alarm fired and delivery failed downstream.

## Platform behaviour worth remembering

- **The app does not need to be running.** Alarms live in the OS `AlarmManager`; Android
  cold-starts the app process to run the receiver. Verified with the process killed.
- **Reboot** clears scheduled alarms. Covered by `rescheduleAll()` on launch plus the
  boot receiver (`RECEIVE_BOOT_COMPLETED`).
- **Force-stop cancels all of an app's alarms** — Android policy, not a bug. They are
  re-armed next launch.
- **App updates do not** clear alarms or data.
- Android 13+ needs runtime `POST_NOTIFICATIONS`; Android 12+ needs
  `SCHEDULE_EXACT_ALARM`, which can only be granted through a Settings screen. The
  reminders list shows a banner for each.

## Trade-offs

- Reminders are lost on uninstall / clear-data, and don't sync between devices. Accepted
  for V1.
- `rescheduleAll()` arms reminders sequentially (~10s for 21 alarms) and is not wrapped
  in per-reminder error handling — one throwing reminder would stop the rest from being
  armed. Known gap, not yet hardened.
- Deriving one notification per weekday means up to 7 OS alarms per reminder. Fine at
  this scale; would need rethinking with dozens of reminders.
