// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'protein_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProteinEntry _$ProteinEntryFromJson(Map<String, dynamic> json) =>
    _ProteinEntry(
      id: json['id'] as String,
      day: json['day'] as String,
      cardId: json['cardId'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      unit: (json['unit'] as num).toInt(),
      count: (json['count'] as num?)?.toInt() ?? 1,
      slot: $enumDecode(_$ProteinSlotEnumMap, json['slot']),
    );

Map<String, dynamic> _$ProteinEntryToJson(_ProteinEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'day': instance.day,
      'cardId': instance.cardId,
      'name': instance.name,
      'icon': instance.icon,
      'unit': instance.unit,
      'count': instance.count,
      'slot': _$ProteinSlotEnumMap[instance.slot]!,
    };

const _$ProteinSlotEnumMap = {
  ProteinSlot.morning: 'morning',
  ProteinSlot.noon: 'noon',
  ProteinSlot.afternoon: 'afternoon',
  ProteinSlot.evening: 'evening',
  ProteinSlot.night: 'night',
};
