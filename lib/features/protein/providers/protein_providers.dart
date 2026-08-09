import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../../profile/data/user_providers.dart';
import '../data/food_card.dart';
import '../data/protein_date_utils.dart';
import '../data/protein_entry.dart';
import '../data/protein_repository.dart';
import '../data/protein_slot.dart';

// ── Repository ───────────────────────────────────────────────────────────────

final proteinRepositoryProvider = Provider<ProteinRepository>((ref) {
  final authUser = ref.watch(authStateChangesProvider).asData?.value;
  if (authUser == null) throw StateError('proteinRepository requires auth');
  return ProteinRepository(
    db: ref.watch(firestoreProvider),
    userId: authUser.uid,
  );
});

/// The couple this user belongs to, or null while unpaired. The food catalog
/// is couple-scoped, so every catalog screen needs this first.
final proteinCoupleIdProvider = Provider<String?>((ref) {
  return ref.watch(currentUserProfileProvider).asData?.value?.coupleId;
});

/// The user's daily target. Read off the existing profile stream; defaults to
/// 110 for documents written before this feature existed.
final proteinTargetProvider = Provider<int>((ref) {
  return ref.watch(currentUserProfileProvider).asData?.value?.proteinTargetGrams ??
      110;
});

// ── Food catalog ─────────────────────────────────────────────────────────────

final foodCardsProvider = StreamProvider<List<FoodCard>>((ref) {
  final coupleId = ref.watch(proteinCoupleIdProvider);
  if (coupleId == null) return Stream.value(const <FoodCard>[]);
  return ref.watch(proteinRepositoryProvider).watchFoods(coupleId);
});

// View state (selected day, selected week, selected slot) is deliberately held
// in each screen's ConsumerState with setState, matching `progress_screen.dart`.
// Riverpod 3 removed StateProvider, and this state is screen-local anyway.

// ── Log ──────────────────────────────────────────────────────────────────────

final dayEntriesProvider =
    StreamProvider.family<List<ProteinEntry>, String>((ref, day) {
  return ref.watch(proteinRepositoryProvider).watchDay(day);
});

class WeekRange {
  const WeekRange(this.startDay, this.endDay);
  final String startDay;
  final String endDay;

  @override
  bool operator ==(Object other) =>
      other is WeekRange && startDay == other.startDay && endDay == other.endDay;

  @override
  int get hashCode => Object.hash(startDay, endDay);
}

final weekEntriesProvider =
    StreamProvider.family<List<ProteinEntry>, WeekRange>((ref, range) {
  return ref
      .watch(proteinRepositoryProvider)
      .watchWeek(range.startDay, range.endDay);
});

// ── Derived day totals ───────────────────────────────────────────────────────

/// Total grams logged on the currently selected day.
final dayTotalProvider = Provider.family<int, String>((ref, day) {
  final entries = ref.watch(dayEntriesProvider(day)).asData?.value ?? [];
  return entries.fold<int>(0, (sum, e) => sum + e.total);
});

/// Entries grouped by slot, in slot order, with empty slots omitted.
final dayEntriesBySlotProvider =
    Provider.family<List<(ProteinSlot, List<ProteinEntry>)>, String>((ref, day) {
  final entries = ref.watch(dayEntriesProvider(day)).asData?.value ?? [];
  final grouped = <(ProteinSlot, List<ProteinEntry>)>[];
  for (final slot in ProteinSlot.values) {
    final inSlot = entries.where((e) => e.slot == slot).toList();
    if (inSlot.isNotEmpty) grouped.add((slot, inSlot));
  }
  return grouped;
});

// ── Weekly stats ─────────────────────────────────────────────────────────────

class DayTotal {
  const DayTotal({required this.label, required this.grams});
  final String label;
  final int grams;
  bool get logged => grams > 0;
}

class WeeklyProteinStats {
  const WeeklyProteinStats({
    required this.days,
    required this.daysLogged,
    required this.weekTotal,
  });

  final List<DayTotal> days;
  final int daysLogged;
  final int weekTotal;

  /// Total divided by the number of days actually logged — **never** by 7.
  /// Dividing by 7 would let an unlogged day silently drag the number down,
  /// which is exactly the punishment signal this feature removes.
  int get average => daysLogged == 0 ? 0 : (weekTotal / daysLogged).round();

  bool get isEmpty => daysLogged == 0;

  /// Tallest bar in the week, used to scale the chart. Never zero, so callers
  /// can divide by it safely.
  int get maxDayGrams =>
      days.fold<int>(1, (m, d) => d.grams > m ? d.grams : m);
}

final weeklyProteinStatsProvider =
    Provider.family<WeeklyProteinStats, DateTime>((ref, weekStart) {
  final keys = ProteinDates.weekDayKeys(weekStart);
  final range = WeekRange(keys.first, keys.last);
  final entries = ref.watch(weekEntriesProvider(range)).asData?.value ?? [];

  final totals = {for (final k in keys) k: 0};
  for (final entry in entries) {
    if (totals.containsKey(entry.day)) {
      totals[entry.day] = totals[entry.day]! + entry.total;
    }
  }

  const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  final days = [
    for (var i = 0; i < 7; i++)
      DayTotal(label: labels[i], grams: totals[keys[i]]!),
  ];

  return WeeklyProteinStats(
    days: days,
    daysLogged: days.where((d) => d.logged).length,
    weekTotal: days.fold<int>(0, (sum, d) => sum + d.grams),
  );
});
