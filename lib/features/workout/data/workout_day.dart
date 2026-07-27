import 'package:freezed_annotation/freezed_annotation.dart';

part 'workout_day.freezed.dart';
part 'workout_day.g.dart';

@freezed
abstract class WorkoutDay with _$WorkoutDay {
  const factory WorkoutDay({
    required String id,
    required String name,
    required int order,
  }) = _WorkoutDay;

  factory WorkoutDay.fromJson(Map<String, dynamic> json) =>
      _$WorkoutDayFromJson(json);
}
