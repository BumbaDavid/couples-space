// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Reminder _$ReminderFromJson(Map<String, dynamic> json) => _Reminder(
  id: json['id'] as String,
  message: json['message'] as String,
  hour: (json['hour'] as num).toInt(),
  minute: (json['minute'] as num).toInt(),
  days:
      (json['days'] as List<dynamic>?)?.map((e) => e as bool).toList() ??
      const [false, false, false, false, false, false, false],
  enabled: json['enabled'] as bool? ?? true,
);

Map<String, dynamic> _$ReminderToJson(_Reminder instance) => <String, dynamic>{
  'id': instance.id,
  'message': instance.message,
  'hour': instance.hour,
  'minute': instance.minute,
  'days': instance.days,
  'enabled': instance.enabled,
};
