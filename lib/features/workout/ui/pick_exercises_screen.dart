import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/theme.dart';
import '../data/exercise.dart';
import '../data/workout_day.dart';
import '../data/workout_icons.dart';
import '../providers/workout_providers.dart';
import 'add_exercise_screen.dart';

class PickExercisesScreen extends ConsumerWidget {
  const PickExercisesScreen({
    super.key,
    required this.dayId,
    required this.dayName,
  });
  final String dayId;
  final String dayName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final exercisesAsync = ref.watch(exercisesProvider(false));
    final days = ref.watch(daysProvider).asData?.value ?? [];

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
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 130),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dayName.toUpperCase(),
                          style: GoogleFonts.quicksand(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.muted,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Add exercises',
                          style: GoogleFonts.baloo2(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 20),
                        exercisesAsync.when(
                          loading: () => const Center(
                              child: CircularProgressIndicator()),
                          error: (e, _) =>
                              Center(child: Text('Error: $e')),
                          data: (exercises) => Column(
                            children: [
                              ...exercises.asMap().entries.map(
                                    (e) => _PickRow(
                                      exercise: e.value,
                                      tileIndex: e.key,
                                      dayId: dayId,
                                      days: days.where((d) => d.id != dayId).toList(),
                                      onToggle: () {
                                        final inDay = e.value.dayIds
                                            .contains(dayId);
                                        ref
                                            .read(workoutRepositoryProvider)
                                            .toggleExerciseInDay(
                                              e.value.id,
                                              dayId,
                                              add: !inDay,
                                            );
                                      },
                                    ),
                                  ),
                              const SizedBox(height: 10),
                              _CreateExerciseDashedButton(
                                onTap: () => Navigator.of(context)
                                    .push(MaterialPageRoute(
                                  builder: (_) =>
                                      AddExerciseScreen(dayId: dayId),
                                )),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [AppTheme.buttonShadow],
                    ),
                    child: Center(
                      child: Text(
                        'Done',
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

// ── Pick row ───────────────────────────────────────────────────────────────

class _PickRow extends StatelessWidget {
  const _PickRow({
    required this.exercise,
    required this.tileIndex,
    required this.dayId,
    required this.days,
    required this.onToggle,
  });
  final Exercise exercise;
  final int tileIndex;
  final String dayId;
  final List<WorkoutDay> days;
  final VoidCallback onToggle;

  String get _noteText {
    final inThis = exercise.dayIds.contains(dayId);
    final otherIds = exercise.dayIds.where((id) => id != dayId).toList();
    if (inThis && otherIds.isEmpty) return 'In this day';
    if (inThis) return 'In this day + ${otherIds.length} more';
    if (otherIds.length == 1) {
      final other = days.where((d) => d.id == otherIds.first).firstOrNull;
      if (other != null) return 'In ${other.name}';
    }
    if (otherIds.isNotEmpty) return 'In ${otherIds.length} other day(s)';
    return exercise.bodyPart;
  }

  bool get _selected => exercise.dayIds.contains(dayId);

  @override
  Widget build(BuildContext context) {
    final tile =
        AppColors.tilePalette[tileIndex % AppColors.tilePalette.length];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onToggle,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [AppTheme.cardShadow],
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
                  WorkoutIcons.forBodyPart(exercise.bodyPart),
                  color: tile.iconColor,
                  size: 24,
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
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text,
                      ),
                    ),
                    Text(
                      _noteText,
                      style: GoogleFonts.quicksand(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _selected ? AppColors.primary : Colors.transparent,
                  border: Border.all(
                    color: _selected ? AppColors.primary : AppColors.border,
                    width: 2,
                  ),
                ),
                child: _selected
                    ? const Icon(Icons.check,
                        size: 17, color: AppColors.onPrimary)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Create exercise dashed button ───────────────────────────────────────────

class _CreateExerciseDashedButton extends StatelessWidget {
  const _CreateExerciseDashedButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border, width: 1.5),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, size: 20, color: AppColors.muted),
            const SizedBox(width: 6),
            Text(
              'Create a new exercise',
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
