import 'package:freezed_annotation/freezed_annotation.dart';

part 'food_card.freezed.dart';
part 'food_card.g.dart';

/// A reusable food the user taps to log, e.g. "Whey shake — 25g".
///
/// Lives in the couple's *shared* catalog at `couples/{coupleId}/foods` —
/// food facts ("an egg has ~6g") are shared knowledge, not personal data.
/// The log built from these cards is private per user.
@freezed
abstract class FoodCard with _$FoodCard {
  const factory FoodCard({
    required String id,
    required String name,

    /// Grams of protein per serving. Clamped 1..120 by the editor.
    required int proteinGrams,

    /// Key into [ProteinIcons.byName] — a string, so the stored document is
    /// not coupled to Flutter's icon codepoints.
    required String icon,

    /// Catalog ordering. Also determines the tile colour, which cycles
    /// `AppColors.tilePalette` by the card's index in this ordering.
    required DateTime createdAt,
  }) = _FoodCard;

  factory FoodCard.fromJson(Map<String, dynamic> json) =>
      _$FoodCardFromJson(json);
}
