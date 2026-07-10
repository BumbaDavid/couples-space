// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WorkoutEntry _$WorkoutEntryFromJson(Map<String, dynamic> json) =>
    _WorkoutEntry(
      id: json['id'] as String,
      exerciseId: json['exerciseId'] as String,
      sets: (json['sets'] as List<dynamic>)
          .map((e) => WorkoutSet.fromJson(e as Map<String, dynamic>))
          .toList(),
      date: DateTime.parse(json['date'] as String),
    );

Map<String, dynamic> _$WorkoutEntryToJson(_WorkoutEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'exerciseId': instance.exerciseId,
      'sets': instance.sets,
      'date': instance.date.toIso8601String(),
    };
