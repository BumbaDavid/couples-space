# CLAUDE.md

Project-level guidance for Claude Code working in this repository.

## What this project is

A two-person Android app (Flutter + Firebase) for a couple to share notes between
themselves, keep private notes, and track workouts. Authoritative design lives in
[docs/superpowers/specs/2026-05-26-couples-notes-app-design.md](docs/superpowers/specs/2026-05-26-couples-notes-app-design.md).
Read that spec before making non-trivial changes to the notes/pairing side — it covers
data model, pairing flow, screens, state management, and security rules in detail.
The workout tracker design lives in
[docs/design/design_feature_new/README.md](docs/design/design_feature_new/README.md).

## Stack

- **Flutter** — Android only for V1.
- **Firebase** — Auth (email/password) and Cloud Firestore. No Cloud Functions, no
  Firebase Storage in V1.
- **Riverpod** for state management (`flutter_riverpod` + `riverpod_annotation`).
- **go_router** for routing.
- **freezed** + **json_serializable** for immutable data classes.
- **google_fonts** for Baloo 2 (headings) and Quicksand (body/labels).

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

- iOS support, push notifications (FCM + Cloud Functions, Blaze plan), photo uploads
  (Firebase Storage), markdown rendering, accent-color / font customization, shared
  todos / calendar / love-notes, soft delete / undo, unpair flow, group sharing >2 members.

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

```
flutter build apk --release
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app 1:538976807059:android:aed5f6962c35be14414566 \
  --release-notes "What changed" \
  --testers "david.bumba0607@gmail.com,miruna.petrosanu@gmail.com"
```

Testers receive a push/email notification and install the update through the Firebase
App Tester companion app. No Play Store required.
