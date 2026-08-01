import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/theme.dart';
import '../data/reminder.dart';
import '../providers/reminder_providers.dart';
import 'reminder_editor_screen.dart';

class RemindersListScreen extends ConsumerStatefulWidget {
  const RemindersListScreen({super.key});

  @override
  ConsumerState<RemindersListScreen> createState() =>
      _RemindersListScreenState();
}

class _RemindersListScreenState extends ConsumerState<RemindersListScreen> {
  bool _bannerDismissed = false;

  Future<void> _requestNotificationPermission() async {
    await ref.read(notificationServiceProvider).requestPermission();
    ref.invalidate(notificationPermissionProvider);
  }

  Future<void> _requestExactAlarmPermission() async {
    await ref.read(notificationServiceProvider).requestExactAlarmPermission();
    ref.invalidate(exactAlarmPermissionProvider);
  }

  @override
  Widget build(BuildContext context) {
    final remindersAsync = ref.watch(remindersProvider);
    final hasNotificationPermission =
        ref.watch(notificationPermissionProvider).asData?.value ?? true;
    final hasExactAlarmPermission =
        ref.watch(exactAlarmPermissionProvider).asData?.value ?? true;
    final showBanner =
        (!hasNotificationPermission || !hasExactAlarmPermission) &&
            !_bannerDismissed;

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "DON'T FORGET",
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.muted,
                      letterSpacing: 1.6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Reminders',
                    style: GoogleFonts.baloo2(
                      fontSize: 31,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: remindersAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (reminders) {
                  if (reminders.isEmpty && !showBanner) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(18, 8, 18, 100),
                      child: _EmptyState(
                        onCreate: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ReminderEditorScreen(),
                          ),
                        ),
                      ),
                    );
                  }
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 100),
                    children: [
                      if (showBanner)
                        _PermissionBanner(
                          title: hasNotificationPermission
                              ? 'Allow exact timing'
                              : 'Allow notifications',
                          body: hasNotificationPermission
                              ? 'Without this, Android may delay reminders '
                                  'by several minutes.'
                              : 'We need permission to nudge you at the '
                                  'right time.',
                          onAllow: hasNotificationPermission
                              ? _requestExactAlarmPermission
                              : _requestNotificationPermission,
                          onNotNow: () =>
                              setState(() => _bannerDismissed = true),
                        ),
                      if (reminders.isEmpty)
                        _EmptyState(
                          onCreate: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ReminderEditorScreen(),
                            ),
                          ),
                        )
                      else
                        for (final reminder in reminders)
                          _ReminderCard(reminder: reminder),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _AddFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

// ── Permission banner ───────────────────────────────────────────────────────

class _PermissionBanner extends StatelessWidget {
  const _PermissionBanner({
    required this.title,
    required this.body,
    required this.onAllow,
    required this.onNotNow,
  });
  final String title;
  final String body;
  final VoidCallback onAllow;
  final VoidCallback onNotNow;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 17),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.notifications_active,
              size: 26, color: Color(0xFFE07A54)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.baloo2(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: GoogleFonts.quicksand(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.chipText,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    GestureDetector(
                      onTap: onAllow,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 9),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          'Allow',
                          style: GoogleFonts.quicksand(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onNotNow,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 9),
                        child: Text(
                          'Not now',
                          style: GoogleFonts.quicksand(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.chipText,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reminder card ────────────────────────────────────────────────────────────

class _ReminderCard extends ConsumerWidget {
  const _ReminderCard({required this.reminder});
  final Reminder reminder;

  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = reminder.enabled;
    return Opacity(
      opacity: enabled ? 1 : 0.55,
      child: Container(
        margin: const EdgeInsets.only(bottom: 13),
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(26),
          boxShadow: const [AppTheme.cardShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            ReminderEditorScreen(reminder: reminder),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              reminder.timeLabel,
                              style: GoogleFonts.baloo2(
                                fontSize: 29,
                                fontWeight: FontWeight.w700,
                                height: 1,
                                color: enabled
                                    ? const Color(0xFFE07A54)
                                    : AppColors.muted,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              reminder.repeatLabel,
                              style: GoogleFonts.quicksand(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          reminder.message,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.baloo2(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _EnableSwitch(
                  value: enabled,
                  onChanged: (v) => ref
                      .read(reminderRepositoryProvider)
                      .setEnabled(reminder.id, v),
                ),
              ],
            ),
            const SizedBox(height: 13),
            Row(
              children: [
                for (var i = 0; i < 7; i++) ...[
                  if (i > 0) const SizedBox(width: 6),
                  Expanded(
                    child: _DayCell(
                      label: _dayLabels[i],
                      selected: reminder.days[i],
                      enabled: enabled,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell(
      {required this.label, required this.selected, required this.enabled});
  final String label;
  final bool selected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? (enabled ? AppColors.primarySoft : const Color(0xFFF3EAE2))
        : Colors.transparent;
    final fg = selected
        ? (enabled ? const Color(0xFFE07A54) : AppColors.muted)
        : const Color(0xFFD9C4B6);
    return Container(
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: GoogleFonts.quicksand(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: fg,
        ),
      ),
    );
  }
}

class _EnableSwitch extends StatelessWidget {
  const _EnableSwitch({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 54,
        height: 31,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: value ? AppColors.primary : AppColors.border,
          borderRadius: BorderRadius.circular(100),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 25,
            height: 25,
            decoration: const BoxDecoration(
              color: AppColors.onPrimary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── FAB ─────────────────────────────────────────────────────────────────────

class _AddFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const ReminderEditorScreen()),
      ),
      child: Container(
        width: 62,
        height: 62,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [AppTheme.buttonShadow],
        ),
        child: const Icon(Icons.add, color: AppColors.onPrimary, size: 31),
      ),
    );
  }
}

// ── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 38, 22, 30),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [AppTheme.cardShadow],
      ),
      child: Column(
        children: [
          const Icon(Icons.alarm_add, size: 46, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(
            'No reminders yet',
            style: GoogleFonts.baloo2(
              fontSize: 19,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Set a cozy nudge like "Creatine time!" and '
            "we'll tap you on the shoulder.",
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.muted,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 22),
          GestureDetector(
            onTap: onCreate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(100),
                boxShadow: const [AppTheme.buttonShadow],
              ),
              child: Text(
                'Create a reminder',
                style: GoogleFonts.baloo2(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
