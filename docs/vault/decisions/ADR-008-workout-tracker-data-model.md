# ADR-008: Workout tracker data model

**Date:** 2026-07-27
**Status:** Accepted

## Decision

The workout tracker stores all data under the current user's own Firestore subcollections,
never under a couple. Exercises can belong to multiple workout days. Exercise type
(strength vs endurance) is derived from `bodyPart`, not from a separate type field.

## Firestore paths

| Collection | Path |
|------------|------|
| Exercises | `users/{userId}/exercises/{exerciseId}` |
| Workout entries | `users/{userId}/workoutEntries/{entryId}` |
| Workout days | `users/{userId}/days/{dayId}` |

## Multi-day exercise membership

An exercise belongs to zero or more named days via `dayIds: List<String>` on the
`Exercise` model. Membership is updated with `FieldValue.arrayUnion` /
`FieldValue.arrayRemove`; queried with `arrayContains`. Old documents without `dayIds`
default to `[]` — backward compatible.

## Endurance vs strength detection

Exercise type is derived from `bodyPart` via `WorkoutIcons.isEndurance(bodyPart)`:

```dart
static bool isEndurance(String bodyPart) =>
    bodyPart == 'Endurance' || bodyPart == 'Cardio';
```

- No separate `exerciseType` field was added to the model to avoid a migration and an
  extra `build_runner` run. The `bodyPart` field already carries the information.
- Legacy Firestore documents created before the rename use `"Cardio"`; the helper
  matches both values.

### Entry shape by type

| Field | Strength | Endurance |
|-------|----------|-----------|
| `sets` | non-empty `List<WorkoutSet>` | `[]` (default) |
| `durationMinutes` | `null` | set (required) |
| `distanceKm`, `speed`, `resistance` | `null` | optional |

## Weekly progress stats

Endurance exercises are excluded from the weekly progress aggregation
(`weeklyProgressProvider` filters on `!WorkoutIcons.isEndurance(e.bodyPart)`).
Only strength sessions contribute to workout days, total reps, and day volume.

## Trade-offs

- Deriving type from `bodyPart` is an implicit convention. If a new body part is
  added that should be treated as endurance, `isEndurance()` must be updated.
- Workout data is per-user, not shared. A couple cannot see each other's workouts in V1.
  Shared workout tracking is a post-V1 idea.
