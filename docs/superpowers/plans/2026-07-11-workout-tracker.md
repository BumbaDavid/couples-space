# Workout Tracker Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a private per-user workout tracker to the couples notes app with set-by-set exercise logging, exercise history, body-part filtering, archive, and weekly progress visualization.

**Architecture:** Feature-first layout under `lib/features/workout/`. Firestore path: `users/{userId}/exercises/{exerciseId}/entries/{entryId}`. Each entry is a workout session (a date + list of sets). Sets are embedded as an array on the entry document. Navigation: 4th "Workouts" tab added to `HomeShell`; when active, the bottom nav swaps to a 2-item workout sub-nav (Exercises | Progress) and Android back returns to the previous main tab. Pushed screens (Detail, AddEntry, AddExercise) use `Navigator.of(context).push` over the root navigator — no nested navigators needed.

**Tech Stack:** Flutter, Cloud Firestore, Riverpod (manual `Provider`/`StreamProvider` — same pattern as the rest of the app, no code-gen), freezed + json_serializable, google_fonts (already added), intl (already in pubspec)

## Global Constraints

- Android only; no iOS code
- Data path: `users/{userId}/exercises/{exerciseId}/entries/{entryId}` — never under a couple path
- All colors via `AppColors.*`; shadows via `AppTheme.cardShadow` / `AppTheme.buttonShadow`
- Headings/titles: `GoogleFonts.baloo2(...)`; body/labels: `GoogleFonts.quicksand(...)`
- No raw hex values or raw `Map`s in UI widgets
- Firestore read/write pattern: `timestampsToDateTimes` on read, `dateTimesToTimestamps` on write — from `lib/core/firebase/converters.dart`
- No tests (project convention: manual smoke testing only)
- No auto-save; explicit save buttons throughout

---

## File map

**Created:**
```
lib/features/workout/data/
  exercise.dart               freezed Exercise model
  exercise.freezed.dart       generated
  exercise.g.dart             generated
  workout_set.dart            freezed WorkoutSet model (embedded in entries)
  workout_set.freezed.dart    generated
  workout_set.g.dart          generated
  workout_entry.dart          freezed WorkoutEntry model (a session)
  workout_entry.freezed.dart  generated
  workout_entry.g.dart        generated
  workout_icons.dart          IconData + body-part list constants
  workout_date_utils.dart     date display helpers
  workout_repository.dart     Firestore CRUD

lib/features/workout/providers/
  workout_providers.dart      all Riverpod providers for this feature

lib/features/workout/ui/
  exercise_list_screen.dart   exercise list with filter chips + FAB
  add_exercise_screen.dart    create-exercise form
  exercise_detail_screen.dart stats, volume chart, history
  add_entry_screen.dart       set-by-set logging
  progress_screen.dart        weekly chart + stat cards
```

**Modified:**
```
lib/core/widgets/home_shell.dart   add 4th Workouts tab + workout sub-nav
```

---

### Task 1: Data models and helpers

**Files:**
- Create: `lib/features/workout/data/exercise.dart`
- Create: `lib/features/workout/data/workout_set.dart`
- Create: `lib/features/workout/data/workout_entry.dart`
- Create: `lib/features/workout/data/workout_icons.dart`
- Create: `lib/features/workout/data/workout_date_utils.dart`

**Produces:** `Exercise`, `WorkoutSet`, `WorkoutEntry` classes + `WorkoutIcons` constants + `formatEntryDate` helper — used by every subsequent task.

- [ ] **Step 1: Create `lib/features/workout/data/exercise.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'exercise.freezed.dart';
part 'exercise.g.dart';

@freezed
abstract class Exercise with _$Exercise {
  const factory Exercise({
    required String id,
    required String name,
    required String bodyPart,
    @Default(false) bool isArchived,
    required DateTime createdAt,
  }) = _Exercise;

  factory Exercise.fromJson(Map<String, dynamic> json) =>
      _$ExerciseFromJson(json);
}
```

`icon` is intentionally absent — derived at runtime from `bodyPart` via `WorkoutIcons.forBodyPart`.

- [ ] **Step 2: Create `lib/features/workout/data/workout_set.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'workout_set.freezed.dart';
part 'workout_set.g.dart';

@freezed
abstract class WorkoutSet with _$WorkoutSet {
  const factory WorkoutSet({
    required int reps,
    double? weight,           // null = bodyweight; volume calc uses 1.0 as fallback
    @Default(false) bool failure,
  }) = _WorkoutSet;

  factory WorkoutSet.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSetFromJson(json);
}
```

- [ ] **Step 3: Create `lib/features/workout/data/workout_entry.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'workout_set.dart';

part 'workout_entry.freezed.dart';
part 'workout_entry.g.dart';

@freezed
abstract class WorkoutEntry with _$WorkoutEntry {
  const factory WorkoutEntry({
    required String id,
    required String exerciseId,
    required List<WorkoutSet> sets,
    required DateTime date,
  }) = _WorkoutEntry;

  factory WorkoutEntry.fromJson(Map<String, dynamic> json) =>
      _$WorkoutEntryFromJson(json);
}

extension WorkoutEntryStats on WorkoutEntry {
  /// Total volume: sum of reps × weight (weight defaults to 1 for bodyweight sets).
  double get volume => sets.fold(0, (s, set) => s + set.reps * (set.weight ?? 1.0));

  int get totalReps => sets.fold(0, (s, set) => s + set.reps);
}
```

- [ ] **Step 4: Create `lib/features/workout/data/workout_icons.dart`**

```dart
import 'package:flutter/material.dart';

abstract class WorkoutIcons {
  static const List<String> bodyParts = [
    'Chest', 'Back', 'Legs', 'Shoulders', 'Arms', 'Core', 'Cardio',
  ];

  static IconData forBodyPart(String bodyPart) => switch (bodyPart) {
    'Chest' => Icons.fitness_center,
    'Back' => Icons.rowing,
    'Legs' => Icons.directions_run,
    'Shoulders' => Icons.sports_gymnastics,
    'Arms' => Icons.sports_handball,
    'Core' => Icons.self_improvement,
    'Cardio' => Icons.directions_bike,
    _ => Icons.fitness_center,
  };
}
```

- [ ] **Step 5: Create `lib/features/workout/data/workout_date_utils.dart`**

