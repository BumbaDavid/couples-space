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
  double get volume =>
      sets.fold<double>(0.0, (s, set) => s + set.reps * (set.weight ?? 1.0));

  int get totalReps => sets.fold<int>(0, (s, set) => s + set.reps);
}
