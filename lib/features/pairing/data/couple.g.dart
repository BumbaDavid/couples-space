// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'couple.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Couple _$CoupleFromJson(Map<String, dynamic> json) => _Couple(
  id: json['id'] as String,
  memberIds: (json['memberIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$CoupleToJson(_Couple instance) => <String, dynamic>{
  'id': instance.id,
  'memberIds': instance.memberIds,
  'createdAt': instance.createdAt.toIso8601String(),
};