```dart
import 'package:intl/intl.dart';

/// Returns 'Today', 'Yesterday', or 'Jul 10' depending on how old [date] is.
String formatEntryDate(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(date.year, date.month, date.day);
  final diff = today.difference(day).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  return DateFormat('MMM d').format(date);
}

/// Returns the Monday of the week containing [date], normalized to midnight.
DateTime weekStart(DateTime date) {
  final monday = date.subtract(Duration(days: date.weekday - 1));
  return DateTime(monday.year, monday.month, monday.day);
}

/// Returns the Sunday (last day) of the week starting on [start].
DateTime weekEnd(DateTime start) =>
    start.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));

/// Human-readable label for a week. Returns 'This week' for the current week,
/// 'Jul 7 – Jul 13' for others.
String weekLabel(DateTime start) {
  final currentStart = weekStart(DateTime.now());
  if (start == currentStart) return 'This week';
  final end = start.add(const Duration(days: 6));
  final fmt = DateFormat('MMM d');
  return '${fmt.format(start)} – ${fmt.format(end)}';
}
```

- [ ] **Step 6: Run build_runner**

```
flutter pub run build_runner build --delete-conflicting-outputs
```

Expected: generates 6 files (`*.freezed.dart` + `*.g.dart` for each of the 3 models).

- [ ] **Step 7: Analyze**

```
flutter analyze lib/features/workout/data/
```

Expected: No issues.

- [ ] **Step 8: Commit**

```
git add lib/features/workout/data/
git commit -m "feat(workout): add Exercise, WorkoutSet, WorkoutEntry models and helpers"
```

---

### Task 2: WorkoutRepository

**Files:**
- Create: `lib/features/workout/data/workout_repository.dart`

**Consumes:** `Exercise`, `WorkoutSet`, `WorkoutEntry` (Task 1); `converters.dart` from `lib/core/firebase/`

**Produces:** `WorkoutRepository` — used by Task 3 (providers).

- [ ] **Step 1: Create `lib/features/workout/data/workout_repository.dart`**

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../../core/firebase/converters.dart';
import 'exercise.dart';
import 'workout_entry.dart';
import 'workout_set.dart';

class WorkoutRepository {
  WorkoutRepository({
    required FirebaseFirestore db,
    required String userId,
  })  : _db = db,
        _userId = userId;

  final FirebaseFirestore _db;
  final String _userId;
  static const _uuid = Uuid();
  static const _exerciseTimeFields = ['createdAt'];
  static const _entryTimeFields = ['date'];

  CollectionReference<Map<String, dynamic>> get _exercises =>
      _db.collection('users').doc(_userId).collection('exercises');

  CollectionReference<Map<String, dynamic>> _entries(String exerciseId) =>
      _exercises.doc(exerciseId).collection('entries');

  // ── Exercises ──────────────────────────────────────────────────────────────

  Stream<List<Exercise>> watchExercises({bool includeArchived = false}) {
    Query<Map<String, dynamic>> q = _exercises;
    if (!includeArchived) q = q.where('isArchived', isEqualTo: false);
    return q
        .orderBy('createdAt')
        .snapshots()
        .map((snap) => snap.docs.map(_decodeExercise).toList());
  }

