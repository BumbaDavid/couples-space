# Feature idea: Personal reminders

**Discussed:** 2026-07-28
**Status:** ✅ Implemented and shipped in release 1.1.0 (2) on 2026-07-28.
Implementation decisions and platform gotchas are recorded in [[ADR-010-local-reminders]].
This note is kept as the record of *why* the feature is shaped the way it is.

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

## Implementation gotchas (anticipated vs. actual)

Anticipated before building, and both real:
- Android clears scheduled notifications on reboot — handled by `rescheduleAll()` on
  launch plus a boot receiver.
- Android 13+ requires the `POST_NOTIFICATIONS` runtime permission.

The one that actually broke it was **not** on this list: `flutter_local_notifications`
does not declare its own broadcast receivers, so the app must declare them in
`AndroidManifest.xml`. Without them the alarm fires and the notification is dropped
silently — no notification, no log entry. See [[ADR-010-local-reminders]] for the full
set of silent failure modes and how to diagnose them with `adb dumpsys`.
