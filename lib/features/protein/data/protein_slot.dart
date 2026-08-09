import 'package:flutter/material.dart';

/// A time-of-day bucket for a protein log entry. Deliberately a coarse slot
/// rather than a timestamp — the design records *roughly when* something was
/// eaten, not the exact minute.
enum ProteinSlot { morning, noon, afternoon, evening, night }

extension ProteinSlotX on ProteinSlot {
  /// Full name, used everywhere except the 5-column selector grid.
  String get label => switch (this) {
    ProteinSlot.morning => 'Morning',
    ProteinSlot.noon => 'Noon',
    ProteinSlot.afternoon => 'Afternoon',
    ProteinSlot.evening => 'Evening',
    ProteinSlot.night => 'Night',
  };

  /// Abbreviated name. Only for the 5-column grid, where the full word does
  /// not fit at 412px.
  String get shortLabel =>
      this == ProteinSlot.afternoon ? 'Aft.' : label;

  IconData get icon => switch (this) {
    ProteinSlot.morning => Icons.wb_twilight,
    ProteinSlot.noon => Icons.light_mode,
    ProteinSlot.afternoon => Icons.wb_sunny,
    ProteinSlot.evening => Icons.nights_stay,
    ProteinSlot.night => Icons.bedtime,
  };

  /// The slot the clock currently falls into. Seeds the selector so the fast
  /// path (open, tap a card) needs no extra input.
  static ProteinSlot fromHour(int hour) {
    if (hour < 11) return ProteinSlot.morning;
    if (hour < 14) return ProteinSlot.noon;
    if (hour < 17) return ProteinSlot.afternoon;
    if (hour < 21) return ProteinSlot.evening;
    return ProteinSlot.night;
  }

  static ProteinSlot now() => fromHour(DateTime.now().hour);
}
