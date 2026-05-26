---
title: Couples Notes App — Design
date: 2026-05-26
status: approved
---

# Couples Notes App — Design

A small Android app for two people (a couple) to share notes with each other and keep
private notes for themselves. Each user has their own account; data is partitioned per
couple via a shared `coupleId`.

## Goals

- A working V1 that two specific users (the author and his girlfriend) can install on
  their Android phones and use daily.
- Clear separation between **shared** data (visible to both) and **private** data
  (visible only to the owning user), enforced at the database layer, not by convention.
- Foundation that can be extended later (more feature pages, push notifications,
  iOS support) without re-architecting.

## Non-Goals (V1)

- iOS support. Android only.
- Push notifications.
- Photo / media uploads (no Firebase Storage usage).
- Markdown / rich text formatting.
- Group sharing with more than two members.
- Soft-delete / undo / version history.

## Scope (V1)

- Email/password authentication (Firebase Auth).
- Invite-code pairing into a couple.
- Shared notes between the two paired users.
- Per-user private notes.
- Minimal profile: display name + per-user theme mode (light/dark/system).
- Offline cache (Firestore native persistence).

## Tech Stack

- **Frontend:** Flutter (Android target only for V1).
- **Backend:** Firebase — Auth + Cloud Firestore. No Cloud Functions in V1.
- **State management:** Riverpod (`flutter_riverpod` + `riverpod_annotation`).
- **Routing:** `go_router`.
- **Data classes:** `freezed` + `json_serializable`.
- **Other packages:** `share_plus` (invite-code share sheet), `intl` (timestamp formatting).

## Data Model (Firestore)

```
users/{userId}
  displayName: string
  email: string
  coupleId: string | null         # null until paired
  themeMode: 'light' | 'dark' | 'system'
  createdAt: timestamp

couples/{coupleId}
  memberIds: [userId, userId]
  createdAt: timestamp

couples/{coupleId}/sharedNotes/{noteId}
  title: string
  body: string
  authorId: userId                # for "David wrote this" display
  createdAt: timestamp
  updatedAt: timestamp

users/{userId}/privateNotes/{noteId}
  title: string
  body: string
  createdAt: timestamp
  updatedAt: timestamp

inviteCodes/{code}                # e.g. "K7P2QX"
  createdBy: userId
  createdAt: timestamp
  expiresAt: timestamp            # 24h from creation
```

### Why this shape

- Shared notes live as a **subcollection under the couple**, not under a user. This makes
  "shared by coupleId" a real storage-level concept, not just a filter, and security
  rules are simple.
- Private notes live under the user. They are never reachable through a couple path.
- `inviteCodes` is top-level so a not-yet-paired second user can validate a code before
  they have a coupleId.
- Notes carry both `createdAt` and `updatedAt`. Lists are sorted by `updatedAt` desc.

## Pairing Flow

Security rules forbid one user from writing another user's doc. The pairing is therefore
**two-phase with self-healing denormalization**: the claiming user (B) writes everything
they're allowed to write; the inviting user (A) backfills their own user doc when their
app observes the new couple.

1. User A signs up — `users/A` is created with `coupleId: null`.
2. User A taps "Invite partner" — app generates a 6-character code (uppercase
   alphanumeric, ambiguous chars excluded), writes `inviteCodes/{code}` with `createdBy: A`,
   `expiresAt: now + 24h`, and displays the code with a share button (`share_plus`).
3. User B signs up on their phone — `users/B` is created with `coupleId: null`.
4. User B taps "Enter partner's code" and submits the code.
5. B's app validates the code client-side: read `inviteCodes/{code}`, reject if missing,
   expired, or `createdBy == B`.
6. B's app runs an atomic Firestore batch:
   - Create `couples/{newCoupleId}` with `memberIds: [A, B]`.
   - Set `coupleId` on `users/B` (allowed — B is writing their own doc).
   - Delete `inviteCodes/{code}`.
7. A's app — wherever it next runs the auth gate — executes a query:
   `couples where memberIds contains request.auth.uid limit 1`. If a couple is found and
   `users/A.coupleId` is still null, A's app writes its own `coupleId` to `users/A`
   (allowed — A is writing their own doc). A is now fully paired.

The "atomic" guarantee is on the things B writes (step 6). A's user-doc backfill (step 7)
is eventually consistent — A is paired the moment their app next syncs. The auth gate
treats "a couple exists for me" as authoritative; the `coupleId` field on `users/A` is a
denormalized cache that gets repaired automatically.

## App Architecture

### Folder layout (feature-first)

```
lib/
├── main.dart
├── app.dart                       # MaterialApp, router, theme
├── core/
│   ├── firebase/                  # init, instances
│   └── widgets/                   # shared UI bits
└── features/
    ├── auth/                      # sign-up, sign-in
    ├── pairing/                   # generate / enter invite code
    ├── shared_notes/              # list + editor (shared)
    ├── private_notes/             # list + editor (private)
    └── profile/                   # display name, theme mode, sign out
```

