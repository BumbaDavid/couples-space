# ADR-004: Firestore data model shape

**Date:** 2026-05-26
**Status:** Accepted

## Decision

```
users/{userId}
couples/{coupleId}
couples/{coupleId}/sharedNotes/{noteId}
users/{userId}/privateNotes/{noteId}
inviteCodes/{code}
```

Shared notes live **under the couple**, not under a user. Private notes live **under the user**, never under a couple.

## Why this shape

- Putting shared notes under the couple makes "shared by coupleId" a real storage concept. Security rules become simple: `isCoupleMember(coupleId)` covers both partners without any per-user exceptions.
- Putting private notes under the user means they are structurally unreachable from any couple path — the separation is enforced by the path, not just by a rule.
- `inviteCodes` is top-level so a not-yet-paired user (who has no `coupleId`) can validate a code before they're in a couple. If it lived under `/couples/...`, they couldn't read it.

## Why not alternatives

- **All notes under user with a `sharedWith` field:** Works, but requires client-side filtering and complicates security rules (who can read what?).
- **Flat `notes` collection with a `type` field:** Loses structural separation; security rules become complex ACL checks.

## Invariants to never break

- Never move shared notes under a user path.
- Never add a rule that lets one couple read another couple's data.
- `users/{userId}` writes are **self-only** — even the pairing flow is designed around this (see [[ADR-005-pairing-flow]]).
- `users/{userId}.coupleId` is a **denormalized cache**. The authoritative source of pairing is `couples/{coupleId}.memberIds`. The auth gate backfills `coupleId` if it's missing.
