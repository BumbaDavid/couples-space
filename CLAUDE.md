# CLAUDE.md

Project-level guidance for Claude Code working in this repository.

## What this project is

A two-person Android app (Flutter + Firebase) for a couple to share notes between
themselves, keep private notes, track workouts, and set personal reminders.
Authoritative design lives in
[docs/superpowers/specs/2026-05-26-couples-notes-app-design.md](docs/superpowers/specs/2026-05-26-couples-notes-app-design.md).
Read that spec before making non-trivial changes to the notes/pairing side — it covers
data model, pairing flow, screens, state management, and security rules in detail.
The workout tracker design lives in
[docs/design/design_feature_new/README.md](docs/design/design_feature_new/README.md).
The reminders design lives in
[docs/design/design_reminder/README.md](docs/design/design_reminder/README.md).

## Stack

- **Flutter** — Android only for V1.
- **Firebase** — Auth (email/password) and Cloud Firestore. No Cloud Functions, no
  Firebase Storage in V1.
- **Riverpod** for state management (`flutter_riverpod` + `riverpod_annotation`).
- **go_router** for routing.
- **freezed** + **json_serializable** for immutable data classes.
- **google_fonts** for Baloo 2 (headings) and Quicksand (body/labels).
- **flutter_local_notifications** + **timezone** + **flutter_timezone** for reminders
  (on-device scheduling only — no FCM, no Blaze plan).
- **shared_preferences** for the reminders' local storage.

## Project layout (feature-first)

```
lib/
├── main.dart
├── app.dart                       # MaterialApp, router, theme
├── core/
│   ├── firebase/                  # Firebase init + instances
│   └── widgets/                   # shared UI bits
└── features/
    ├── auth/                      # email/password sign-up + sign-in
    ├── pairing/                   # invite-code generate / enter
    ├── shared_notes/              # shared notes list + editor
    ├── private_notes/             # per-user private notes
    ├── profile/                   # display name, theme mode, sign out
    ├── reminders/                 # local recurring notifications (no Firestore)
    │   ├── data/                  # reminder.dart (freezed model + repeatLabel)
    │   │   ├── notification_service.dart   # flutter_local_notifications wrapper
    │   │   └── reminder_repository.dart    # shared_preferences CRUD + stream
    │   ├── providers/             # reminder_providers.dart
    │   └── ui/                    # reminders_list, reminder_editor screens
    └── workout/
        ├── data/                  # models (Exercise, WorkoutEntry, WorkoutDay, WorkoutSet)
        │   ├── workout_repository.dart
        │   ├── workout_icons.dart # body-part list, icon map, isEndurance()
        │   └── workout_date_utils.dart
        ├── providers/             # workout_providers.dart
        └── ui/                    # exercise_list, exercise_detail, add_entry,
                                   # add_exercise, pick_exercises screens
```

Each feature directory owns its UI, repository (Firestore wrapper), and Riverpod
providers. The note-editor UI is shared between `shared_notes` and `private_notes` —
it takes a repository as a parameter rather than knowing which kind of note it edits.
`reminders/` is the one exception to "repository == Firestore wrapper": it is backed by
`shared_preferences`, not Firestore.

The bottom nav (`core/widgets/home_shell.dart`) is a **horizontally scrollable** custom
bar, not a Material `NavigationBar` — tab count is expected to keep growing, and a fixed
bar shrinks items to fit. Add new tabs to the `_tabs` list and the `_body()` switch.

## Data model invariants

- Shared notes live at `couples/{coupleId}/sharedNotes/{noteId}` — **not** under a user.
- Private notes live at `users/{userId}/privateNotes/{noteId}` — never under a couple.
- `users/{userId}.coupleId` is a denormalized cache. The authoritative source of pairing
  is `couples/{coupleId}.memberIds`. The auth gate is responsible for backfilling
  `users/me.coupleId` if it's null but a matching couple exists (see Pairing Flow in the
  spec).
- Notes sort by `updatedAt` descending in lists.
- Either partner can edit any shared note. `authorId` is for display only, not permission.

### Workout feature paths

- Exercises: `users/{userId}/exercises/{exerciseId}`
- Workout entries: `users/{userId}/workoutEntries/{entryId}`
- Workout days: `users/{userId}/days/{dayId}`
- An exercise belongs to zero or more days via `dayIds: List<String>`. Use
  `FieldValue.arrayUnion` / `FieldValue.arrayRemove` to update membership; query with
  `arrayContains`. Old documents missing `dayIds` default to `[]` (backward compatible).
- Exercise type (strength vs endurance) is derived from `bodyPart` via
  `WorkoutIcons.isEndurance(bodyPart)` — no separate type field. Endurance body part is
  `"Endurance"` (legacy Firestore docs may have `"Cardio"`; `isEndurance()` matches both).
- Endurance entries have `durationMinutes` set and `sets` empty. Strength entries have
  `sets` non-empty and `durationMinutes` null.
- Endurance exercises are excluded from weekly progress stats (reps, volume).

### Reminders — local only, never Firestore

- Reminders are stored **on-device** in `shared_preferences` under the key `reminders`
  (a `List<String>` of JSON blobs). They are per-user, never shared with the partner,
  and are lost on uninstall / clear-data. This is deliberate — do not "improve" it by
  syncing to Firestore without asking.
- A reminder is `{id, message, hour, minute, days: List<bool> (len 7, 0=Mon), enabled}`.
  `message` is both the list label and the notification title.
