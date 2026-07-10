# ADR-005: Two-phase pairing with self-healing denormalization

**Date:** 2026-05-26
**Status:** Accepted

## Decision

Pairing is split into two phases because Firestore rules forbid one user from writing another user's doc. User B does the atomic writes it's allowed to do; User A's app self-heals its own `coupleId` when it next runs.

## The flow

1. A generates a 6-char invite code → writes `inviteCodes/{code}`.
2. B enters the code → validates it client-side (not expired, not created by B).
3. B runs an atomic batch:
   - Create `couples/{newCoupleId}` with `memberIds: [A, B]`
   - Set `coupleId` on `users/B` (allowed — B writes their own doc)
   - Delete `inviteCodes/{code}`
4. A's app, on its next auth-gate evaluation, queries `couples where memberIds contains A`. If found and `users/A.coupleId` is still null → A writes its own `coupleId`. Done.

## Why this design

- Firestore rules enforce **self-only writes** on `users/{userId}`. This is a deliberate security constraint — we cannot relax it just to simplify pairing.
- A's `coupleId` backfill is eventually consistent but safe: the auth gate treats "a couple exists for me" as the authority, not the `coupleId` field alone.
- The invite code is deleted atomically with the couple creation — no double-claim race condition.

## What NOT to do

- **Do not loosen `users/{userId}` write rules** to let B write A's doc. The whole security model depends on self-only writes.
- **Do not treat `users/me.coupleId` as authoritative.** Always check `couples/{coupleId}.memberIds` for security-critical decisions.
