# ADR-001: Flutter + Firebase as the full stack

**Date:** 2026-05-26
**Status:** Accepted

## Decision

Flutter (Android only for V1) as the UI framework, Firebase Auth + Cloud Firestore as the backend. No custom server, no Cloud Functions in V1.

## Why

- Two-person app with no complex server logic — a managed backend removes an entire layer to maintain.
- Firestore real-time streams mean live sync between partners with zero polling code.
- Firebase Auth handles email/password sign-up, token refresh, and session persistence out of the box.
- Flutter gives a single codebase for Android now, with a clear path to iOS later without rewriting the backend.

## Why not alternatives

- **Supabase / custom REST API:** More control, but adds a server to host, secure, and maintain. Overkill for V1.
- **React Native:** Less familiarity; Flutter's widget model is more structured for this kind of form-heavy app.

## Trade-offs

- Vendor lock-in to Firebase. Migrating off later would be significant work.
- Firestore pricing can spike with high read volume — not a concern for a 2-user app.
- No Cloud Functions means no server-side triggers (e.g. push notifications) until the Blaze plan is needed post-V1.

## Constraints this creates

- All access control must live in Firestore security rules — there is no server middleware to add auth checks to later.
- Offline support comes for free via Firestore persistence, but conflict resolution is last-write-wins.
