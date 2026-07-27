import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../data/exercise.dart';
import '../data/workout_date_utils.dart';
import '../data/workout_day.dart';
import '../data/workout_entry.dart';
import '../data/workout_icons.dart';
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

// ── Days ────────────────────────────────────────────────────────────────────

final daysProvider = StreamProvider<List<WorkoutDay>>((ref) {
  return ref.watch(workoutRepositoryProvider).watchDays();
});

// ── Exercises ───────────────────────────────────────────────────────────────

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

class WeeklyEntriesParams {
  const WeeklyEntriesParams(this.exerciseId, this.start, this.end);
  final String exerciseId;
  final DateTime start;
  final DateTime end;

  @override
  bool operator ==(Object other) =>
      other is WeeklyEntriesParams &&
      exerciseId == other.exerciseId &&
      start == other.start &&
      end == other.end;

  @override
  int get hashCode => Object.hash(exerciseId, start, end);
}

final weeklyEntriesProvider =
    StreamProvider.family<List<WorkoutEntry>, WeeklyEntriesParams>(
        (ref, params) {
  return ref
      .watch(workoutRepositoryProvider)
      .watchEntriesForWeek(params.exerciseId, params.start, params.end);
});

// ── Weekly progress (derived, sync) ─────────────────────────────────────────

class DayVolume {
  const DayVolume({required this.label, required this.volume});
  final String label;
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
  final List<DayVolume> days;

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

final weeklyProgressProvider =
    Provider.family<WeeklyStats, DateTime>((ref, start) {
  final end = weekEnd(start);
  final exercises =
      ref.watch(exercisesProvider(false)).asData?.value ?? [];
  final strengthExercises =
      exercises.where((e) => !WorkoutIcons.isEndurance(e.bodyPart)).toList();

  final dayVolumes = List<double>.filled(7, 0);
  final activeDays = <int>{};
  var totalReps = 0;

  for (final exercise in strengthExercises) {
    final params = WeeklyEntriesParams(exercise.id, start, end);
    final entries =
        ref.watch(weeklyEntriesProvider(params)).asData?.value ?? [];
    for (final entry in entries) {
      final dayIdx = entry.date.weekday - 1;
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
