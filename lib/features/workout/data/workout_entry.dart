import 'package:freezed_annotation/freezed_annotation.dart';

import 'workout_set.dart';

part 'workout_entry.freezed.dart';
part 'workout_entry.g.dart';

@freezed
abstract class WorkoutEntry with _$WorkoutEntry {
  const factory WorkoutEntry({
    required String id,
    required String exerciseId,
    @Default([]) List<WorkoutSet> sets,
    required DateTime date,
    // endurance fields (null for strength entries)
    int? durationMinutes,
    double? distanceKm,
    double? speed,
    int? resistance,
  }) = _WorkoutEntry;

  factory WorkoutEntry.fromJson(Map<String, dynamic> json) =>
      _$WorkoutEntryFromJson(json);
}

extension WorkoutEntryStats on WorkoutEntry {
  bool get isEndurance => durationMinutes != null;

  double get volume =>
      sets.fold<double>(0.0, (s, set) => s + set.reps * (set.weight ?? 1.0));

  int get totalReps => sets.fold<int>(0, (s, set) => s + set.reps);
}

String formatDuration(int minutes) {
  if (minutes < 60) return '${minutes}m';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return m == 0 ? '${h}h' : '${h}h ${m}m';
}
