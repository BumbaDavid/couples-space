import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/theme.dart';
import '../data/exercise.dart';
import '../data/workout_day.dart';
import '../data/workout_icons.dart';
import '../providers/workout_providers.dart';
import 'add_exercise_screen.dart';
import 'exercise_detail_screen.dart';
import 'pick_exercises_screen.dart';

class ExerciseListScreen extends ConsumerStatefulWidget {
  const ExerciseListScreen({super.key});

  @override
  ConsumerState<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends ConsumerState<ExerciseListScreen> {
  String? _filterBodyPart;
  bool _showArchived = false;
  bool _grouped = false;

  @override
  Widget build(BuildContext context) {
    final exercisesAsync = ref.watch(exercisesProvider(_showArchived));

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
                    "LET'S MOVE",
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.muted,
                      letterSpacing: 1.6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'My Workouts',
                        style: GoogleFonts.baloo2(
                          fontSize: 31,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                      const Spacer(),
                      _GroupToggleButton(
                        grouped: _grouped,
                        onTap: () => setState(() => _grouped = !_grouped),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (!_grouped) ...[
              _FilterBar(
                selectedBodyPart: _filterBodyPart,
                showArchived: _showArchived,
                onBodyPartSelected: (bp) =>
                    setState(() => _filterBodyPart = bp),
                onArchivedToggled: (v) => setState(() => _showArchived = v),
              ),
              const SizedBox(height: 4),
            ],
            Expanded(
              child: _grouped
                  ? _GroupedBody(
                      exercisesAsync: exercisesAsync,
                      onPickExercises:
                          (dayId, dayName) =>
                              Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => PickExercisesScreen(
                          dayId: dayId,
                          dayName: dayName,
                        ),
                      )),
                    )
                  : exercisesAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('Error: $e')),
                      data: (all) {
                        final exercises = _filterBodyPart == null
                            ? all
                            : all
                                .where((e) => e.bodyPart == _filterBodyPart)
                                .toList();
                        if (exercises.isEmpty) {
                          return _EmptyState(showArchived: _showArchived);
                        }
                        return ListView.builder(
                          padding:
                              const EdgeInsets.fromLTRB(18, 8, 18, 100),
                          itemCount: exercises.length,
                          itemBuilder: (context, i) => _ExerciseRow(
                            exercise: exercises[i],
                            tileIndex: i,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          (_grouped || _showArchived) ? null : _AddFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

// ── Group toggle button ────────────────────────────────────────────────────

class _GroupToggleButton extends StatelessWidget {
  const _GroupToggleButton({required this.grouped, required this.onTap});
  final bool grouped;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: grouped ? AppColors.primary : AppColors.chipBg,
          borderRadius: BorderRadius.circular(100),
          boxShadow: grouped ? const [AppTheme.buttonShadow] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              grouped ? Icons.view_agenda : Icons.calendar_view_week,
              size: 18,
              color: grouped ? AppColors.onPrimary : AppColors.chipText,
            ),
            const SizedBox(width: 7),
            Text(
              grouped ? 'All' : 'By day',
              style: GoogleFonts.quicksand(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: grouped ? AppColors.onPrimary : AppColors.chipText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Grouped body ───────────────────────────────────────────────────────────

class _GroupedBody extends ConsumerWidget {
  const _GroupedBody({
    required this.exercisesAsync,
    required this.onPickExercises,
  });
  final AsyncValue<List<Exercise>> exercisesAsync;
  final void Function(String dayId, String dayName) onPickExercises;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daysAsync = ref.watch(daysProvider);
    final days = daysAsync.asData?.value ?? [];
    final exercises = exercisesAsync.asData?.value ?? [];

    if (days.isEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 100),
        child: Column(
          children: [
            _GroupedEmptyState(
              onNewDay: () =>
                  ref.read(workoutRepositoryProvider).createDay(),
            ),
          ],
        ),
      );
    }

    // Compute tile index offsets so colors stay distinct across sections
    final dayExercises = <String, List<Exercise>>{};
    for (final day in days) {
      dayExercises[day.id] =
          exercises.where((e) => e.dayIds.contains(day.id)).toList();
    }

    var tileOffset = 0;
    final sectionOffsets = <String, int>{};
    for (final day in days) {
      sectionOffsets[day.id] = tileOffset;
      tileOffset += dayExercises[day.id]!.length;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final day in days)
            _DaySection(
              day: day,
              exercises: dayExercises[day.id]!,
              globalTileOffset: sectionOffsets[day.id]!,
              onPickExercises: onPickExercises,
            ),
          _NewDayButton(
            onTap: () => ref.read(workoutRepositoryProvider).createDay(),
          ),
        ],
      ),
    );
  }
}

// ── Grouped empty state ────────────────────────────────────────────────────

class _GroupedEmptyState extends StatelessWidget {
  const _GroupedEmptyState({required this.onNewDay});
  final VoidCallback onNewDay;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 34, 18, 26),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [AppTheme.cardShadow],
      ),
      child: Column(
        children: [
          const Icon(Icons.calendar_month,
              size: 44, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(
            'No days yet',
            style: GoogleFonts.baloo2(
              fontSize: 19,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a day like "Day 1 · Push",\nthen fill it with exercises.',
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.muted,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 22),
          _NewDayButton(onTap: onNewDay),
        ],
      ),
    );
  }
}

