import 'package:freezed_annotation/freezed_annotation.dart';

part 'workout_set.freezed.dart';
part 'workout_set.g.dart';

@freezed
abstract class WorkoutSet with _$WorkoutSet {
  const factory WorkoutSet({
    required int reps,
    double? weight,
    @Default(false) bool failure,
  }) = _WorkoutSet;

  factory WorkoutSet.fromJson(Map<String, dynamic> json) =>
      _$WorkoutSetFromJson(json);
}
