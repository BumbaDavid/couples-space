// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FoodCard _$FoodCardFromJson(Map<String, dynamic> json) => _FoodCard(
  id: json['id'] as String,
  name: json['name'] as String,
  proteinGrams: (json['proteinGrams'] as num).toInt(),
  icon: json['icon'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$FoodCardToJson(_FoodCard instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'proteinGrams': instance.proteinGrams,
  'icon': instance.icon,
  'createdAt': instance.createdAt.toIso8601String(),
};
