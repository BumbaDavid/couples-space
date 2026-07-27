import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/theme.dart';
import '../data/workout_icons.dart';
import '../providers/workout_providers.dart';

class AddExerciseScreen extends ConsumerStatefulWidget {
  const AddExerciseScreen({super.key, this.dayId});
  final String? dayId;

  @override
  ConsumerState<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends ConsumerState<AddExerciseScreen> {
  final _nameController = TextEditingController();
  String _bodyPart = WorkoutIcons.bodyParts.first;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (_saving) return;
    setState(() => _saving = true);
    final name = _nameController.text.trim().isEmpty
        ? 'New Exercise'
        : _nameController.text.trim();
    try {
      await ref
          .read(workoutRepositoryProvider)
          .createExercise(name: name, bodyPart: _bodyPart, dayId: widget.dayId);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tileIdx = WorkoutIcons.bodyParts.indexOf(_bodyPart);
    final tile =
        AppColors.tilePalette[tileIdx % AppColors.tilePalette.length];

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
                    padding: const EdgeInsets.fromLTRB(22, 6, 22, 130),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'New exercise',
                          style: GoogleFonts.baloo2(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: Container(
                            width: 92,
                            height: 92,
                            decoration: BoxDecoration(
                              color: tile.background,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              WorkoutIcons.forBodyPart(_bodyPart),
                              color: tile.iconColor,
                              size: 48,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'NAME',
                          style: GoogleFonts.quicksand(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.muted,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: const [AppTheme.cardShadow],
                          ),
                          child: TextField(
                            controller: _nameController,
                            style: GoogleFonts.baloo2(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: AppColors.text,
                            ),
                            decoration: InputDecoration(
                              hintText: 'e.g. Lunges',
                              hintStyle: GoogleFonts.baloo2(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: AppColors.muted,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 15),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'BODY PART',
                          style: GoogleFonts.quicksand(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.muted,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 9,
                          runSpacing: 9,
                          children: WorkoutIcons.bodyParts.map((bp) {
                            final selected = bp == _bodyPart;
                            return GestureDetector(
                              onTap: () => setState(() => _bodyPart = bp),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.chipBg,
                                  borderRadius: BorderRadius.circular(100),
                                  boxShadow: selected
                                      ? const [AppTheme.buttonShadow]
                                      : null,
                                ),
                                child: Text(
                                  bp,
                                  style: GoogleFonts.quicksand(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: selected
                                        ? AppColors.onPrimary
                                        : AppColors.chipText,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
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
                  onTap: _saving ? null : _create,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [AppTheme.buttonShadow],
                    ),
                    child: Center(
                      child: _saving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  color: AppColors.onPrimary, strokeWidth: 2),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.add,
                                    color: AppColors.onPrimary, size: 22),
                                const SizedBox(width: 8),
                                Text(
                                  'Create exercise',
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
