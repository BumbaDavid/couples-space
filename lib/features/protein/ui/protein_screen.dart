import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/theme.dart';
import '../data/food_card.dart';
import '../data/protein_date_utils.dart';
import '../data/protein_entry.dart';
import '../data/protein_icons.dart';
import '../data/protein_repository.dart';
import '../data/protein_slot.dart';
import '../providers/protein_providers.dart';
import 'edit_entry_screen.dart';
import 'food_cards_screen.dart';
import 'protein_target_screen.dart';
import 'widgets/protein_common.dart';
import 'widgets/protein_ring.dart';

/// S1 — the Protein tab's default screen.
class ProteinScreen extends ConsumerStatefulWidget {
  const ProteinScreen({super.key});

  @override
  ConsumerState<ProteinScreen> createState() => _ProteinScreenState();
}

class _ProteinScreenState extends ConsumerState<ProteinScreen> {
  late DateTime _date;
  late ProteinSlot _slot;

  String? _undoEntryId;
  Timer? _undoTimer;

  @override
  void initState() {
    super.initState();
    _date = ProteinDates.today();
    _slot = ProteinSlotX.now();
  }

  @override
  void dispose() {
    _undoTimer?.cancel();
    super.dispose();
  }

  void _prevDay() =>
      setState(() => _date = _date.subtract(const Duration(days: 1)));

  void _nextDay() {
    final next = _date.add(const Duration(days: 1));
    if (!ProteinDates.isTodayOrLater(next) ||
        ProteinDates.daysAgo(next) == 0) {
      setState(() => _date = next);
    }
  }

  Future<void> _log(FoodCard card) async {
    final day = ProteinDates.dayKey(_date);
    final entries =
        ref.read(dayEntriesProvider(day)).asData?.value ??
        const <ProteinEntry>[];
    try {
      final id = await ref.read(proteinRepositoryProvider).logCard(
            card,
            day: day,
            slot: _slot,
            dayEntries: entries,
          );
      if (!mounted) return;
      _undoTimer?.cancel();
      setState(() => _undoEntryId = id);
      _undoTimer = Timer(const Duration(seconds: 4), () {
        if (mounted) setState(() => _undoEntryId = null);
      });
    } on ProteinException catch (e) {
      _showMessage(e.message);
    }
  }

  Future<void> _undo() async {
    final id = _undoEntryId;
    if (id == null) return;
    _undoTimer?.cancel();
    setState(() => _undoEntryId = null);

    final entries =
        ref.read(dayEntriesProvider(ProteinDates.dayKey(_date))).asData?.value ??
        const <ProteinEntry>[];
    ProteinEntry? entry;
    for (final e in entries) {
      if (e.id == id) entry = e;
    }
    if (entry == null) return;
    try {
      await ref.read(proteinRepositoryProvider).decrementEntry(entry);
    } on ProteinException catch (e) {
      _showMessage(e.message);
    }
  }

