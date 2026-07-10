# ADR-003: go_router for navigation

**Date:** 2026-05-26
**Status:** Accepted

## Decision

Use `go_router` for all navigation and deep-link routing.

## Why

- Officially supported by the Flutter team (part of the `flutter/packages` repo).
- Declarative route configuration — all routes are defined in one place (`core/router/router.dart`), not scattered across `Navigator.push` calls.
- `redirect` callback integrates cleanly with Riverpod: auth state changes trigger a re-evaluation of the redirect, so the app routes itself to auth/pairing/home automatically.
- Nested routes (`/pairing/generate`, `/pairing/enter`) are first-class.

## Why not alternatives

- **Navigator 1.0 (push/pop):** Imperative, harder to enforce auth-gating across the whole app.
- **auto_route:** Code-gen based, more powerful, but more setup than this app needs.
- **Beamer:** Less adoption, more complex API.

## Trade-offs

- go_router's `redirect` runs on every navigation — keep it cheap (it reads a provider, not Firestore directly).
- Subroute paths must not start with `/` (they're relative) — this caught a bug during pairing screen implementation.

## Key pattern in this project

Auth gating is done via `refreshListenable` + `redirect`:
```
GoRouter(
  refreshListenable: _AuthRouteListenable(ref),  // re-runs redirect on auth state change
  redirect: (context, state) { ... }             // maps AuthRoute enum → path
)
```
This means no screen needs to manually call `context.go(...)` for auth transitions — the router handles it reactively.
