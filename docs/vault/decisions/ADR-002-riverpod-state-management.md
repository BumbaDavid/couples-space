# ADR-002: Riverpod for state management

**Date:** 2026-05-26
**Status:** Accepted

## Decision

Use `flutter_riverpod` + `riverpod_annotation` (code-gen style) for all state management and dependency injection.

## Why

- Riverpod is Provider's direct successor — fixes Provider's most painful issues (context dependency, scoping bugs).
- `riverpod_annotation` gives compile-time safety: a wrong provider type is a build error, not a runtime crash.
- Providers are defined outside the widget tree — easier to test and reason about.
- `StreamProvider` wraps Firestore streams cleanly: loading / data / error states handled automatically.

## Why not alternatives

- **Provider:** Older, still works, but Riverpod solves its scoping and context issues. No reason to use it for a new project.
- **BLoC:** Too much boilerplate (events, states, blocs) for an app with a handful of screens.
- **GetX:** Mixes routing + state + DI into one package; harder to replace any piece later.
- **setState only:** Fine for isolated widgets, not for shared Firestore streams that multiple screens watch.

## Trade-offs

- Requires a code-gen step (`flutter pub run build_runner build`) after adding or changing providers.
- Steeper initial learning curve than setState or simple Provider.
- `ProviderScope` must wrap the root widget — already done in `main.dart`.

## How it's used in this project

- Each feature has its own providers file (e.g. `auth_providers.dart`, `notes_providers.dart`).
- Repositories are injected via providers, not constructed directly in widgets.
- UI watches `StreamProvider`s; mutations call repository methods from a `ref.read(...)` callback.
