import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/theme.dart';
import '../data/workout_entry.dart';
import '../data/workout_icons.dart';
import '../data/workout_set.dart';
import '../providers/workout_providers.dart';

class AddEntryScreen extends ConsumerStatefulWidget {
  const AddEntryScreen({
    super.key,
    required this.exerciseId,
    required this.exerciseName,
    required this.bodyPart,
  });
  final String exerciseId;
  final String exerciseName;
  final String bodyPart;

  @override
  ConsumerState<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends ConsumerState<AddEntryScreen> {
  // strength
  int _reps = 10;
  final _weightController = TextEditingController();
  final List<WorkoutSet> _sets = [];

  // endurance
  int _durationMinutes = 20;
  final _distanceController = TextEditingController();
  final _speedController = TextEditingController();
  final _resistanceController = TextEditingController();

  // strength
  bool _failure = false;

  bool _saving = false;

  bool get _isEndurance => WorkoutIcons.isEndurance(widget.bodyPart);

  @override
  void dispose() {
    _weightController.dispose();
    _distanceController.dispose();
    _speedController.dispose();
    _resistanceController.dispose();
    super.dispose();
  }

  void _addSet() {
    final weight = _weightController.text.trim().isEmpty
        ? null
        : double.tryParse(_weightController.text.trim());
    setState(() {
      _sets.add(WorkoutSet(reps: _reps, weight: weight, failure: _failure));
      _reps = 10;
      _weightController.clear();
      _failure = false;
    });
  }

  Future<void> _saveStrength() async {
    if (_saving || _sets.isEmpty) return;
    setState(() => _saving = true);
    try {
      await ref.read(workoutRepositoryProvider).createEntry(
            exerciseId: widget.exerciseId,
            sets: _sets,
          );
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveEndurance() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      double? parseDouble(String t) =>
          t.trim().isEmpty ? null : double.tryParse(t.trim());
      int? parseInt(String t) =>
          t.trim().isEmpty ? null : int.tryParse(t.trim());
      await ref.read(workoutRepositoryProvider).createEntry(
            exerciseId: widget.exerciseId,
            durationMinutes: _durationMinutes,
            distanceKm: parseDouble(_distanceController.text),
            speed: parseDouble(_speedController.text),
            resistance: parseInt(_resistanceController.text),
          );
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
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
                          widget.exerciseName.toUpperCase(),
                          style: GoogleFonts.quicksand(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.muted,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isEndurance ? 'Log a session' : 'Log a set',
                          style: GoogleFonts.baloo2(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (_isEndurance)
                          _buildEnduranceForm()
                        else
                          _buildStrengthForm(),
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
              child: _buildSaveButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStrengthForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_sets.isNotEmpty) ...[
          Text(
            'Sets logged',
            style: GoogleFonts.baloo2(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 8),
          ..._sets.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _SetChip(index: e.key, set: e.value),
              )),
          const SizedBox(height: 16),
        ],
        _StepperCard(
          label: 'REPS',
          value: _reps,
          onDecrement: _reps > 1 ? () => setState(() => _reps--) : null,
          onIncrement: () => setState(() => _reps++),
        ),
        const SizedBox(height: 14),
        _WeightCard(controller: _weightController),
        const SizedBox(height: 14),
        _FailureCard(
          subtitle: 'Last set with nothing left',
          value: _failure,
          onChanged: (v) => setState(() => _failure = v),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: _addSet,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.chipBg,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Text(
                'Add set',
                style: GoogleFonts.baloo2(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.chipText,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnduranceForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepperCard(
          label: 'DURATION (MINUTES)',
          value: _durationMinutes,
          onDecrement:
              _durationMinutes > 1 ? () => setState(() => _durationMinutes--) : null,
          onIncrement: () => setState(() => _durationMinutes++),
        ),
        const SizedBox(height: 14),
        _DistanceCard(controller: _distanceController),
        const SizedBox(height: 14),
        _SpeedCard(controller: _speedController),
        const SizedBox(height: 14),
        _ResistanceCard(controller: _resistanceController),
      ],
    );
  }

  Widget _buildSaveButton() {
    final ready = _isEndurance || _sets.isNotEmpty;
    final label = _isEndurance
        ? 'Save session (${formatDuration(_durationMinutes)})'
        : _sets.isEmpty
            ? 'Add at least one set'
            : 'Save entry (${_sets.length} set${_sets.length == 1 ? '' : 's'})';

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
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 20),
      child: GestureDetector(
        onTap: (!ready || _saving)
            ? null
            : (_isEndurance ? _saveEndurance : _saveStrength),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: ready ? AppColors.primary : AppColors.border,
            borderRadius: BorderRadius.circular(18),
            boxShadow: ready ? const [AppTheme.buttonShadow] : null,
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
                    label,
                    style: GoogleFonts.baloo2(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: ready ? AppColors.onPrimary : AppColors.muted,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ── Set chip ───────────────────────────────────────────────────────────────

class _SetChip extends StatelessWidget {
  const _SetChip({required this.index, required this.set});
  final int index;
  final WorkoutSet set;

  @override
  Widget build(BuildContext context) {
    final weightStr = set.weight != null ? ' × ${set.weight}kg' : '';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.chipBg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Text(
            'Set ${index + 1}',
            style: GoogleFonts.quicksand(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.muted),
          ),
          const SizedBox(width: 12),
          Text(
            '${set.reps} reps$weightStr',
            style: GoogleFonts.baloo2(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.text),
          ),
          if (set.failure) ...[
            const Spacer(),
            const Icon(Icons.local_fire_department,
                size: 16, color: AppColors.failText),
          ],
        ],
      ),
    );
  }
}

// ── Stepper card ───────────────────────────────────────────────────────────

class _StepperCard extends StatelessWidget {
  const _StepperCard({
    required this.label,
    required this.value,
    required this.onIncrement,
    this.onDecrement,
  });
  final String label;
  final int value;
  final VoidCallback? onDecrement;
  final VoidCallback onIncrement;

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
          Text(
            label,
            style: GoogleFonts.quicksand(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.muted,
                letterSpacing: 1.2),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StepperButton(
                  icon: Icons.remove, filled: false, onTap: onDecrement),
              Text(
                '$value',
                style: GoogleFonts.baloo2(
                    fontSize: 44,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text),
              ),
              _StepperButton(
                  icon: Icons.add, filled: true, onTap: onIncrement),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.filled,
    required this.onTap,
  });
  final IconData icon;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: onTap == null
              ? AppColors.border
              : filled
                  ? AppColors.primary
                  : AppColors.chipBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(
          icon,
          size: 26,
          color: onTap == null
              ? AppColors.muted
              : filled
                  ? AppColors.onPrimary
                  : AppColors.chipText,
        ),
      ),
    );
  }
}

