# ADR-006: freezed + json_serializable for data classes

**Date:** 2026-05-26
**Status:** Accepted

## Decision

All Firestore document models use `freezed` + `json_serializable` for immutable data classes with `fromJson`/`toJson`.

## Why

- Immutable value types prevent accidental mutation of Firestore data inside UI code.
- `freezed` generates `copyWith`, `==`, `hashCode`, and `toString` — no manual boilerplate.
- `json_serializable` handles Firestore `Timestamp` → `DateTime` conversion cleanly via custom converters.
- Pattern-matching with `when`/`map` on union types (useful if model variants are added later).

## Why not alternatives

- **Plain Dart classes with manual serialization:** Error-prone, verbose, easy to forget fields.
- **dart_mappable:** Newer, but less ecosystem support at the time of this decision.
- **Built-in `Map` directly in UI:** Never. Raw maps in widgets are explicitly banned in this project (see CLAUDE.md).

## Trade-offs

- Requires code-gen: `flutter pub run build_runner build` after changing any model.
- Generated files (`*.freezed.dart`, `*.g.dart`) are committed to git — they're large but necessary for build reproducibility.

## How it's used

Each feature's `data/` folder contains the model:
```dart
@freezed
class Note with _$Note {
  const factory Note({ required String id, required String title, ... }) = _Note;
  factory Note.fromJson(Map<String, dynamic> json) => _$NoteFromJson(json);
}
```
Repositories always return typed models, never raw `Map<String, dynamic>`.
