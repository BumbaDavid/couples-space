// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WorkoutEntry _$WorkoutEntryFromJson(Map<String, dynamic> json) =>
    _WorkoutEntry(
      id: json['id'] as String,
      exerciseId: json['exerciseId'] as String,
      sets:
          (json['sets'] as List<dynamic>?)
              ?.map((e) => WorkoutSet.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      date: DateTime.parse(json['date'] as String),
      durationMinutes: (json['durationMinutes'] as num?)?.toInt(),
      distanceKm: (json['distanceKm'] as num?)?.toDouble(),
      speed: (json['speed'] as num?)?.toDouble(),
      resistance: (json['resistance'] as num?)?.toInt(),
    );

Map<String, dynamic> _$WorkoutEntryToJson(_WorkoutEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'exerciseId': instance.exerciseId,
      'sets': instance.sets,
      'date': instance.date.toIso8601String(),
      'durationMinutes': instance.durationMinutes,
      'distanceKm': instance.distanceKm,
      'speed': instance.speed,
      'resistance': instance.resistance,
    };
