// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_day.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WorkoutDay _$WorkoutDayFromJson(Map<String, dynamic> json) => _WorkoutDay(
  id: json['id'] as String,
  name: json['name'] as String,
  order: (json['order'] as num).toInt(),
);

Map<String, dynamic> _$WorkoutDayToJson(_WorkoutDay instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'order': instance.order,
    };
