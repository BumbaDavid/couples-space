import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_snack.dart';
import '../data/workout_date_utils.dart';
import '../data/workout_entry.dart';
import '../data/workout_icons.dart';
import '../providers/workout_providers.dart';
import 'add_entry_screen.dart';

class ExerciseDetailScreen extends ConsumerWidget {
  const ExerciseDetailScreen({
    super.key,
    required this.exerciseId,
    required this.tileIndex,
  });
  final String exerciseId;
  final int tileIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exerciseAsync = ref.watch(exerciseProvider(exerciseId));
    final entriesAsync = ref.watch(exerciseEntriesProvider(exerciseId));

    return exerciseAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (exercise) {
        if (exercise == null) {
          return const Scaffold(
              body: Center(child: Text('Exercise not found')));
        }
        final tile =
            AppColors.tilePalette[tileIndex % AppColors.tilePalette.length];
        final entries = entriesAsync.asData?.value ?? [];
        final days = ref.watch(daysProvider).asData?.value ?? [];
        final exerciseDays = days
            .where((d) => exercise.dayIds.contains(d.id))
            .toList();
        final isEndurance = WorkoutIcons.isEndurance(exercise.bodyPart);

        return Scaffold(
          body: SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 14, bottom: 8),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: AppColors.text),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                color: tile.background,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                WorkoutIcons.forBodyPart(exercise.bodyPart),
                                color: tile.iconColor,
                                size: 46,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              exercise.name,
                              style: GoogleFonts.baloo2(
                                fontSize: 27,
                                fontWeight: FontWeight.w600,
                                color: AppColors.text,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 7,
                              runSpacing: 7,
                              children: [
                                _InfoChip(label: exercise.bodyPart),
                                for (final d in exerciseDays)
                                  _InfoChip(
                                    icon: Icons.calendar_today,
                                    label: d.name,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      isEndurance
                          ? _EnduranceStatRow(entries: entries)
                          : _StrengthStatRow(entries: entries),
                      const SizedBox(height: 16),
                      if (entries.isNotEmpty)
                        isEndurance
                            ? _DurationChart(entries: entries)
                            : _VolumeChart(entries: entries),
                      _History(
                        entries: entries,
                        exerciseId: exerciseId,
                        exerciseName: exercise.name,
                        bodyPart: exercise.bodyPart,
                        isEndurance: isEndurance,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _AddEntryButton(
                    exerciseId: exerciseId,
                    exerciseName: exercise.name,
                    bodyPart: exercise.bodyPart,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Strength stat row ──────────────────────────────────────────────────────

class _StrengthStatRow extends StatelessWidget {
  const _StrengthStatRow({required this.entries});
  final List<WorkoutEntry> entries;

  @override
  Widget build(BuildContext context) {
    final sessions = entries.length;
    final allSets = entries.expand((e) => e.sets).toList();
    final bestReps = allSets.isEmpty
        ? 0
        : allSets.map((s) => s.reps).reduce((a, b) => a > b ? a : b);
    final totalSets = entries.fold<int>(0, (sum, e) => sum + e.sets.length);

    return Row(
      children: [
        _StatCard(value: '$sessions', label: 'SESSIONS'),
        const SizedBox(width: 10),
        _StatCard(value: '$bestReps', label: 'BEST REPS'),
        const SizedBox(width: 10),
        _StatCard(value: '$totalSets', label: 'TOTAL SETS'),
      ],
    );
  }
}

// ── Endurance stat row ─────────────────────────────────────────────────────

class _EnduranceStatRow extends StatelessWidget {
  const _EnduranceStatRow({required this.entries});
  final List<WorkoutEntry> entries;

  @override
  Widget build(BuildContext context) {
    final sessions = entries.length;
    final durations =
        entries.map((e) => e.durationMinutes ?? 0).where((d) => d > 0).toList();
    final bestTime = durations.isEmpty ? 0 : durations.reduce((a, b) => a > b ? a : b);
    final totalTime = durations.fold<int>(0, (s, d) => s + d);

    return Row(
      children: [
        _StatCard(value: '$sessions', label: 'SESSIONS'),
        const SizedBox(width: 10),
        _StatCard(
            value: bestTime == 0 ? '—' : formatDuration(bestTime),
            label: 'BEST TIME'),
        const SizedBox(width: 10),
        _StatCard(
            value: totalTime == 0 ? '—' : formatDuration(totalTime),
            label: 'TOTAL TIME'),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [AppTheme.cardShadow],
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.baloo2(
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text),
            ),
            Text(
              label,
              style: GoogleFonts.quicksand(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Volume chart (strength) ────────────────────────────────────────────────

class _VolumeChart extends StatelessWidget {
  const _VolumeChart({required this.entries});
  final List<WorkoutEntry> entries;

  @override
  Widget build(BuildContext context) {
    final volumes = entries.map((e) => e.volume).toList();
    final maxVol = volumes.reduce((a, b) => a > b ? a : b);

    return _ChartCard(
      title: 'Volume per session',
      entries: entries,
      barHeight: (entry) {
        final frac = maxVol > 0 ? entry.volume / maxVol : 0.0;
        return (frac * 100).clamp(6.0, 100.0);
      },
    );
  }
}

// ── Duration chart (endurance) ─────────────────────────────────────────────

class _DurationChart extends StatelessWidget {
  const _DurationChart({required this.entries});
  final List<WorkoutEntry> entries;

  @override
  Widget build(BuildContext context) {
    final durations = entries.map((e) => e.durationMinutes ?? 0).toList();
    final maxDur =
        durations.reduce((a, b) => a > b ? a : b).toDouble();

    return _ChartCard(
      title: 'Duration per session',
      entries: entries,
      barHeight: (entry) {
        final frac = maxDur > 0 ? (entry.durationMinutes ?? 0) / maxDur : 0.0;
        return (frac * 100).clamp(6.0, 100.0);
      },
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.entries,
    required this.barHeight,
  });
  final String title;
  final List<WorkoutEntry> entries;
  final double Function(WorkoutEntry) barHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [AppTheme.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.baloo2(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.text),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: entries.map((entry) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: barHeight(entry),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                              bottomLeft: Radius.circular(5),
                              bottomRight: Radius.circular(5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatEntryDate(entry.date),
                          style: GoogleFonts.quicksand(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.muted),
                          maxLines: 1,
                          overflow: TextOverflow.visible,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── History ────────────────────────────────────────────────────────────────

class _History extends ConsumerWidget {
  const _History({
    required this.entries,
    required this.exerciseId,
    required this.exerciseName,
    required this.bodyPart,
    required this.isEndurance,
  });
  final List<WorkoutEntry> entries;
  final String exerciseId;
  final String exerciseName;
  final String bodyPart;
  final bool isEndurance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 22, 4, 12),
          child: Text(
            'History',
            style: GoogleFonts.baloo2(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.text),
          ),
        ),
        if (entries.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.note_add, color: AppColors.muted, size: 38),
                  const SizedBox(height: 8),
                  Text(
                    isEndurance
                        ? 'No sessions yet — log your first!'
                        : 'No entries yet — log your first set!',
                    style: GoogleFonts.quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.muted),
                  ),
                ],
              ),
            ),
          )
        else
          ...entries.map((entry) => isEndurance
              ? _EnduranceEntryRow(
                  entry: entry,
                  exerciseId: exerciseId,
                  exerciseName: exerciseName,
                  bodyPart: bodyPart,
                )
              : _StrengthEntryRow(
                  entry: entry,
                  exerciseId: exerciseId,
                  exerciseName: exerciseName,
                  bodyPart: bodyPart,
                )),
      ],
    );
  }
}

// ── Strength entry row ─────────────────────────────────────────────────────

class _StrengthEntryRow extends ConsumerWidget {
  const _StrengthEntryRow({
    required this.entry,
    required this.exerciseId,
    required this.exerciseName,
    required this.bodyPart,
  });
  final WorkoutEntry entry;
  final String exerciseId;
  final String exerciseName;
  final String bodyPart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasFailure = entry.sets.any((s) => s.failure);
    final label = formatEntryDate(entry.date);
    final setsCount = entry.sets.length;
    final totalReps = entry.totalReps;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Dismissible(
        key: Key(entry.id),
        direction: DismissDirection.endToStart,
        background: _deleteBackground(),
        confirmDismiss: (_) => _confirmDelete(context),
        onDismissed: (_) {
          final messenger = ScaffoldMessenger.of(context);
          ref
              .read(workoutRepositoryProvider)
              .deleteEntry(exerciseId, entry.id)
              .then((_) => AppSnack.showOn(messenger, 'Entry deleted'))
              .catchError(
                (_) => AppSnack.errorOn(messenger, "Couldn't delete that."),
              );
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => AddEntryScreen(
                exerciseId: exerciseId,
                exerciseName: exerciseName,
                bodyPart: bodyPart,
                existing: entry,
              ),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [AppTheme.cardShadow],
            ),
            child: Row(
              children: [
                _DateTile(label: label),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$setsCount set${setsCount == 1 ? '' : 's'} · $totalReps total reps',
                        style: GoogleFonts.baloo2(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text),
                      ),
                      Text(
                        entry.sets.map((s) {
                          final w =
                              s.weight != null ? ' × ${s.weight}kg' : '';
                          return '${s.reps}$w';
                        }).join(', '),
                        style: GoogleFonts.quicksand(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.muted),
                        // Wraps to three lines so a typical session is fully
                        // readable here; tapping through shows every set.
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (hasFailure) ...[
                  const SizedBox(width: 8),
                  _FailureBadge(),
                ],
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right,
                    size: 20, color: AppColors.muted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Endurance entry row ────────────────────────────────────────────────────

class _EnduranceEntryRow extends ConsumerWidget {
  const _EnduranceEntryRow({
    required this.entry,
    required this.exerciseId,
    required this.exerciseName,
    required this.bodyPart,
  });
  final WorkoutEntry entry;
  final String exerciseId;
  final String exerciseName;
  final String bodyPart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final label = formatEntryDate(entry.date);
    final duration = entry.durationMinutes ?? 0;

    final details = [
      if (entry.distanceKm != null) '${entry.distanceKm}km',
      if (entry.speed != null) '${entry.speed}km/h',
      if (entry.resistance != null) 'R${entry.resistance}',
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Dismissible(
        key: Key(entry.id),
        direction: DismissDirection.endToStart,
        background: _deleteBackground(),
        confirmDismiss: (_) => _confirmDelete(context),
        onDismissed: (_) {
          final messenger = ScaffoldMessenger.of(context);
          ref
              .read(workoutRepositoryProvider)
              .deleteEntry(exerciseId, entry.id)
              .then((_) => AppSnack.showOn(messenger, 'Entry deleted'))
              .catchError(
                (_) => AppSnack.errorOn(messenger, "Couldn't delete that."),
              );
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => AddEntryScreen(
                exerciseId: exerciseId,
                exerciseName: exerciseName,
                bodyPart: bodyPart,
                existing: entry,
              ),
            ),
          ),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [AppTheme.cardShadow],
            ),
            child: Row(
              children: [
                _DateTile(label: label),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatDuration(duration),
                        style: GoogleFonts.baloo2(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text),
                      ),
                      if (details.isNotEmpty)
                        Text(
                          details,
                          style: GoogleFonts.quicksand(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.muted),
                        ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right,
                    size: 20, color: AppColors.muted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Shared row helpers ─────────────────────────────────────────────────────

class _DateTile extends StatelessWidget {
  const _DateTile({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.chipBg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.baloo2(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.text),
        ),
      ),
    );
  }
}

class _FailureBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.failBg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_fire_department,
              size: 14, color: AppColors.failText),
          const SizedBox(width: 3),
          Text(
            'Failure',
            style: GoogleFonts.quicksand(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.failText),
          ),
        ],
      ),
    );
  }
}

Widget _deleteBackground() => Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: AppColors.failText,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Icon(Icons.delete, color: Colors.white),
    );

Future<bool?> _confirmDelete(BuildContext context) => showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete entry?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete')),
        ],
      ),
    );

// ── Info chip ──────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, this.icon});
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.chipBg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: AppColors.chipText),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: GoogleFonts.quicksand(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.chipText,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Add entry button ───────────────────────────────────────────────────────

class _AddEntryButton extends StatelessWidget {
  const _AddEntryButton({
    required this.exerciseId,
    required this.exerciseName,
    required this.bodyPart,
  });
  final String exerciseId;
  final String exerciseName;
  final String bodyPart;

  @override
  Widget build(BuildContext context) {
    final isEndurance = WorkoutIcons.isEndurance(bodyPart);
    return Container(
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => AddEntryScreen(
            exerciseId: exerciseId,
            exerciseName: exerciseName,
            bodyPart: bodyPart,
          ),
        )),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [AppTheme.buttonShadow],
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isEndurance ? Icons.timer : Icons.add,
                  color: AppColors.onPrimary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  isEndurance ? 'Log session' : 'Add entry',
                  style: GoogleFonts.baloo2(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