Each feature directory contains its UI, its repository (Firestore wrapper), and its
Riverpod providers. The note-editor UI is reused across `shared_notes` and `private_notes`
— it accepts a repository as a parameter rather than knowing which kind of note it edits.

### Screens (V1)

1. **Splash / auth gate** — listens to `authStateChanges()` and the current user doc.
   When the user is signed in but `users/me.coupleId` is null, also queries
   `couples where memberIds contains me`; if a couple is found, writes the discovered
   `coupleId` back onto `users/me` (the pairing backfill described in Pairing Flow).
   Routes to auth, pairing, or home based on the resulting state.
2. **Sign up / Sign in** — email + password, mode toggle.
3. **Pairing — start** — "Generate invite code" or "Enter partner's code".
4. **Pairing — code displayed** — shows the 6-char code, share button, waiting state.
5. **Pairing — enter code** — text field, validation errors inline.
6. **Home** — bottom nav with three tabs:
   - **Shared** — list of shared notes, newest-updated first, FAB to add. Each row shows
     title, body snippet, author display name, relative updated time.
   - **Private** — same shape, owner-only notes.
   - **Profile** — editable display name; partner's display name (read-only); theme-mode
     selector (light/dark/system); sign-out button.
7. **Note editor** — full-screen, title field + body field. Auto-save on back. Delete
   action in the app bar (hard delete, confirmation dialog).

### State / data flow

```
Screen widget
  └── watches Riverpod provider
        └── calls Repository method
              └── Firestore stream / write
```

Example: the shared-notes list watches a `StreamProvider<List<Note>>` that wraps
`firestore.collection('couples/{id}/sharedNotes').orderBy('updatedAt', desc).snapshots()`.
When the partner adds a note, the stream emits and the UI rebuilds. No polling.

### Behavior decisions

- **Either partner can edit any shared note.** `authorId` is tracked for display only,
  not for permission enforcement.
- **Hard delete.** Deletes remove the document. A snackbar confirms; no undo.
- **Auto-save on back-navigation from the note editor.** If both title and body are empty,
  the note is discarded instead.
- **Offline cache enabled** via Firestore persistence. Reads serve from cache when offline;
  writes are queued locally and sync on reconnect.

### Theming

- A single `MaterialApp` reads the current user's `themeMode` field via a Riverpod
  provider and applies `ThemeMode.light | dark | system`.
- Light and dark themes are both `ColorScheme.fromSeed(...)` with a single fixed seed
  color for V1. Per-user accent colors are deferred.

## Security Rules

```
service cloud.firestore {
  match /databases/{database}/documents {

    function isSignedIn() {
      return request.auth != null;
    }
    function isSelf(userId) {
      return isSignedIn() && request.auth.uid == userId;
    }
    function isCoupleMember(coupleId) {
      return isSignedIn() &&
        request.auth.uid in get(/databases/$(database)/documents/couples/$(coupleId)).data.memberIds;
    }

    match /users/{userId} {
      allow read: if isSelf(userId)
                  || (isSignedIn()
                      && resource.data.coupleId != null
                      && resource.data.coupleId == get(/databases/$(database)/documents/users/$(request.auth.uid)).data.coupleId);
      allow create: if isSelf(userId);
      allow update: if isSelf(userId);
      allow delete: if false;
    }

    match /couples/{coupleId} {
      allow read: if isCoupleMember(coupleId);
      allow create: if isSignedIn()
                    && request.auth.uid in request.resource.data.memberIds;
      allow update, delete: if false;

      match /sharedNotes/{noteId} {
        allow read, write: if isCoupleMember(coupleId);
      }
    }

    match /users/{userId}/privateNotes/{noteId} {
      allow read, write: if isSelf(userId);
    }

    match /inviteCodes/{code} {
      allow read: if isSignedIn();
      allow create: if isSignedIn()
                    && request.resource.data.createdBy == request.auth.uid;
      allow delete: if isSignedIn();
      allow update: if false;
    }
  }
}
```

### Rule design notes

- The partner-read on `users/{userId}` enables the "David wrote this" attribution. It
  costs one extra `get()` per partner-profile read.
- Field-level validation (length limits etc.) is intentionally not in rules — it's
  enforced client-side. Rules cover access control only.
- No rate-limiting in V1.

## Testing

- Unit tests for repositories using `fake_cloud_firestore`.
- Firestore-rules tests using the Firebase emulator suite — at minimum, one positive and
  one negative case per `match` block (e.g., a non-member cannot read another couple's
  shared notes; the wrong user cannot read someone else's private notes).
- No widget tests in V1.
- Manual smoke testing on a real Android device (the dev's and the partner's phones).

## Out of Scope / Deferred

These come **after** V1 ships:

- Push notifications (FCM + Cloud Functions; requires Blaze plan).
- Photo / media notes (Firebase Storage).
- Accent-color / font customization.
- More feature tabs (shared todos, shared calendar, love-notes).
- iOS support.
- Unpair / leave-couple flow.
- Soft delete and undo.
- Markdown rendering.

## Open Questions

None at design-approval time. Implementation may surface details (e.g., the exact set of
characters used in invite codes, the exact relative-time format), which will be decided
during the implementation plan.
