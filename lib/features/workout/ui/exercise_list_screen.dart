import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/theme.dart';
import '../data/exercise.dart';
import '../data/workout_icons.dart';
import '../providers/workout_providers.dart';
import 'add_exercise_screen.dart';
import 'exercise_detail_screen.dart';

class ExerciseListScreen extends ConsumerStatefulWidget {
  const ExerciseListScreen({super.key});

  @override
  ConsumerState<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends ConsumerState<ExerciseListScreen> {
  String? _filterBodyPart;
  bool _showArchived = false;

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
                  Text(
                    'My Workouts',
                    style: GoogleFonts.baloo2(
                      fontSize: 31,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
            ),
            _FilterBar(
              selectedBodyPart: _filterBodyPart,
              showArchived: _showArchived,
              onBodyPartSelected: (bp) =>
                  setState(() => _filterBodyPart = bp),
              onArchivedToggled: (v) => setState(() => _showArchived = v),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: exercisesAsync.when(
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
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 100),
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
          _showArchived ? null : _AddFab(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
            style: TextButton.styleFrom(foregroundColor: AppColors.failText),
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
