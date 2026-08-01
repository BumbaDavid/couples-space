# Feature idea: Personal reminders

**Discussed:** 2026-07-28
**Status:** Designed and spec'd — awaiting design handoff before implementation

## What it is

A personal reminders tab that lets each user schedule recurring local notifications
with a custom message. Not shared between partners — fully per-user.

Classic example: "Creatine time!" every day at 18:00.

## Key decisions

### Local notifications, not push
`flutter_local_notifications` only. No FCM, no Cloud Functions, no Blaze plan upgrade.
The phone schedules and fires the alarm itself. Works offline.

### On-device storage only
Reminder data is stored locally (not in Firestore). Reminders are lost on app
reinstall — the user accepted this trade-off for V1 simplicity.

### Navigation
A new 5th tab added to the bottom nav bar. The nav bar becomes horizontally
scrollable ("slider") to accommodate future tabs beyond 5.

### Reminder anatomy
Each reminder has exactly:
- **Message** — one text field. Used as both the list label and the notification body.
- **Time** — HH:MM time picker.
- **Days** — Mon through Sun, tap to toggle any combination. All reminders repeat
  weekly on the selected days. No "fire once" option.
- **Enabled toggle** — turn a reminder on/off without deleting it.

### Actions
Create · Edit · Delete · Enable/Disable per reminder.

### Notification tap
Opens the app to wherever the user last was. No deep-link to a specific screen (V1).

## Deferred to post-V1
- Reminders tied to app actions ("don't forget to log your workout") that deep-link
  to a specific screen when tapped.
- Syncing reminders across devices via Firestore.

## Implementation gotcha (for future reference)
Android clears all locally scheduled notifications when the phone reboots. The app
must re-schedule all active reminders on launch (and ideally via a boot broadcast
receiver). `flutter_local_notifications` supports this but it needs to be wired up
explicitly — easy to miss.

Android 13+ also requires the `POST_NOTIFICATIONS` runtime permission. The app must
request it before scheduling the first notification and handle denial gracefully.
