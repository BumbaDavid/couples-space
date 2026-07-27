# Couples Notes — Decision Vault

A running record of architectural decisions, context, and ideas for this project.

## Decisions (ADRs)

- [[ADR-001-flutter-firebase-stack]] — Why Flutter + Firebase, no custom server
- [[ADR-002-riverpod-state-management]] — Why Riverpod over Provider / BLoC / GetX
- [[ADR-003-go-router-routing]] — Why go_router, how auth-gating works
- [[ADR-004-firestore-data-model]] — Why shared notes live under couple, not user
- [[ADR-005-pairing-flow]] — Two-phase self-healing pairing and why rules can't be loosened
- [[ADR-006-freezed-data-classes]] — Why freezed + json_serializable, never raw Maps
- [[ADR-007-peachy-design-system]] — Peachy visual direction, AppColors/AppTheme tokens, never raw hex
- [[ADR-008-workout-tracker-data-model]] — Firestore paths, multi-day exercises, endurance type detection
- [[ADR-009-firebase-app-distribution]] — How app updates are distributed to testers

## Sessions

Start here when coming back after a gap → [[sessions/template]]

## Ideas

Post-V1 features → [[ideas/post-v1]]

## External references

- [Spec](../superpowers/specs/2026-05-26-couples-notes-app-design.md)
- [Implementation plan](../superpowers/plans/2026-05-26-couples-notes-app.md)