  Stream<Exercise?> watchExercise(String exerciseId) {
    return _exercises.doc(exerciseId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return _decodeExercise(snap);
    });
  }

  Future<void> createExercise({
    required String name,
    required String bodyPart,
  }) async {
    final exercise = Exercise(
      id: _uuid.v4(),
      name: name,
      bodyPart: bodyPart,
      createdAt: DateTime.now(),
    );
    final json = exercise.toJson()..remove('id');
    await _exercises
        .doc(exercise.id)
        .set(dateTimesToTimestamps(json, _exerciseTimeFields));
  }

  Future<void> archiveExercise(String exerciseId) =>
      _exercises.doc(exerciseId).update({'isArchived': true});

  Future<void> unarchiveExercise(String exerciseId) =>
      _exercises.doc(exerciseId).update({'isArchived': false});

  Future<void> deleteExercise(String exerciseId) async {
    final entriesSnap = await _entries(exerciseId).get();
    final batch = _db.batch();
    for (final doc in entriesSnap.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_exercises.doc(exerciseId));
    await batch.commit();
  }

  // ── Entries ────────────────────────────────────────────────────────────────

  Stream<List<WorkoutEntry>> watchEntries(String exerciseId) {
    return _entries(exerciseId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(_decodeEntry).toList());
  }

  Stream<List<WorkoutEntry>> watchEntriesForWeek(
    String exerciseId,
    DateTime start,
    DateTime end,
  ) {
    return _entries(exerciseId)
        .where('date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(start),
            isLessThanOrEqualTo: Timestamp.fromDate(end))
        .snapshots()
        .map((snap) => snap.docs.map(_decodeEntry).toList());
  }

  Future<void> createEntry({
    required String exerciseId,
    required List<WorkoutSet> sets,
  }) async {
    final id = _uuid.v4();
    final entry = WorkoutEntry(
      id: id,
      exerciseId: exerciseId,
      sets: sets,
      date: DateTime.now(),
    );
    final json = entry.toJson()..remove('id');
    await _entries(exerciseId)
        .doc(id)
        .set(dateTimesToTimestamps(json, _entryTimeFields));
  }

  Future<void> deleteEntry(String exerciseId, String entryId) =>
      _entries(exerciseId).doc(entryId).delete();

  // ── Decoders ───────────────────────────────────────────────────────────────

  Exercise _decodeExercise(DocumentSnapshot<Map<String, dynamic>> snap) {
    return Exercise.fromJson({
      ...timestampsToDateTimes(snap.data()!, _exerciseTimeFields),
      'id': snap.id,
    });
  }

  WorkoutEntry _decodeEntry(DocumentSnapshot<Map<String, dynamic>> snap) {
    return WorkoutEntry.fromJson({
      ...timestampsToDateTimes(snap.data()!, _entryTimeFields),
      'id': snap.id,
    });
  }
}
```

- [ ] **Step 2: Analyze**

```
flutter analyze lib/features/workout/data/workout_repository.dart
```

- [ ] **Step 3: Commit**

```
git add lib/features/workout/data/workout_repository.dart
git commit -m "feat(workout): add WorkoutRepository"
```

---

### Task 3: Riverpod providers

**Files:**
- Create: `lib/features/workout/providers/workout_providers.dart`

**Consumes:** `WorkoutRepository` (Task 2); `firestoreProvider`, `authStateChangesProvider` from `lib/core/firebase/firebase_providers.dart`

**Produces:**
- `workoutRepositoryProvider` → `WorkoutRepository`
- `exercisesProvider` → `StreamProvider.family<List<Exercise>, bool>` (param = includeArchived)
- `exerciseProvider` → `StreamProvider.family<Exercise?, String>` (param = exerciseId)
- `exerciseEntriesProvider` → `StreamProvider.family<List<WorkoutEntry>, String>` (param = exerciseId)
- `weeklyEntriesProvider` → `StreamProvider.family` (param = `_WeeklyEntriesParams`)
- `weeklyProgressProvider` → `Provider.family<WeeklyStats, DateTime>` (param = weekStart)
- `WeeklyStats`, `DayVolume` data classes

- [ ] **Step 1: Create `lib/features/workout/providers/workout_providers.dart`**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../data/exercise.dart';
import '../data/workout_date_utils.dart';
import '../data/workout_entry.dart';
import '../data/workout_repository.dart';

// ── Repository ─────────────────────────────────────────────────────────────

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  final authUser = ref.watch(authStateChangesProvider).asData?.value;
  if (authUser == null) throw StateError('workoutRepository requires auth');
  return WorkoutRepository(
    db: ref.watch(firestoreProvider),
    userId: authUser.uid,
  );
});

// ── Exercises ───────────────────────────────────────────────────────────────

/// Pass `true` to also load archived exercises. Default is `false`.
final exercisesProvider =
    StreamProvider.family<List<Exercise>, bool>((ref, includeArchived) {
  return ref
      .watch(workoutRepositoryProvider)
      .watchExercises(includeArchived: includeArchived);
});

final exerciseProvider =
    StreamProvider.family<Exercise?, String>((ref, exerciseId) {
  return ref.watch(workoutRepositoryProvider).watchExercise(exerciseId);
});

// ── Entries ─────────────────────────────────────────────────────────────────

final exerciseEntriesProvider =
    StreamProvider.family<List<WorkoutEntry>, String>((ref, exerciseId) {
  return ref.watch(workoutRepositoryProvider).watchEntries(exerciseId);
});

// Params object for weeklyEntriesProvider (Riverpod family requires one arg).
class _WeeklyEntriesParams {
  const _WeeklyEntriesParams(this.exerciseId, this.start, this.end);
  final String exerciseId;
  final DateTime start;
  final DateTime end;

  @override
  bool operator ==(Object other) =>
      other is _WeeklyEntriesParams &&
      exerciseId == other.exerciseId &&
      start == other.start &&
      end == other.end;

  @override
  int get hashCode => Object.hash(exerciseId, start, end);
}

final weeklyEntriesProvider =
    StreamProvider.family<List<WorkoutEntry>, _WeeklyEntriesParams>(
        (ref, params) {
  return ref
      .watch(workoutRepositoryProvider)
      .watchEntriesForWeek(params.exerciseId, params.start, params.end);
});

// ── Weekly progress (derived, sync) ─────────────────────────────────────────

class DayVolume {
  const DayVolume({required this.label, required this.volume});
  final String label;  // 'M', 'T', 'W', 'T', 'F', 'S', 'S'
  final double volume;
}

class WeeklyStats {
  const WeeklyStats({
    required this.workoutDays,
    required this.totalReps,
    required this.days,
  });
  final int workoutDays;
  final int totalReps;
  final List<DayVolume> days; // 7 entries, index 0 = Monday

  static const empty = WeeklyStats(
    workoutDays: 0,
    totalReps: 0,
    days: [
      DayVolume(label: 'M', volume: 0),
      DayVolume(label: 'T', volume: 0),
      DayVolume(label: 'W', volume: 0),
      DayVolume(label: 'T', volume: 0),
      DayVolume(label: 'F', volume: 0),
      DayVolume(label: 'S', volume: 0),
      DayVolume(label: 'S', volume: 0),
    ],
  );
}

/// Returns weekly stats for the calendar week starting on [weekStart] (Monday).
/// Pass a value from [weekStart(DateTime)] in workout_date_utils.dart.
final weeklyProgressProvider =
    Provider.family<WeeklyStats, DateTime>((ref, start) {
  final end = weekEnd(start);
  final exercises =
      ref.watch(exercisesProvider(false)).valueOrNull ?? [];

  final dayVolumes = List<double>.filled(7, 0);
  final activeDays = <int>{};
  var totalReps = 0;

  for (final exercise in exercises) {
    final params = _WeeklyEntriesParams(exercise.id, start, end);
    final entries =
        ref.watch(weeklyEntriesProvider(params)).valueOrNull ?? [];
    for (final entry in entries) {
      final dayIdx = entry.date.weekday - 1; // 0=Mon … 6=Sun
      dayVolumes[dayIdx] += entry.volume;
      activeDays.add(entry.date.weekday);
      totalReps += entry.totalReps;
    }
  }

  const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  return WeeklyStats(
    workoutDays: activeDays.length,
    totalReps: totalReps,
    days: List.generate(
      7,
      (i) => DayVolume(label: labels[i], volume: dayVolumes[i]),
    ),
  );
});
```

- [ ] **Step 2: Analyze**

```
flutter analyze lib/features/workout/providers/
```

- [ ] **Step 3: Commit**

```
git add lib/features/workout/providers/
git commit -m "feat(workout): add Riverpod providers and WeeklyStats"
```

---

### Task 4: Navigation integration

**Files:**
- Modify: `lib/core/widgets/home_shell.dart`

**Consumes:** `ExerciseListScreen` (Task 5), `ProgressScreen` (Task 9)

**Note:** Import these screens before this task compiles — stub them out first if building incrementally.

- [ ] **Step 1: Replace `lib/core/widgets/home_shell.dart`**

