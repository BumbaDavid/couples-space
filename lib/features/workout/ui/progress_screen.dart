import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/theme.dart';
import '../data/workout_date_utils.dart';
import '../providers/workout_providers.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  late DateTime _weekStart;

  @override
  void initState() {
    super.initState();
    _weekStart = weekStart(DateTime.now());
  }

  void _prevWeek() =>
      setState(() => _weekStart = _weekStart.subtract(const Duration(days: 7)));

  void _nextWeek() {
    final nextStart = _weekStart.add(const Duration(days: 7));
    final currentStart = weekStart(DateTime.now());
    if (nextStart.isAfter(currentStart)) return;
    setState(() => _weekStart = nextStart);
  }

  bool get _isCurrentWeek => _weekStart == weekStart(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(weeklyProgressProvider(_weekStart));

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
                    'THIS WEEK',
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.muted,
                      letterSpacing: 1.6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your Gains',
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _StatCard(
                            value: '${stats.workoutDays}',
                            label: 'WORKOUTS'),
                        const SizedBox(width: 10),
                        _StatCard(
                            value: '${stats.totalReps}',
                            label: 'TOTAL REPS'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _WeeklyChart(
                      stats: stats,
                      label: weekLabel(_weekStart),
                      onPrev: _prevWeek,
                      onNext: _isCurrentWeek ? null : _nextWeek,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stat card ──────────────────────────────────────────────────────────────

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

// ── Weekly chart ───────────────────────────────────────────────────────────

class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart({
    required this.stats,
    required this.label,
    required this.onPrev,
    required this.onNext,
  });
  final WeeklyStats stats;
  final String label;
  final VoidCallback onPrev;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final maxVol =
        stats.days.map((d) => d.volume).reduce((a, b) => a > b ? a : b);

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
          Row(
            children: [
              Expanded(
                child: Text(
                  'Weekly volume',
                  style: GoogleFonts.baloo2(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left,
                    color: AppColors.muted, size: 22),
                onPressed: onPrev,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.quicksand(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.muted),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(
                  Icons.chevron_right,
                  color:
                      onNext != null ? AppColors.muted : AppColors.border,
                  size: 22,
                ),
                onPressed: onNext,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: stats.days.map((day) {
                final frac = maxVol > 0 ? day.volume / maxVol : 0.0;
                final barH = maxVol > 0
                    ? (frac * 120).clamp(5.0, 120.0)
                    : 5.0;
                final hasVolume = day.volume > 0;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: barH,
                          decoration: BoxDecoration(
                            color: hasVolume
                                ? AppColors.primary
                                : AppColors.border,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8),
                              bottomLeft: Radius.circular(5),
                              bottomRight: Radius.circular(5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          day.label,
                          style: GoogleFonts.quicksand(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.muted),
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
