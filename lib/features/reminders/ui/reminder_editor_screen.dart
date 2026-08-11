import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_snack.dart';
import '../data/reminder.dart';
import '../providers/reminder_providers.dart';

class ReminderEditorScreen extends ConsumerStatefulWidget {
  const ReminderEditorScreen({super.key, this.reminder});
  final Reminder? reminder;

  @override
  ConsumerState<ReminderEditorScreen> createState() =>
      _ReminderEditorScreenState();
}

class _ReminderEditorScreenState extends ConsumerState<ReminderEditorScreen> {
  late final _messageController =
      TextEditingController(text: widget.reminder?.message ?? '');
  late int _hour = widget.reminder?.hour ?? 18;
  late int _minute = widget.reminder?.minute ?? 0;
  late List<bool> _days =
      List.of(widget.reminder?.days ?? List.filled(7, false));
  bool _saving = false;

  bool get _editing => widget.reminder != null;
  bool get _hasDaySelected => _days.any((d) => d);

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Reminder get _draft => Reminder(
        id: widget.reminder?.id ?? '',
        message: _messageController.text,
        hour: _hour,
        minute: _minute,
        days: _days,
        enabled: widget.reminder?.enabled ?? true,
      );

  /// Unlike the Firestore-backed screens, this deliberately keeps its `await`:
  /// reminders are stored in shared_preferences and the repository also arms up
  /// to seven OS alarms per reminder. That work is local and quick, and the
  /// alarms should be scheduled before the editor closes.
  Future<void> _save() async {
    if (_saving || !_hasDaySelected) return;
    final messenger = ScaffoldMessenger.of(context);
    final wasEditing = _editing;
    setState(() => _saving = true);
    final repo = ref.read(reminderRepositoryProvider);
    try {
      if (_editing) {
        await repo.update(_draft.copyWith(id: widget.reminder!.id));
      } else {
        await repo.create(
          message: _messageController.text,
          hour: _hour,
          minute: _minute,
          days: _days,
        );
      }
      if (mounted) Navigator.of(context).pop();
      AppSnack.showOn(
        messenger,
        wasEditing ? 'Reminder updated' : 'Reminder set',
      );
    } catch (_) {
      AppSnack.errorOn(messenger, "Couldn't save that reminder.");
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final reminder = widget.reminder;
    if (reminder == null) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(reminderRepositoryProvider).delete(reminder.id);
      if (mounted) Navigator.of(context).pop();
      AppSnack.showOn(messenger, 'Reminder deleted');
    } catch (_) {
      AppSnack.errorOn(messenger, "Couldn't delete that reminder.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon:
                          const Icon(Icons.arrow_back, color: AppColors.text),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Spacer(),
                    if (_editing)
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: AppColors.failText),
                        onPressed: _delete,
                      ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(22, 6, 22, 130),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _editing ? 'Edit reminder' : 'New reminder',
                          style: GoogleFonts.baloo2(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _TimeCard(
                          hour: _hour,
                          minute: _minute,
                          onHourChanged: (h) => setState(() => _hour = h),
                          onMinuteChanged: (m) => setState(() => _minute = m),
                        ),
                        const SizedBox(height: 14),
                        _Label('MESSAGE'),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: const [AppTheme.cardShadow],
                          ),
                          child: TextField(
                            controller: _messageController,
                            style: GoogleFonts.baloo2(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: AppColors.text,
                            ),
                            decoration: InputDecoration(
                              hintText: 'e.g. Creatine time!',
                              hintStyle: GoogleFonts.baloo2(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: AppColors.muted,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 15),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          'This shows in the notification.',
                          style: GoogleFonts.quicksand(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _Label('REPEAT ON'),
                        const SizedBox(height: 10),
                        _DayToggleRow(
                          days: _days,
                          onToggle: (i) =>
                              setState(() => _days[i] = !_days[i]),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _ShortcutChip(
                              label: 'Every day',
                              onTap: () => setState(
                                  () => _days = List.filled(7, true)),
                            ),
                            const SizedBox(width: 9),
                            _ShortcutChip(
                              label: 'Weekdays',
                              onTap: () => setState(() => _days = [
                                    true,
                                    true,
                                    true,
                                    true,
                                    true,
                                    false,
                                    false,
                                  ]),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _hasDaySelected
                              ? 'Repeats ${_draft.repeatLabel.toLowerCase()} '
                                  'at ${_draft.timeLabel}.'
                              : 'Pick at least one day to repeat on.',
                          style: GoogleFonts.quicksand(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Bottom button overlay
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.bg.withValues(alpha: 0),
                      AppColors.bg,
                    ],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(22, 16, 22, 20),
                child: GestureDetector(
                  onTap: (_saving || !_hasDaySelected) ? null : _save,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: _hasDaySelected
                          ? AppColors.primary
                          : const Color(0xFFDFCFC3),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow:
                          _hasDaySelected ? const [AppTheme.buttonShadow] : null,
                    ),
                    child: Center(
                      child: _saving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  color: AppColors.onPrimary, strokeWidth: 2),
                            )
                          : Text(
                              _editing ? 'Save changes' : 'Create reminder',
                              style: GoogleFonts.baloo2(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: AppColors.onPrimary,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: GoogleFonts.quicksand(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppColors.muted,
          letterSpacing: 1.2,
        ),
      );
}

// ── Time card ────────────────────────────────────────────────────────────────

class _TimeCard extends StatelessWidget {
  const _TimeCard({
    required this.hour,
    required this.minute,
    required this.onHourChanged,
    required this.onMinuteChanged,
  });
  final int hour;
  final int minute;
  final ValueChanged<int> onHourChanged;
  final ValueChanged<int> onMinuteChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [AppTheme.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Label('TIME'),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _TimeColumn(value: hour, max: 24, onChanged: onHourChanged),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  ':',
                  style: GoogleFonts.baloo2(
                    fontSize: 44,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFD9C4B6),
                  ),
                ),
              ),
              _TimeColumn(value: minute, max: 60, onChanged: onMinuteChanged),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeColumn extends StatelessWidget {
  const _TimeColumn({
    required this.value,
    required this.max,
    required this.onChanged,
  });
  final int value;
  final int max;
  final ValueChanged<int> onChanged;

  Future<void> _typeValue(BuildContext context) async {
    final controller = TextEditingController(text: value.toString());
    // whenComplete fires however the dialog is dismissed — Set, Cancel, the
    // back gesture, or a tap outside — and passes the result through, so the
    // controller is always released exactly once.
    final entered = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: GoogleFonts.baloo2(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
          onSubmitted: (v) => Navigator.pop(ctx, int.tryParse(v)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.baloo2(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.muted,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, int.tryParse(controller.text)),
            child: Text(
              'Set',
              style: GoogleFonts.baloo2(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    ).whenComplete(controller.dispose);
    if (entered != null) onChanged(entered.clamp(0, max - 1));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Chevron(
          icon: Icons.keyboard_arrow_up,
          onTap: () => onChanged((value + 1) % max),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => _typeValue(context),
          child: Text(
            value.toString().padLeft(2, '0'),
            style: GoogleFonts.baloo2(
              fontSize: 50,
              fontWeight: FontWeight.w700,
              color: AppColors.text,
            ),
          ),
        ),
        const SizedBox(height: 6),
        _Chevron(
          icon: Icons.keyboard_arrow_down,
          onTap: () => onChanged((value - 1) % max),
        ),
      ],
    );
  }
}

class _Chevron extends StatelessWidget {
  const _Chevron({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.chipBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 22, color: AppColors.chipText),
      ),
    );
  }
}

// ── Day toggle row ───────────────────────────────────────────────────────────

class _DayToggleRow extends StatelessWidget {
  const _DayToggleRow({required this.days, required this.onToggle});
  final List<bool> days;
  final ValueChanged<int> onToggle;

  static const _labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < 7; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: () => onToggle(i),
              child: AspectRatio(
                aspectRatio: 1,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: days[i] ? AppColors.primary : AppColors.chipBg,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow:
                        days[i] ? const [AppTheme.buttonShadow] : null,
                  ),
                  child: Text(
                    _labels[i],
                    style: GoogleFonts.quicksand(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: days[i]
                          ? AppColors.onPrimary
                          : AppColors.chipText,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ShortcutChip extends StatelessWidget {
  const _ShortcutChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.chipBg,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: GoogleFonts.quicksand(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.chipText,
          ),
        ),
      ),
    );
  }
}