```dart
import 'package:flutter/material.dart';

import '../../features/private_notes/ui/private_notes_screen.dart';
import '../../features/profile/ui/profile_screen.dart';
import '../../features/shared_notes/ui/shared_notes_screen.dart';
import '../../features/workout/ui/exercise_list_screen.dart';
import '../../features/workout/ui/progress_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _mainIndex = 0; // 0=Shared 1=Private 2=Workouts 3=Profile
  int _workoutTab = 0; // 0=Exercises 1=Progress (only used when _mainIndex==2)

  Widget _body() => switch (_mainIndex) {
    0 => const SharedNotesScreen(),
    1 => const PrivateNotesScreen(),
    2 => _workoutTab == 0
        ? const ExerciseListScreen()
        : const ProgressScreen(),
    3 => const ProfileScreen(),
    _ => const SharedNotesScreen(),
  };

  NavigationBar _navBar() {
    if (_mainIndex == 2) {
      return NavigationBar(
        selectedIndex: _workoutTab,
        onDestinationSelected: (i) => setState(() => _workoutTab = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.fitness_center), label: 'Exercises'),
          NavigationDestination(
              icon: Icon(Icons.bar_chart), label: 'Progress'),
        ],
      );
    }
    return NavigationBar(
      selectedIndex: _mainIndex,
      onDestinationSelected: (i) => setState(() => _mainIndex = i),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.people), label: 'Shared'),
        NavigationDestination(icon: Icon(Icons.person), label: 'Private'),
        NavigationDestination(
            icon: Icon(Icons.fitness_center), label: 'Workouts'),
        NavigationDestination(icon: Icon(Icons.settings), label: 'Profile'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Allow back when NOT in workout section; handle it manually when in workout.
      canPop: _mainIndex != 2,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _mainIndex == 2) {
          setState(() {
            _mainIndex = 0;
            _workoutTab = 0;
          });
        }
      },
      child: Scaffold(
        body: _body(),
        bottomNavigationBar: _navBar(),
      ),
    );
  }
}
```

- [ ] **Step 2: Analyze**

```
flutter analyze lib/core/widgets/home_shell.dart
```

- [ ] **Step 3: Commit**

```
git add lib/core/widgets/home_shell.dart
git commit -m "feat(workout): add Workouts tab to HomeShell with sub-nav"
```

---

### Task 5: ExerciseListScreen

**Files:**
- Create: `lib/features/workout/ui/exercise_list_screen.dart`

**Consumes:** `exercisesProvider(bool)` (Task 3), `WorkoutIcons` (Task 1), `AppColors`, `AppTheme`

- [ ] **Step 1: Create `lib/features/workout/ui/exercise_list_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/theme.dart';
import '../data/exercise.dart';
import '../data/workout_icons.dart';
import '../providers/workout_providers.dart';
import 'add_exercise_screen.dart';
import 'exercise_detail_screen.dart';

class ExerciseListScreen extends ConsumerStatefulWidget {
  const ExerciseListScreen({super.key});

  @override
  ConsumerState<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends ConsumerState<ExerciseListScreen> {
  String? _filterBodyPart; // null = All
  bool _showArchived = false;

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(exercisesProvider(_showArchived));

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "LET'S MOVE",
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.muted,
                      letterSpacing: 1.6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'My Workouts',
                    style: GoogleFonts.baloo2(
                      fontSize: 31,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
            ),
            // Filter chips
            _FilterBar(
              selectedBodyPart: _filterBodyPart,
              showArchived: _showArchived,
              onBodyPartSelected: (bp) =>
                  setState(() => _filterBodyPart = bp),
              onArchivedToggled: (v) =>
                  setState(() => _showArchived = v),
            ),
            const SizedBox(height: 4),
            // List
            Expanded(
              child: exercisesAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (all) {
                  final exercises = _filterBodyPart == null
                      ? all
                      : all
                          .where((e) => e.bodyPart == _filterBodyPart)
                          .toList();
                  if (exercises.isEmpty) {
                    return _EmptyState(showArchived: _showArchived);
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 100),
                    itemCount: exercises.length,
                    itemBuilder: (context, i) => _ExerciseRow(
                      exercise: exercises[i],
                      tileIndex: i,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _AddFab(showArchived: _showArchived),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

// ── Filter bar ─────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.selectedBodyPart,
    required this.showArchived,
    required this.onBodyPartSelected,
    required this.onArchivedToggled,
  });
  final String? selectedBodyPart;
  final bool showArchived;
  final ValueChanged<String?> onBodyPartSelected;
  final ValueChanged<bool> onArchivedToggled;

  @override
  Widget build(BuildContext context) {
    final chips = <String?>[null, ...WorkoutIcons.bodyParts]; // null = 'All'
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        itemCount: chips.length + 1, // +1 for archived toggle
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          if (i == chips.length) {
            // Archived toggle chip
            return _Chip(
              label: 'Archived',
              selected: showArchived,
              onTap: () => onArchivedToggled(!showArchived),
            );
          }
          final bp = chips[i];
          return _Chip(
            label: bp ?? 'All',
            selected: selectedBodyPart == bp,
            onTap: () => onBodyPartSelected(bp),
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.chipBg,
          borderRadius: BorderRadius.circular(100),
          boxShadow: selected ? [AppTheme.buttonShadow] : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.quicksand(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.onPrimary : AppColors.chipText,
          ),
        ),
      ),
    );
  }
}

// ── Exercise row ───────────────────────────────────────────────────────────

class _ExerciseRow extends ConsumerWidget {
  const _ExerciseRow({required this.exercise, required this.tileIndex});
  final Exercise exercise;
  final int tileIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tile = AppColors.tilePalette[tileIndex % AppColors.tilePalette.length];
    final entries =
        ref.watch(exerciseEntriesProvider(exercise.id)).valueOrNull ?? [];

    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => ExerciseDetailScreen(
            exerciseId: exercise.id,
            tileIndex: tileIndex,
          ),
        )),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(26),
            boxShadow: const [AppTheme.cardShadow],
          ),
          child: Row(
            children: [
              // Icon tile
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: tile.background,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  WorkoutIcons.forBodyPart(exercise.bodyPart),
                  color: tile.iconColor,
                  size: 29,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: GoogleFonts.baloo2(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    Text(
                      '${exercise.bodyPart} · ${entries.length} session${entries.length == 1 ? '' : 's'}',
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.muted, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ── FAB ─────────────────────────────────────────────────────────────────────

class _AddFab extends StatelessWidget {
  const _AddFab({required this.showArchived});
  final bool showArchived;

  @override
  Widget build(BuildContext context) {
    if (showArchived) return const SizedBox.shrink();
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AddExerciseScreen()),
      ),
      child: Container(
        width: 62,
        height: 62,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [AppTheme.buttonShadow],
        ),
        child: const Icon(Icons.add, color: AppColors.onPrimary, size: 31),
      ),
    );
  }
}

// ── Empty state ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.showArchived});
  final bool showArchived;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.note_add, color: AppColors.muted, size: 38),
          const SizedBox(height: 12),
          Text(
            showArchived
                ? 'No archived exercises'
                : 'No exercises yet — add your first!',
            style: GoogleFonts.quicksand(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Analyze**

```
flutter analyze lib/features/workout/ui/exercise_list_screen.dart
```

- [ ] **Step 3: Commit**

```
git add lib/features/workout/ui/exercise_list_screen.dart
git commit -m "feat(workout): add ExerciseListScreen with filter and tile list"
```

---

### Task 6: AddExerciseScreen

**Files:**
- Create: `lib/features/workout/ui/add_exercise_screen.dart`

**Consumes:** `workoutRepositoryProvider` (Task 3), `WorkoutIcons` (Task 1), `AppColors`, `AppTheme`

- [ ] **Step 1: Create `lib/features/workout/ui/add_exercise_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/theme.dart';
import '../data/workout_icons.dart';
import '../providers/workout_providers.dart';
import 'exercise_detail_screen.dart';

