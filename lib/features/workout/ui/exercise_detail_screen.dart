import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/theme.dart';
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
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.chipBg,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Text(
                                exercise.bodyPart,
                                style: GoogleFonts.quicksand(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.chipText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      _StatRow(entries: entries),
                      const SizedBox(height: 16),
                      if (entries.isNotEmpty) _VolumeChart(entries: entries),
                      _History(
                        entries: entries,
                        exerciseId: exerciseId,
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

// ── Stat row ───────────────────────────────────────────────────────────────

class _StatRow extends StatelessWidget {
  const _StatRow({required this.entries});
  final List<WorkoutEntry> entries;

  @override
  Widget build(BuildContext context) {
    final sessions = entries.length;
    final allSets = entries.expand((e) => e.sets).toList();
    final bestReps =
        allSets.isEmpty ? 0 : allSets.map((s) => s.reps).reduce((a, b) => a > b ? a : b);
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

// ── Volume chart ───────────────────────────────────────────────────────────

class _VolumeChart extends StatelessWidget {
  const _VolumeChart({required this.entries});
  final List<WorkoutEntry> entries;

  @override
  Widget build(BuildContext context) {
    final volumes = entries.map((e) => e.volume).toList();
    final maxVol = volumes.reduce((a, b) => a > b ? a : b);

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
            'Volume per session',
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
              children: entries.asMap().entries.map((e) {
                final vol = e.value.volume;
                final frac = maxVol > 0 ? vol / maxVol : 0.0;
                final barH = (frac * 100).clamp(6.0, 100.0);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: barH,
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
                          formatEntryDate(e.value.date),
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
  const _History({required this.entries, required this.exerciseId});
  final List<WorkoutEntry> entries;
  final String exerciseId;

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
                    'No entries yet — log your first set!',
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
          ...entries.map((entry) => _EntryRow(
                entry: entry,
                exerciseId: exerciseId,
              )),
      ],
    );
  }
}

class _EntryRow extends ConsumerWidget {
  const _EntryRow({required this.entry, required this.exerciseId});
  final WorkoutEntry entry;
  final String exerciseId;

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
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: AppColors.failText,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        confirmDismiss: (_) => showDialog<bool>(
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
        ),
        onDismissed: (_) => ref
            .read(workoutRepositoryProvider)
            .deleteEntry(exerciseId, entry.id),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [AppTheme.cardShadow],
          ),
          child: Row(
            children: [
              Container(
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
              ),
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
                        final w = s.weight != null ? ' × ${s.weight}kg' : '';
                        return '${s.reps}$w';
                      }).join(', '),
                      style: GoogleFonts.quicksand(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.muted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (hasFailure) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
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
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Add entry button ───────────────────────────────────────────────────────

class _AddEntryButton extends StatelessWidget {
  const _AddEntryButton({
    required this.exerciseId,
    required this.exerciseName,
  });
  final String exerciseId;
  final String exerciseName;

  @override
  Widget build(BuildContext context) {
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
                const Icon(Icons.add, color: AppColors.onPrimary, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Add entry',
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
