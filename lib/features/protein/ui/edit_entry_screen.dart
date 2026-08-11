import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_snack.dart';
import '../data/protein_date_utils.dart';
import '../data/protein_entry.dart';
import '../data/protein_icons.dart';
import '../data/protein_repository.dart';
import '../data/protein_slot.dart';
import '../providers/protein_providers.dart';
import 'widgets/protein_common.dart';

/// S4 — correct a logged entry: its per-serving amount, how many servings, or
/// which slot it belongs to. Removal is styled as a correction, never as a
/// destructive action.
class EditEntryScreen extends ConsumerStatefulWidget {
  const EditEntryScreen({super.key, required this.entry, required this.date});

  final ProteinEntry entry;
  final DateTime date;

  @override
  ConsumerState<EditEntryScreen> createState() => _EditEntryScreenState();
}

class _EditEntryScreenState extends ConsumerState<EditEntryScreen> {
  late int _unit;
  late int _count;
  late ProteinSlot _slot;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _unit = widget.entry.unit;
    _count = widget.entry.count;
    _slot = widget.entry.slot;
  }

  /// Pops first — the edit is applied to the local cache at once, so the row
  /// already shows its new value; the Future only waits on server ack.
  void _save() {
    if (_saving) return;
    final messenger = ScaffoldMessenger.of(context);
    final updated =
        widget.entry.copyWith(unit: _unit, count: _count, slot: _slot);
    final repo = ref.read(proteinRepositoryProvider);

    setState(() => _saving = true);
    Navigator.of(context).pop();

    repo
        .updateEntry(updated)
        .then((_) => AppSnack.showOn(messenger, 'Updated'))
        .catchError((Object e) => _reportError(messenger, e));
  }

  void _remove() {
    final messenger = ScaffoldMessenger.of(context);
    final name = widget.entry.name;
    final repo = ref.read(proteinRepositoryProvider);
    final id = widget.entry.id;

    Navigator.of(context).pop();

    repo
        .deleteEntry(id)
        .then((_) => AppSnack.showOn(messenger, '$name taken off the list'))
        .catchError((Object e) => _reportError(messenger, e));
  }

  void _reportError(ScaffoldMessengerState messenger, Object e) {
    AppSnack.errorOn(
      messenger,
      e is ProteinException ? e.message : 'Could not save that change.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final cards = ref.watch(foodCardsProvider).asData?.value ?? [];
    final index = cards.indexWhere((c) => c.id == widget.entry.cardId);
    final tile = tileFor(index < 0 ? widget.entry.name.hashCode : index);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.text),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(22, 6, 22, 130),
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: tile.background,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              ProteinIcons.forName(widget.entry.icon),
                              color: tile.iconColor,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.entry.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.baloo2(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.text,
                                  ),
                                ),
                                Text(
                                  ProteinDates.fullDate(widget.date),
                                  style: GoogleFonts.quicksand(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 26),
                      const Eyebrow('Amount each'),
                      const SizedBox(height: 10),
                      StepperCard(
                        value: _unit,
                        min: 1,
                        max: 200,
                        onChanged: (v) => setState(() => _unit = v),
                      ),
                      const SizedBox(height: 20),
                      const Eyebrow('How many'),
                      const SizedBox(height: 10),
                      StepperCard(
                        value: _count,
                        min: 1,
                        max: 20,
                        prefix: '×',
                        suffix: '',
                        onChanged: (v) => setState(() => _count = v),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          '${_unit * _count}g altogether',
                          style: GoogleFonts.quicksand(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Eyebrow('Time of day'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 9,
                        runSpacing: 9,
                        children: [
                          for (final slot in ProteinSlot.values)
                            GestureDetector(
                              onTap: () => setState(() => _slot = slot),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: slot == _slot
                                      ? AppColors.primary
                                      : AppColors.chipBg,
                                  borderRadius: BorderRadius.circular(100),
                                  boxShadow: slot == _slot
                                      ? const [AppTheme.buttonShadow]
                                      : null,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      slot.icon,
                                      size: 18,
                                      color: slot == _slot
                                          ? AppColors.onPrimary
                                          : AppColors.chipText,
                                    ),
                                    const SizedBox(width: 7),
                                    Text(
                                      slot.label,
                                      style: GoogleFonts.quicksand(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: slot == _slot
                                            ? AppColors.onPrimary
                                            : AppColors.chipText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      // Never red — this is a correction, not a failure.
                      GestureDetector(
                        onTap: _remove,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            color: AppColors.chipBg,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.backspace,
                                size: 19,
                                color: AppColors.chipText,
                              ),
                              const SizedBox(width: 9),
                              Text(
                                'Take this off the list',
                                style: GoogleFonts.quicksand(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.chipText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BottomAction(
                label: 'Save changes',
                busy: _saving,
                onTap: _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