  Future<void> _decrement(ProteinEntry entry) async {
    try {
      await ref.read(proteinRepositoryProvider).decrementEntry(entry);
    } on ProteinException catch (e) {
      _showMessage(e.message);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.quicksand(fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dayKey = ProteinDates.dayKey(_date);
    final cards = ref.watch(foodCardsProvider).asData?.value ?? const <FoodCard>[];
    final total = ref.watch(dayTotalProvider(dayKey));
    final target = ref.watch(proteinTargetProvider);
    final grouped = ref.watch(dayEntriesBySlotProvider(dayKey));

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: [
            _header(),
            const SizedBox(height: 18),
            Center(
              child: ProteinRing(
                total: total,
                target: target,
                loggedLabel: ProteinDates.loggedLabel(_date),
              ),
            ),
            const SizedBox(height: 12),
            Center(child: _targetPill(target)),
            const SizedBox(height: 24),
            _sectionRow(),
            const SizedBox(height: 11),
            _slotGrid(),
            const SizedBox(height: 14),
            if (cards.isEmpty) _noCardsEmptyState() else _cardStrip(cards),
            const SizedBox(height: 24),
            Eyebrow(ProteinDates.logHeading(_date)),
            const SizedBox(height: 12),
            if (grouped.isEmpty)
              ProteinEmptyState(
                icon: Icons.bookmark_border,
                title: 'Nothing here yet',
                body: ProteinDates.daysAgo(_date) == 0
                    ? 'Tap a card above whenever you eat something.'
                    : 'Nothing was logged on this day.',
              )
            else
              ...grouped.map((g) => _slotGroup(g.$1, g.$2, cards)),
          ],
        ),
        if (_undoEntryId != null)
          Positioned(left: 16, right: 16, bottom: 16, child: _undoToast()),
      ],
    );
  }

  Widget _header() {
    final canGoForward = ProteinDates.daysAgo(_date) > 0;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Eyebrow('Protein'),
              const SizedBox(height: 2),
              Text(
                ProteinDates.dayTitle(_date),
                style: GoogleFonts.baloo2(
                  fontSize: 29,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
        ),
        ArrowButton(icon: Icons.chevron_left, onTap: _prevDay),
        const SizedBox(width: 8),
        ArrowButton(
          icon: Icons.chevron_right,
          onTap: _nextDay,
          enabled: canGoForward,
        ),
      ],
    );
  }

  Widget _targetPill(int target) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const ProteinTargetScreen()),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.chipBg,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.flag, size: 17, color: AppColors.chipText),
            const SizedBox(width: 6),
            Text(
              'Target ${target}g',
              style: GoogleFonts.quicksand(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.chipText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Eyebrow('Log into'),
        GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const FoodCardsScreen()),
          ),
          child: Text(
            'Edit cards',
            style: GoogleFonts.quicksand(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.chipText,
            ),
          ),
        ),
      ],
    );
  }

  /// A 5-column grid, never a horizontal scroller: with chips in a row the
  /// selected one lands off-screen whenever the clock seeds evening or night —
  /// exactly when someone is logging dinner.
  Widget _slotGrid() {
    return Row(
      children: [
        for (final slot in ProteinSlot.values) ...[
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _slot = slot),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.fromLTRB(2, 10, 2, 9),
                decoration: BoxDecoration(
                  color: slot == _slot ? AppColors.primary : AppColors.chipBg,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: slot == _slot ? const [AppTheme.buttonShadow] : null,
                ),
                child: Column(
                  children: [
                    Icon(
                      slot.icon,
                      size: 19,
                      color: slot == _slot
                          ? AppColors.onPrimary
                          : AppColors.chipText,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      slot.shortLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.quicksand(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: slot == _slot
                            ? AppColors.onPrimary
                            : AppColors.chipText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (slot != ProteinSlot.values.last) const SizedBox(width: 7),
        ],
      ],
    );
  }

  Widget _noCardsEmptyState() {
    return ProteinEmptyState(
      icon: Icons.restaurant,
      iconColor: AppColors.primary,
      iconSize: 42,
      title: "Let's make your first card",
      body: 'Cards are the foods you eat often. One tap logs them.',
      action: GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const FoodCardsScreen()),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(100),
            boxShadow: const [AppTheme.buttonShadow],
          ),
          child: Text(
            'Create a card',
            style: GoogleFonts.baloo2(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.onPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _cardStrip(List<FoodCard> cards) {
    return SizedBox(
      height: 142,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 0),
        itemCount: cards.length + 1,
        separatorBuilder: (_, _) => const SizedBox(width: 11),
        itemBuilder: (context, i) {
          if (i == cards.length) return _newCardTile();
          final card = cards[i];
          final tile = tileFor(i);
          return GestureDetector(
            onTap: () => _log(card),
            child: Container(
              width: 98,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(22),
                boxShadow: const [AppTheme.cardShadow],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: tile.background,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      ProteinIcons.forName(card.icon),
                      color: tile.iconColor,
                      size: 27,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    card.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.baloo2(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.chipBg,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      '${card.proteinGrams}g',
                      style: GoogleFonts.quicksand(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.chipText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _newCardTile() {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const FoodCardsScreen()),
      ),
      child: Container(
        width: 98,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.border,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, size: 26, color: AppColors.muted),
            const SizedBox(height: 6),
            Text(
              'New card',
              style: GoogleFonts.quicksand(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _slotGroup(
    ProteinSlot slot,
    List<ProteinEntry> entries,
    List<FoodCard> cards,
  ) {
    final sum = entries.fold<int>(0, (s, e) => s + e.total);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(slot.icon, size: 17, color: AppColors.muted),
            const SizedBox(width: 6),
            Text(
              slot.label.toUpperCase(),
              style: GoogleFonts.quicksand(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.muted,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(child: Divider(color: AppColors.border)),
            const SizedBox(width: 10),
            Text(
              '${sum}g',
              style: GoogleFonts.quicksand(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...entries.map((e) => _entryRow(e, cards)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _entryRow(ProteinEntry entry, List<FoodCard> cards) {
    final index = cards.indexWhere((c) => c.id == entry.cardId);
    final tile = tileFor(index < 0 ? entry.name.hashCode : index);
    final repeated = entry.count > 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [AppTheme.cardShadow],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => EditEntryScreen(entry: entry, date: _date),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: tile.background,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      ProteinIcons.forName(entry.icon),
                      color: tile.iconColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                entry.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.baloo2(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.text,
                                ),
                              ),
                            ),
                            if (repeated) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.chipBg,
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Text(
                                  '×${entry.count}',
                                  style: GoogleFonts.quicksand(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.chipText,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          repeated
                              ? '${entry.slot.label} · ${entry.unit}g each'
                              : entry.slot.label,
                          style: GoogleFonts.quicksand(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${entry.total}g',
                    style: GoogleFonts.baloo2(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.overfill,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Steps a stack down; removes the row on the last serving. Never
          // styled as destructive — taking something off the list is a
          // correction, not a failure.
          GestureDetector(
            onTap: () => _decrement(entry),
            child: SizedBox(
              width: 44,
              height: 44,
              child: Icon(
                repeated ? Icons.remove : Icons.backspace,
                size: 20,
                color: AppColors.muted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _undoToast() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.text,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [AppTheme.toastShadow],
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 20, color: AppColors.primarySoft),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Added to ${_slot.label.toLowerCase()}',
              style: GoogleFonts.quicksand(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.onToast,
              ),
            ),
          ),
          GestureDetector(
            onTap: _undo,
            child: Text(
              'Undo',
              style: GoogleFonts.quicksand(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.onToastAction,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
