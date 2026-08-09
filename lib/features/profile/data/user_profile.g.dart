// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => _UserProfile(
  id: json['id'] as String,
  email: json['email'] as String,
  displayName: json['displayName'] as String,
  coupleId: json['coupleId'] as String?,
  themeMode:
      $enumDecodeNullable(_$AppThemeModeEnumMap, json['themeMode']) ??
      AppThemeMode.system,
  proteinTargetGrams: (json['proteinTargetGrams'] as num?)?.toInt() ?? 110,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$UserProfileToJson(_UserProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'displayName': instance.displayName,
      'coupleId': instance.coupleId,
      'themeMode': _$AppThemeModeEnumMap[instance.themeMode]!,
      'proteinTargetGrams': instance.proteinTargetGrams,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$AppThemeModeEnumMap = {
  AppThemeMode.light: 'light',
  AppThemeMode.dark: 'dark',
  AppThemeMode.system: 'system',
};