class AddExerciseScreen extends ConsumerStatefulWidget {
  const AddExerciseScreen({super.key});

  @override
  ConsumerState<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends ConsumerState<AddExerciseScreen> {
  final _nameController = TextEditingController();
  String _bodyPart = WorkoutIcons.bodyParts.first;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (_saving) return;
    setState(() => _saving = true);
    final name = _nameController.text.trim().isEmpty
        ? 'New Exercise'
        : _nameController.text.trim();
    try {
      final repo = ref.read(workoutRepositoryProvider);
      await repo.createExercise(name: name, bodyPart: _bodyPart);
      // Pop AddExercise, then push Detail for the new exercise.
      // We navigate back first; the list re-renders via the stream and the
      // caller navigates to detail from there. Simpler: just pop.
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tile = AppColors.tilePalette[
        WorkoutIcons.bodyParts.indexOf(_bodyPart) % AppColors.tilePalette.length];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Back arrow
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.text),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 6, 22, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'New exercise',
                      style: GoogleFonts.baloo2(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Icon preview
                    Center(
                      child: Container(
                        width: 92,
                        height: 92,
                        decoration: BoxDecoration(
                          color: tile.background,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          WorkoutIcons.forBodyPart(_bodyPart),
                          color: tile.iconColor,
                          size: 48,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Name field
                    Text(
                      'NAME',
                      style: GoogleFonts.quicksand(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.muted,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [AppTheme.cardShadow],
                      ),
                      child: TextField(
                        controller: _nameController,
                        style: GoogleFonts.baloo2(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                        decoration: InputDecoration(
                          hintText: 'e.g. Lunges',
                          hintStyle: GoogleFonts.baloo2(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: AppColors.muted,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 15),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Body part chips
                    Text(
                      'BODY PART',
                      style: GoogleFonts.quicksand(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.muted,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 9,
                      runSpacing: 9,
                      children: WorkoutIcons.bodyParts.map((bp) {
                        final selected = bp == _bodyPart;
                        return GestureDetector(
                          onTap: () => setState(() => _bodyPart = bp),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.chipBg,
                              borderRadius: BorderRadius.circular(100),
                              boxShadow:
                                  selected ? [AppTheme.buttonShadow] : null,
                            ),
                            child: Text(
                              bp,
                              style: GoogleFonts.quicksand(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: selected
                                    ? AppColors.onPrimary
                                    : AppColors.chipText,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Fixed bottom button
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 16),
          child: GestureDetector(
            onTap: _saving ? null : _create,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [AppTheme.buttonShadow],
              ),
              child: Center(
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: AppColors.onPrimary, strokeWidth: 2))
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add,
                              color: AppColors.onPrimary, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'Create exercise',
                            style: GoogleFonts.baloo2(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onPrimary,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Analyze**

```
flutter analyze lib/features/workout/ui/add_exercise_screen.dart
```

- [ ] **Step 3: Commit**

```
git add lib/features/workout/ui/add_exercise_screen.dart
git commit -m "feat(workout): add AddExerciseScreen"
```

---

### Task 7: ExerciseDetailScreen

**Files:**
- Create: `lib/features/workout/ui/exercise_detail_screen.dart`

**Consumes:** `exerciseProvider(id)`, `exerciseEntriesProvider(id)` (Task 3); `workoutRepositoryProvider` (Task 3); `WorkoutIcons`, `WorkoutEntry`, `WorkoutEntryStats` (Tasks 1-2); `AppColors`, `AppTheme`

- [ ] **Step 1: Create `lib/features/workout/ui/exercise_detail_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/theme.dart';
import '../data/workout_date_utils.dart';
import '../data/workout_entry.dart';
import '../data/workout_icons.dart';
import '../providers/workout_providers.dart';
import 'add_entry_screen.dart';

class ExerciseDetailScreen extends ConsumerWidget {
  const ExerciseDetailScreen({
    super.key,
    required this.exerciseId,
    required this.tileIndex,
  });
  final String exerciseId;
  final int tileIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exerciseAsync = ref.watch(exerciseProvider(exerciseId));
    final entriesAsync = ref.watch(exerciseEntriesProvider(exerciseId));

    return exerciseAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (exercise) {
        if (exercise == null) {
          return const Scaffold(
              body: Center(child: Text('Exercise not found')));
        }
        final tile = AppColors
            .tilePalette[tileIndex % AppColors.tilePalette.length];
        final entries = entriesAsync.valueOrNull ?? [];

        return Scaffold(
          body: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back arrow
                      Padding(
                        padding: const EdgeInsets.only(top: 14, bottom: 8),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: AppColors.text),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      // Hero
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                color: tile.background,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                WorkoutIcons.forBodyPart(exercise.bodyPart),
                                color: tile.iconColor,
                                size: 46,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              exercise.name,
                              style: GoogleFonts.baloo2(
                                fontSize: 27,
                                fontWeight: FontWeight.w600,
                                color: AppColors.text,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.chipBg,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                exercise.bodyPart,
                                style: GoogleFonts.quicksand(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.chipText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      // Stat row
                      _StatRow(entries: entries),
                      const SizedBox(height: 16),
                      // Volume chart
                      if (entries.isNotEmpty) _VolumeChart(entries: entries),
                      // History
                      _History(
                        entries: entries,
                        exerciseId: exerciseId,
                      ),
                    ],
                  ),
                ),
                // Fixed bottom button
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _AddEntryButton(
                    exerciseId: exerciseId,
                    exerciseName: exercise.name,
                    tileIndex: tileIndex,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Stat row (3 cards) ─────────────────────────────────────────────────────

class _StatRow extends StatelessWidget {
  const _StatRow({required this.entries});
  final List<WorkoutEntry> entries;

  @override
  Widget build(BuildContext context) {
    final sessions = entries.length;
    final bestReps = entries.isEmpty
        ? 0
        : entries
            .expand((e) => e.sets)
            .map((s) => s.reps)
            .reduce((a, b) => a > b ? a : b);
    final totalSets = entries.fold(0, (sum, e) => sum + e.sets.length);

    return Row(
      children: [
        _StatCard(value: '$sessions', label: 'SESSIONS'),
        const SizedBox(width: 10),
        _StatCard(value: '$bestReps', label: 'BEST REPS'),
        const SizedBox(width: 10),
        _StatCard(value: '$totalSets', label: 'TOTAL SETS'),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [AppTheme.cardShadow],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.baloo2(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text),
            ),
            Text(
              label,
              style: GoogleFonts.quicksand(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Volume chart ───────────────────────────────────────────────────────────

class _VolumeChart extends StatelessWidget {
  const _VolumeChart({required this.entries});
  final List<WorkoutEntry> entries;

  @override
  Widget build(BuildContext context) {
    final volumes = entries.map((e) => e.volume).toList();
    final maxVol = volumes.reduce((a, b) => a > b ? a : b);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [AppTheme.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Volume per session',
            style: GoogleFonts.baloo2(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.text),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 104,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: entries.asMap().entries.map((e) {
                final vol = e.value.volume;
                final frac = maxVol > 0 ? vol / maxVol : 0.0;
                final barH = (frac * 100).clamp(6.0, 100.0);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: barH,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                              bottomLeft: Radius.circular(5),
                              bottomRight: Radius.circular(5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatEntryDate(e.value.date),
                          style: GoogleFonts.quicksand(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.muted),
                          maxLines: 1,
                          overflow: TextOverflow.visible,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── History ────────────────────────────────────────────────────────────────

class _History extends ConsumerWidget {
  const _History({required this.entries, required this.exerciseId});
  final List<WorkoutEntry> entries;
  final String exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 22, 4, 12),
          child: Text(
            'History',
            style: GoogleFonts.baloo2(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.text),
          ),
        ),
        if (entries.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.note_add, color: AppColors.muted, size: 38),
                  const SizedBox(height: 8),
                  Text(
                    'No entries yet — log your first set!',
                    style: GoogleFonts.quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.muted),
                  ),
                ],
              ),
            ),
          )
        else
          ...entries.map((entry) => _EntryRow(
                entry: entry,
                exerciseId: exerciseId,
              )),
      ],
    );
  }
}

class _EntryRow extends ConsumerWidget {
  const _EntryRow({required this.entry, required this.exerciseId});
  final WorkoutEntry entry;
  final String exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasFailure = entry.sets.any((s) => s.failure);
    final label = formatEntryDate(entry.date);
    final setsCount = entry.sets.length;
    final totalReps = entry.totalReps;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Dismissible(
        key: Key(entry.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: AppColors.failText,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        confirmDismiss: (_) => showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete entry?'),
            content: const Text('This cannot be undone.'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Delete')),
            ],
          ),
        ),
        onDismissed: (_) => ref
            .read(workoutRepositoryProvider)
            .deleteEntry(exerciseId, entry.id),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [AppTheme.cardShadow],
          ),
          child: Row(
            children: [
              // Date tile
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.chipBg,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.baloo2(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.text),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$setsCount set${setsCount == 1 ? '' : 's'} · $totalReps total reps',
                      style: GoogleFonts.baloo2(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text),
                    ),
                    Text(
                      entry.sets.map((s) {
                        final w = s.weight != null ? ' × ${s.weight}kg' : '';
                        return '${s.reps}$w';
                      }).join(', '),
                      style: GoogleFonts.quicksand(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.muted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (hasFailure) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.failBg,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_fire_department,
                          size: 14, color: AppColors.failText),
                      const SizedBox(width: 3),
                      Text(
                        'Failure',
                        style: GoogleFonts.quicksand(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.failText),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Add entry button ───────────────────────────────────────────────────────

class _AddEntryButton extends StatelessWidget {
  const _AddEntryButton({
    required this.exerciseId,
    required this.exerciseName,
    required this.tileIndex,
  });
  final String exerciseId;
  final String exerciseName;
  final int tileIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.bg.withValues(alpha: 0),
            AppColors.bg,
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => AddEntryScreen(
            exerciseId: exerciseId,
            exerciseName: exerciseName,
          ),
        )),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [AppTheme.buttonShadow],
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add, color: AppColors.onPrimary, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Add entry',
                  style: GoogleFonts.baloo2(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Analyze**

```
flutter analyze lib/features/workout/ui/exercise_detail_screen.dart
```

- [ ] **Step 3: Commit**

```
git add lib/features/workout/ui/exercise_detail_screen.dart
git commit -m "feat(workout): add ExerciseDetailScreen with stats, chart, and history"
```

---

### Task 8: AddEntryScreen

**Files:**
- Create: `lib/features/workout/ui/add_entry_screen.dart`

**Consumes:** `workoutRepositoryProvider` (Task 3); `WorkoutSet` (Task 1); `AppColors`, `AppTheme`

The screen collects individual sets one at a time. Each set: reps stepper + optional weight field + failure toggle. Tapping "Add set" appends to a local list. Tapping "Save entry" writes all sets to Firestore and pops back.

- [ ] **Step 1: Create `lib/features/workout/ui/add_entry_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/theme.dart';
import '../data/workout_set.dart';
import '../providers/workout_providers.dart';

class AddEntryScreen extends ConsumerStatefulWidget {
  const AddEntryScreen({
    super.key,
    required this.exerciseId,
    required this.exerciseName,
  });
  final String exerciseId;
  final String exerciseName;

  @override
  ConsumerState<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends ConsumerState<AddEntryScreen> {
  // Current set being built
  int _reps = 10;
  final _weightController = TextEditingController();
  bool _failure = false;

  // Committed sets in this session
  final List<WorkoutSet> _sets = [];

  bool _saving = false;

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  void _addSet() {
    final weightText = _weightController.text.trim();
    final weight = weightText.isEmpty ? null : double.tryParse(weightText);
    setState(() {
      _sets.add(WorkoutSet(reps: _reps, weight: weight, failure: _failure));
      // Reset form
      _reps = 10;
      _weightController.clear();
      _failure = false;
    });
  }

  Future<void> _save() async {
    if (_saving || _sets.isEmpty) return;
    setState(() => _saving = true);
    try {
      await ref.read(workoutRepositoryProvider).createEntry(
            exerciseId: widget.exerciseId,
            sets: _sets,
          );
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Back arrow
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.text),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 6, 22, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Eyebrow + title
                    Text(
                      widget.exerciseName.toUpperCase(),
                      style: GoogleFonts.quicksand(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.muted,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Log a set',
                      style: GoogleFonts.baloo2(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Sets logged so far
                    if (_sets.isNotEmpty) ...[
                      Text(
                        'Sets logged',
                        style: GoogleFonts.baloo2(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._sets.asMap().entries.map((e) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _SetChip(
                                index: e.key, set: e.value),
                          )),
                      const SizedBox(height: 16),
                    ],
                    // Reps stepper
                    _StepperCard(
                      label: 'REPS',
                      value: _reps,
                      onDecrement: _reps > 1
                          ? () => setState(() => _reps--)
                          : null,
                      onIncrement: () => setState(() => _reps++),
                    ),
                    const SizedBox(height: 14),
                    // Weight field
                    _WeightCard(controller: _weightController),
                    const SizedBox(height: 14),
                    // Failure toggle
                    _FailureCard(
                      value: _failure,
                      onChanged: (v) => setState(() => _failure = v),
                    ),
                    const SizedBox(height: 20),
                    // Add set button
                    GestureDetector(
                      onTap: _addSet,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.chipBg,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Center(
                          child: Text(
                            'Add set',
                            style: GoogleFonts.baloo2(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.chipText,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 16),
          child: GestureDetector(
            onTap: _sets.isEmpty || _saving ? null : _save,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _sets.isEmpty
                    ? AppColors.border
                    : AppColors.primary,
                borderRadius: BorderRadius.circular(18),
                boxShadow: _sets.isEmpty ? null : const [AppTheme.buttonShadow],
              ),
              child: Center(
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: AppColors.onPrimary, strokeWidth: 2))
                    : Text(
                        _sets.isEmpty
                            ? 'Add at least one set'
                            : 'Save entry (${_sets.length} set${_sets.length == 1 ? '' : 's'})',
                        style: GoogleFonts.baloo2(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: _sets.isEmpty
                              ? AppColors.muted
                              : AppColors.onPrimary,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Set chip (logged set summary) ─────────────────────────────────────────

class _SetChip extends StatelessWidget {
  const _SetChip({required this.index, required this.set});
  final int index;
  final WorkoutSet set;

  @override
  Widget build(BuildContext context) {
    final weightStr =
        set.weight != null ? ' × ${set.weight}kg' : '';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.chipBg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Text(
            'Set ${index + 1}',
            style: GoogleFonts.quicksand(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.muted),
          ),
          const SizedBox(width: 12),
          Text(
            '${set.reps} reps$weightStr',
            style: GoogleFonts.baloo2(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.text),
          ),
          if (set.failure) ...[
            const Spacer(),
            const Icon(Icons.local_fire_department,
                size: 16, color: AppColors.failText),
          ],
        ],
      ),
    );
  }
}

// ── Stepper card ───────────────────────────────────────────────────────────

class _StepperCard extends StatelessWidget {
  const _StepperCard({
    required this.label,
    required this.value,
    required this.onIncrement,
    this.onDecrement,
  });
  final String label;
  final int value;
  final VoidCallback? onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [AppTheme.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.quicksand(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.muted,
                letterSpacing: 1.2),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StepperButton(
                icon: Icons.remove,
                filled: false,
                onTap: onDecrement,
              ),
              Text(
                '$value',
                style: GoogleFonts.baloo2(
                    fontSize: 44,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text),
              ),
              _StepperButton(
                icon: Icons.add,
                filled: true,
                onTap: onIncrement,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.filled,
    required this.onTap,
  });
  final IconData icon;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: onTap == null
              ? AppColors.border
              : filled
                  ? AppColors.primary
                  : AppColors.chipBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          size: 26,
          color: onTap == null
              ? AppColors.muted
              : filled
                  ? AppColors.onPrimary
                  : AppColors.chipText,
        ),
      ),
    );
  }
}

// ── Weight card ────────────────────────────────────────────────────────────

class _WeightCard extends StatelessWidget {
  const _WeightCard({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [AppTheme.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WEIGHT (KG) — OPTIONAL',
            style: GoogleFonts.quicksand(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.muted,
                letterSpacing: 1.2),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            style: GoogleFonts.baloo2(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: AppColors.text),
            decoration: InputDecoration(
              hintText: '—',
              hintStyle: GoogleFonts.baloo2(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.border),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              suffixText: 'kg',
              suffixStyle: GoogleFonts.quicksand(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Failure toggle card ────────────────────────────────────────────────────

class _FailureCard extends StatelessWidget {
  const _FailureCard({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(26),
          boxShadow: const [AppTheme.cardShadow],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Went to failure?',
                    style: GoogleFonts.baloo2(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text),
                  ),
                  Text(
                    'Last set with nothing left',
                    style: GoogleFonts.quicksand(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.muted),
                  ),
                ],
              ),
            ),
            _Toggle(value: value),
          ],
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({required this.value});
  final bool value;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 54,
      height: 31,
      decoration: BoxDecoration(
        color: value ? AppColors.primary : AppColors.border,
        borderRadius: BorderRadius.circular(100),
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 200),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 25,
          height: 25,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Analyze**

```
flutter analyze lib/features/workout/ui/add_entry_screen.dart
```

- [ ] **Step 3: Commit**

```
git add lib/features/workout/ui/add_entry_screen.dart
git commit -m "feat(workout): add AddEntryScreen with set-by-set logging"
```

---

### Task 9: ProgressScreen

**Files:**
- Create: `lib/features/workout/ui/progress_screen.dart`

**Consumes:** `weeklyProgressProvider(DateTime)` (Task 3); `WeeklyStats`, `DayVolume` (Task 3); `weekLabel`, `weekStart` from `workout_date_utils.dart` (Task 1); `AppColors`, `AppTheme`

- [ ] **Step 1: Create `lib/features/workout/ui/progress_screen.dart`**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/theme.dart';
import '../data/workout_date_utils.dart';
import '../providers/workout_providers.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  late DateTime _weekStart;

  @override
  void initState() {
    super.initState();
    _weekStart = weekStart(DateTime.now());
  }

  void _prevWeek() =>
      setState(() => _weekStart = _weekStart.subtract(const Duration(days: 7)));

  void _nextWeek() {
    final nextStart = _weekStart.add(const Duration(days: 7));
    final currentStart = weekStart(DateTime.now());
    if (nextStart.isAfter(currentStart)) return; // can't go past current week
    setState(() => _weekStart = nextStart);
  }

  bool get _isCurrentWeek => _weekStart == weekStart(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(weeklyProgressProvider(_weekStart));

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'THIS WEEK',
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.muted,
                      letterSpacing: 1.6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your Gains',
                    style: GoogleFonts.baloo2(
                      fontSize: 31,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stat cards (2)
                    Row(
                      children: [
                        _StatCard(
                            value: '${stats.workoutDays}',
                            label: 'WORKOUTS'),
                        const SizedBox(width: 10),
                        _StatCard(
                            value: '${stats.totalReps}',
                            label: 'TOTAL REPS'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Weekly volume chart card
                    _WeeklyChart(
                      stats: stats,
                      weekLabel: weekLabel(_weekStart),
                      onPrev: _prevWeek,
                      onNext: _isCurrentWeek ? null : _nextWeek,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stat card ──────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [AppTheme.cardShadow],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.baloo2(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text),
            ),
            Text(
              label,
              style: GoogleFonts.quicksand(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Weekly volume chart ────────────────────────────────────────────────────

class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart({
    required this.stats,
    required this.weekLabel,
    required this.onPrev,
    required this.onNext,
  });
  final WeeklyStats stats;
  final String weekLabel;
  final VoidCallback onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final maxVol =
        stats.days.map((d) => d.volume).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [AppTheme.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + week navigation
          Row(
            children: [
              Expanded(
                child: Text(
                  'Weekly volume',
                  style: GoogleFonts.baloo2(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left,
                    color: AppColors.muted, size: 22),
                onPressed: onPrev,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 4),
              Text(
                weekLabel,
                style: GoogleFonts.quicksand(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.muted),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(
                  Icons.chevron_right,
                  color: onNext != null ? AppColors.muted : AppColors.border,
                  size: 22,
                ),
                onPressed: onNext,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Bars
          SizedBox(
            height: 130,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: stats.days.map((day) {
                final frac = maxVol > 0 ? day.volume / maxVol : 0.0;
                final barH = maxVol > 0
                    ? (frac * 120).clamp(5.0, 120.0)
                    : 5.0;
                final hasVolume = day.volume > 0;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: barH,
                          decoration: BoxDecoration(
                            color: hasVolume
                                ? AppColors.primary
                                : AppColors.border,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                              bottomLeft: Radius.circular(5),
                              bottomRight: Radius.circular(5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          day.label,
                          style: GoogleFonts.quicksand(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 2: Analyze**

```
flutter analyze lib/features/workout/ui/progress_screen.dart
```

- [ ] **Step 3: Commit**

```
git add lib/features/workout/ui/progress_screen.dart
git commit -m "feat(workout): add ProgressScreen with weekly chart and past-week navigation"
```

---

## Post-implementation smoke test checklist

Run `flutter run` on a connected Android device and verify each flow:

- [ ] Main bottom nav shows 4 tabs; tapping Workouts switches to Exercises sub-nav
- [ ] Android back from Workouts section returns to previous tab
- [ ] Exercise list is empty initially; FAB opens Add Exercise
- [ ] Add Exercise: body part chips update icon preview live; Create navigates back to list
- [ ] New exercise appears in list; tile color cycles correctly
- [ ] Filter chips filter by body part; Archived toggle shows only archived exercises
- [ ] Tap exercise row → Exercise Detail; back arrow returns to list
- [ ] Detail shows stat cards (0 sessions initially) and empty history state
- [ ] Tap "Add entry" → Add Entry; add 2+ sets; Save entry → returns to detail; stats/history update
- [ ] Swipe entry in history → delete dialog → confirm deletes entry
- [ ] Failure toggle animates; sets with failure show fire badge in history
- [ ] Long-press or swipe exercise row → archive / delete options (see note below)
- [ ] Progress tab shows stat cards; weekly chart shows bars for workout days
- [ ] Prev/Next week navigation works; Next is disabled on the current week

**Note on archive/delete from exercise list:** The ExerciseListScreen above navigates to ExerciseDetail on tap. Add long-press to `_ExerciseRow` to show a bottom sheet with Archive / Delete options, calling `workoutRepositoryProvider.archiveExercise()` or `.deleteExercise()`. This is a small addition not broken into a separate task.

---

## Firestore index notes

The `watchExercises` query orders by `createdAt` and may also filter by `isArchived`. Firestore will prompt you with a console link to create the required composite index the first time the query runs — follow that link.

Similarly, `watchEntriesForWeek` filters by date range. A single-field index on `date` (descending) handles this; Firestore creates single-field indexes automatically.
