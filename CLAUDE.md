# CLAUDE.md

Project-level guidance for Claude Code working in this repository.

## What this project is

A two-person Android app (Flutter + Firebase) for a couple to share notes between
themselves and keep private notes for each user. Authoritative design lives in
[docs/superpowers/specs/2026-05-26-couples-notes-app-design.md](docs/superpowers/specs/2026-05-26-couples-notes-app-design.md).
Read that spec before making non-trivial changes — it covers data model, pairing flow,
screens, state management, and security rules in detail.

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
    └── profile/                   # display name, theme mode, sign out
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
