import 'package:freezed_annotation/freezed_annotation.dart';

import 'protein_slot.dart';

part 'protein_entry.freezed.dart';
part 'protein_entry.g.dart';

/// One logged serving (or stack of identical servings) of a food.
///
/// Stored privately at `users/{userId}/proteinLog` — never visible to the
/// partner, even though this is a couples app. That is a hard invariant.
@freezed
abstract class ProteinEntry with _$ProteinEntry {
  const factory ProteinEntry({
    required String id,

    /// Day bucket as `yyyy-MM-dd`. A string rather than a Timestamp so day
    /// identity is exact and immune to timezone/DST drift — see
    /// `docs/superpowers/specs/2026-08-08-protein-tracker-design.md`.
    required String day,

    required String cardId,

    /// Snapshotted from the card at log time. Renaming or deleting a card must
    /// never rewrite history or change a past weekly average.
    required String name,
    required String icon,

    /// Grams per single serving. Clamped 1..200 by the entry editor.
    required int unit,

    /// How many identical servings this row represents. Repeat taps of the
    /// same card in the same day+slot at the same unit increment this instead
    /// of creating another row.
    @Default(1) int count,

    required ProteinSlot slot,
  }) = _ProteinEntry;

  factory ProteinEntry.fromJson(Map<String, dynamic> json) =>
      _$ProteinEntryFromJson(json);
}

extension ProteinEntryX on ProteinEntry {
  int get total => unit * count;
}