// ── Weight card ────────────────────────────────────────────────────────────

class _WeightCard extends StatelessWidget {
  const _WeightCard({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return _NumericInputCard(
      label: 'WEIGHT (KG) — OPTIONAL',
      controller: controller,
      suffix: 'kg',
    );
  }
}

// ── Distance card ──────────────────────────────────────────────────────────

class _DistanceCard extends StatelessWidget {
  const _DistanceCard({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return _NumericInputCard(
      label: 'DISTANCE (KM) — OPTIONAL',
      controller: controller,
      suffix: 'km',
    );
  }
}

// ── Speed card ─────────────────────────────────────────────────────────────

class _SpeedCard extends StatelessWidget {
  const _SpeedCard({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return _NumericInputCard(
      label: 'SPEED (KM/H) — OPTIONAL',
      controller: controller,
      suffix: 'km/h',
    );
  }
}

class _NumericInputCard extends StatelessWidget {
  const _NumericInputCard({
    required this.label,
    required this.controller,
    required this.suffix,
  });
  final String label;
  final TextEditingController controller;
  final String suffix;

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
          Text(
            label,
            style: GoogleFonts.quicksand(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.muted,
                letterSpacing: 1.2),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            style: GoogleFonts.baloo2(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: AppColors.text),
            decoration: InputDecoration(
              hintText: '—',
              hintStyle: GoogleFonts.baloo2(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.border),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              suffixText: suffix,
              suffixStyle: GoogleFonts.quicksand(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Resistance card ────────────────────────────────────────────────────────

class _ResistanceCard extends StatelessWidget {
  const _ResistanceCard({required this.controller});
  final TextEditingController controller;

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
          Text(
            'RESISTANCE — OPTIONAL',
            style: GoogleFonts.quicksand(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.muted,
                letterSpacing: 1.2),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: GoogleFonts.baloo2(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: AppColors.text),
            decoration: InputDecoration(
              hintText: '—',
              hintStyle: GoogleFonts.baloo2(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.border),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              suffixText: 'level',
              suffixStyle: GoogleFonts.quicksand(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Failure toggle card ────────────────────────────────────────────────────

class _FailureCard extends StatelessWidget {
  const _FailureCard({
    required this.value,
    required this.onChanged,
    required this.subtitle,
  });
  final bool value;
  final ValueChanged<bool> onChanged;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(26),
          boxShadow: const [AppTheme.cardShadow],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Went to failure?',
                    style: GoogleFonts.baloo2(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.quicksand(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.muted),
                  ),
                ],
              ),
            ),
            _Toggle(value: value),
          ],
        ),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const _Toggle({required this.value});
  final bool value;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 54,
      height: 31,
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
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
