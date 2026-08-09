import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

enum AppThemeMode { light, dark, system }

@freezed
abstract class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String email,
    required String displayName,
    String? coupleId,
    @Default(AppThemeMode.system) AppThemeMode themeMode,

    /// Daily protein target in grams. Per-user; edited on the protein screen,
    /// not in Profile. `@Default` lets user documents written before this
    /// feature decode without a migration.
    @Default(110) int proteinTargetGrams,
    required DateTime createdAt,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}