// ── Day section ────────────────────────────────────────────────────────────

class _DaySection extends ConsumerWidget {
  const _DaySection({
    required this.day,
    required this.exercises,
    required this.globalTileOffset,
    required this.onPickExercises,
  });
  final WorkoutDay day;
  final List<Exercise> exercises;
  final int globalTileOffset;
  final void Function(String dayId, String dayName) onPickExercises;

  void _showRename(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: day.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Rename day',
          style: GoogleFonts.baloo2(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: GoogleFonts.baloo2(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
          decoration: InputDecoration(
            hintText: day.name,
            hintStyle: GoogleFonts.baloo2(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.muted,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          onSubmitted: (_) async {
            final name = controller.text.trim();
            if (name.isNotEmpty) {
              await ref.read(workoutRepositoryProvider).renameDay(day.id, name);
            }
            if (ctx.mounted) Navigator.pop(ctx);
          },
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
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                await ref
                    .read(workoutRepositoryProvider)
                    .renameDay(day.id, name);
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: Text(
              'Rename',
              style: GoogleFonts.baloo2(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Delete ${day.name}?',
          style: GoogleFonts.baloo2(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        content: Text(
          'Exercises will not be deleted — they\'ll just become unassigned.',
          style: GoogleFonts.quicksand(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.muted,
          ),
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
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(workoutRepositoryProvider)
                  .deleteDay(day.id);
            },
            style:
                TextButton.styleFrom(foregroundColor: AppColors.failText),
            child: Text(
              'Delete',
              style: GoogleFonts.baloo2(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.failText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final n = exercises.length;
    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 0, 2, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.chipBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '${day.order + 1}',
                      style: GoogleFonts.baloo2(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.chipText,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        day.name,
                        style: GoogleFonts.baloo2(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                      Text(
                        '$n exercise${n == 1 ? '' : 's'}',
                        style: GoogleFonts.quicksand(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _showRename(context, ref),
                  child: Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    child: const Icon(Icons.edit_outlined,
                        size: 20, color: AppColors.muted),
                  ),
                ),
                const SizedBox(width: 2),
                GestureDetector(
                  onTap: () => _confirmDelete(context, ref),
                  child: Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    child: const Icon(Icons.delete_outline,
                        size: 20, color: AppColors.muted),
                  ),
                ),
              ],
            ),
          ),
          // Exercise rows
          for (var i = 0; i < exercises.length; i++)
            _ExerciseRow(
              exercise: exercises[i],
              tileIndex: globalTileOffset + i,
            ),
          // Add exercises button
          _AddExercisesButton(
            onTap: () => onPickExercises(day.id, day.name),
          ),
        ],
      ),
    );
  }
}

// ── Add exercises button (dashed-style) ────────────────────────────────────

class _AddExercisesButton extends StatelessWidget {
  const _AddExercisesButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border, width: 2),
          borderRadius: BorderRadius.circular(26),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, size: 20, color: AppColors.muted),
            const SizedBox(width: 6),
            Text(
              'Add exercises',
              style: GoogleFonts.quicksand(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── New day button ─────────────────────────────────────────────────────────

class _NewDayButton extends StatelessWidget {
  const _NewDayButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(26),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.calendar_month,
                size: 21, color: AppColors.chipText),
            const SizedBox(width: 8),
            Text(
              'New day',
              style: GoogleFonts.baloo2(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.chipText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Filter bar ─────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.selectedBodyPart,
    required this.showArchived,
    required this.onBodyPartSelected,
    required this.onArchivedToggled,
  });
  final String? selectedBodyPart;
  final bool showArchived;
  final ValueChanged<String?> onBodyPartSelected;
  final ValueChanged<bool> onArchivedToggled;

  @override
  Widget build(BuildContext context) {
    final chips = <String?>[null, ...WorkoutIcons.bodyParts];
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        itemCount: chips.length + 1,
        separatorBuilder: (_, i) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          if (i == chips.length) {
            return _Chip(
              label: 'Archived',
              selected: showArchived,
              onTap: () => onArchivedToggled(!showArchived),
            );
          }
          final bp = chips[i];
          return _Chip(
            label: bp ?? 'All',
            selected: selectedBodyPart == bp,
            onTap: () => onBodyPartSelected(bp),
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.chipBg,
          borderRadius: BorderRadius.circular(100),
          boxShadow: selected ? const [AppTheme.buttonShadow] : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.quicksand(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.onPrimary : AppColors.chipText,
          ),
        ),
      ),
    );
  }
}

// ── Exercise row ───────────────────────────────────────────────────────────

class _ExerciseRow extends ConsumerWidget {
  const _ExerciseRow({required this.exercise, required this.tileIndex});
  final Exercise exercise;
  final int tileIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tile =
        AppColors.tilePalette[tileIndex % AppColors.tilePalette.length];
    final entries =
        ref.watch(exerciseEntriesProvider(exercise.id)).asData?.value ?? [];

    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => ExerciseDetailScreen(
          exerciseId: exercise.id,
          tileIndex: tileIndex,
        ),
      )),
      onLongPress: () => _showOptions(context, ref),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(26),
          boxShadow: const [AppTheme.cardShadow],
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: tile.background,
                shape: BoxShape.circle,
              ),
              child: Icon(
                WorkoutIcons.forBodyPart(exercise.bodyPart),
                color: tile.iconColor,
                size: 29,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: GoogleFonts.baloo2(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  Text(
                    '${exercise.bodyPart} · ${entries.length} session${entries.length == 1 ? '' : 's'}',
                    style: GoogleFonts.quicksand(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.muted, size: 24),
          ],
        ),
      ),
    ),
    );
  }

  void _showOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: Icon(
                exercise.isArchived
                    ? Icons.unarchive_outlined
                    : Icons.archive_outlined,
                color: AppColors.text,
              ),
              title: Text(
                exercise.isArchived ? 'Unarchive' : 'Archive',
                style: GoogleFonts.baloo2(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              onTap: () async {
                Navigator.pop(ctx);
                if (exercise.isArchived) {
                  await ref
                      .read(workoutRepositoryProvider)
                      .unarchiveExercise(exercise.id);
                } else {
                  await ref
                      .read(workoutRepositoryProvider)
                      .archiveExercise(exercise.id);
                }
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.delete_outline, color: AppColors.failText),
              title: Text(
                'Delete',
                style: GoogleFonts.baloo2(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.failText,
                ),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _confirmDelete(context, ref);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Delete exercise?',
          style: GoogleFonts.baloo2(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        content: Text(
          'This will permanently delete "${exercise.name}" and all its entries.',
          style: GoogleFonts.quicksand(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.muted,
          ),
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
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(workoutRepositoryProvider)
                  .deleteExercise(exercise.id);
            },
            style:
                TextButton.styleFrom(foregroundColor: AppColors.failText),
            child: Text(
              'Delete',
              style: GoogleFonts.baloo2(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.failText,
              ),
            ),
          ),
        ],
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
        MaterialPageRoute(builder: (_) => const AddExerciseScreen()),
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

// ── Empty state ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.showArchived});
  final bool showArchived;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.note_add, color: AppColors.muted, size: 38),
          const SizedBox(height: 12),
          Text(
            showArchived
                ? 'No archived exercises'
                : 'No exercises yet — add your first!',
            style: GoogleFonts.quicksand(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}
