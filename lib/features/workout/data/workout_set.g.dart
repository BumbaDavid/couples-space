// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_set.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WorkoutSet _$WorkoutSetFromJson(Map<String, dynamic> json) => _WorkoutSet(
  reps: (json['reps'] as num).toInt(),
  weight: (json['weight'] as num?)?.toDouble(),
  failure: json['failure'] as bool? ?? false,
);

Map<String, dynamic> _$WorkoutSetToJson(_WorkoutSet instance) =>
    <String, dynamic>{
      'reps': instance.reps,
      'weight': instance.weight,
      'failure': instance.failure,
    };
