import 'package:freezed_annotation/freezed_annotation.dart';

part 'couple.freezed.dart';
part 'couple.g.dart';

@freezed
abstract class Couple with _$Couple {
  const factory Couple({
    required String id,
    required List<String> memberIds,
    required DateTime createdAt,
  }) = _Couple;

  factory Couple.fromJson(Map<String, dynamic> json) => _$CoupleFromJson(json);
}