- All reminders repeat **weekly** on the selected days. There is no fire-once option.
- One OS notification is scheduled per selected weekday, id =
  `(reminderId.hashCode & 0xFFFFFF) * 10 + dayIndex`. Changing that formula orphans
  every already-scheduled alarm.
- `ReminderRepository` mutations must keep prefs and the OS alarms in sync — every
  create/update/delete/toggle calls `NotificationService.syncReminder` or
  `cancelReminder`.

## Android notification requirements (easy to break)

These are load-bearing. Removing any of them breaks reminders **silently** — the alarm
fires, nothing appears, and nothing is logged.

- `AndroidManifest.xml` **must** declare `ScheduledNotificationReceiver` and
  `ScheduledNotificationBootReceiver`. `flutter_local_notifications` does *not* declare
  them itself; without them a fired alarm has no receiver to broadcast to.
- The notification channel is created explicitly in `NotificationService.init()`.
  Posting to a channel that doesn't exist is silently dropped on Android 8+.
- Permissions: `POST_NOTIFICATIONS` (runtime, Android 13+), `SCHEDULE_EXACT_ALARM`
  (granted only via a Settings screen, Android 12+), `RECEIVE_BOOT_COMPLETED`.
- Android clears scheduled alarms on reboot, so `main.dart` re-arms everything via
  `reminderRepository.rescheduleAll()` at startup; the boot receiver covers the rest.
- `isCoreLibraryDesugaringEnabled = true` plus the `desugar_jdk_libs` dependency in
  `android/app/build.gradle.kts` are required by the plugin.
- **Force-stopping the app cancels all its alarms** (Android policy). They come back the
  next time the app is opened. Nothing to fix — just know it when debugging.

To verify scheduling on a device:
`adb shell dumpsys alarm | grep -A2 ScheduledNotificationReceiver`

## Security rules

Security is enforced by Firestore rules — there is no server-side middleware. **Treat the
rules file as production code.** Any change to it needs an emulator-based rules test
proving both the positive case (allowed access works) and the negative case (forbidden
access is denied).

Specifically:
- Never relax `users/{userId}` writes to allow non-self updates. The pairing flow is
  designed around this constraint; don't "fix" it by loosening rules.
- Never add a rule that reads or writes across couples.

## Conventions

- **Imports:** prefer relative imports within a feature, package imports across features.
- **Models:** all Firestore documents decode through freezed classes; no raw `Map`s in UI.
- **Streams:** UI watches `StreamProvider`s wrapped around Firestore `snapshots()`;
  repositories never return raw `Stream<QuerySnapshot>` to widgets.
- **Errors:** repositories throw typed exceptions; UI converts to user-visible messages
  at the screen boundary.
- **Auto-save:** the note editor auto-saves on back-navigation. If both title and body
  are empty, the note is discarded instead of saved.
- **Deletes are hard deletes** with a confirmation dialog. No soft-delete, no undo in V1.
- **Colors and shadows:** never use raw hex values in UI code. Use `AppColors.*` for
  colors, `AppTheme.cardShadow` / `AppTheme.buttonShadow` for shadows, and
  `AppColors.tilePalette[i % 5]` for exercise icon tile colors. Design tokens live in
  `lib/core/theme/theme.dart`.

## Testing

- Only write tests when explicitly asked — never as an automatic byproduct of a code change.
- Unit-test repositories with `fake_cloud_firestore`.
- Firestore-rules tests via the Firebase emulator — at least one allow and one deny case
  per `match` block.
- Manual smoke testing on a real Android device covers the rest. No widget tests in V1.

## Claude behavior

- **No subagents:** Solve tasks using the main agent only. Do not spawn subagents or
  parallel agents unless explicitly asked.
- **No auto-generated tests:** Never write tests as part of a code change unless
  explicitly asked. The Testing section describes how to write them when requested.
- **Obsidian vault:** Before adding anything to `docs/vault/`, ask first.
- **Git:** Never commit or push to GitHub unless explicitly asked. Fetching and pulling
  to compare is fine.

## Things deferred to post-V1 — do not add them speculatively

- iOS support, **server-sent push** notifications (FCM + Cloud Functions, Blaze plan),
  photo uploads (Firebase Storage), markdown rendering, accent-color / font
  customization, shared todos / calendar / love-notes, soft delete / undo, unpair flow,
  group sharing >2 members.
- Reminders specifically: deep-linking a notification tap to a screen (e.g. "log your
  workout" → exercise list), and syncing reminders across devices via Firestore.

Note: *local* notifications are shipped (the reminders feature). It is only **FCM /
server-pushed** notifications that remain deferred — those are what need the Blaze plan.

If a task seems to require one of these, ask first — it likely means scope has expanded
beyond V1.

## Maintenance

Keep this file up to date as the project evolves. Update it when conventions change,
new patterns are established, scope shifts, or new tooling is added.

## Useful commands

```
flutter pub get                       # install dependencies
flutter run                           # run on a connected Android device / emulator
flutter analyze                       # static analysis
flutter test                          # unit tests
firebase emulators:start              # run Auth + Firestore emulators locally
```

### Distributing an update (Firebase App Distribution)

Bump `version:` in `pubspec.yaml` first — reusing a version leaves two releases
indistinguishable in the tester app. (`1.0.0+1` → workouts, `1.1.0+2` → reminders.)

```
flutter build apk --release
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app 1:538976807059:android:aed5f6962c35be14414566 \
  --release-notes "What changed" \
  --testers "david.bumba0607@gmail.com,miruna.petrosanu@gmail.com"
```

Testers receive a push/email notification and install the update through the Firebase
App Tester companion app. No Play Store required.
