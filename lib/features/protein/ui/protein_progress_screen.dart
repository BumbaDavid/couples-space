import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/theme.dart';
import '../data/protein_date_utils.dart';
import '../providers/protein_providers.dart';
import 'widgets/protein_common.dart';

/// S2 — weekly view. Deliberately has no target line, no "days hit", and no
/// percentages: nothing here may read as a threshold the user fell below.
class ProteinProgressScreen extends ConsumerStatefulWidget {
  const ProteinProgressScreen({super.key});

  @override
  ConsumerState<ProteinProgressScreen> createState() =>
      _ProteinProgressScreenState();
}

class _ProteinProgressScreenState extends ConsumerState<ProteinProgressScreen> {
  late DateTime _weekStart;

  @override
  void initState() {
    super.initState();
    _weekStart = ProteinDates.weekStart(DateTime.now());
  }

  void _prevWeek() =>
      setState(() => _weekStart = _weekStart.subtract(const Duration(days: 7)));

  void _nextWeek() {
    final next = _weekStart.add(const Duration(days: 7));
    if (!ProteinDates.isCurrentWeekOrLater(next)) {
      setState(() => _weekStart = next);
    } else if (next == ProteinDates.weekStart(DateTime.now())) {
      setState(() => _weekStart = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(weeklyProteinStatsProvider(_weekStart));
    final canGoForward =
        _weekStart.isBefore(ProteinDates.weekStart(DateTime.now()));

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Eyebrow('Progress'),
                  const SizedBox(height: 2),
                  Text(
                    ProteinDates.weekLabel(_weekStart),
                    style: GoogleFonts.baloo2(
                      fontSize: 29,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
            ),
            ArrowButton(icon: Icons.chevron_left, onTap: _prevWeek),
            const SizedBox(width: 8),
            ArrowButton(
              icon: Icons.chevron_right,
              onTap: _nextWeek,
              enabled: canGoForward,
            ),
          ],
        ),
        const SizedBox(height: 20),
        if (stats.isEmpty)
          const ProteinEmptyState(
            icon: Icons.insights,
            iconSize: 42,
            title: 'Nothing logged this week',
            body: "Whenever you log something, it'll show up here.",
          )
        else ...[
          _averageCard(stats),
          const SizedBox(height: 16),
          _chartCard(stats),
          const SizedBox(height: 16),
          _weekTotalCard(stats),
        ],
      ],
    );
  }

  /// The average is total ÷ days logged, never ÷ 7, and never renders without
  /// its day count — a bare average over a self-selected denominator misleads.
  Widget _averageCard(WeeklyProteinStats stats) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${stats.average}',
                style: GoogleFonts.baloo2(
                  fontSize: 46,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              Text(
                'g',
                style: GoogleFonts.baloo2(
                  fontSize: 21,
                  fontWeight: FontWeight.w600,
                  color: AppColors.chipText,
                ),
              ),
            ],
          ),
          Text(
            'average across ${stats.daysLogged} '
            '${stats.daysLogged == 1 ? 'day' : 'days'} logged',
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.chipText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chartCard(WeeklyProteinStats stats) {
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
          const Eyebrow('Each day'),
          const SizedBox(height: 14),
          // The plot area and the day labels are deliberately two separate
          // rows. Previously the labels lived inside each bar's Column, and a
          // logged day's content (value text + full-height bar + label)
          // exceeded the fixed height. RenderFlex clamps leftover space to
          // zero on overflow, which makes MainAxisAlignment.end lay out from
          // the top instead — dropping that one label below the others. Keeping
          // labels in their own row makes alignment structural.
          SizedBox(
            height: _plotHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < stats.days.length; i++) ...[
                  Expanded(child: _bar(stats.days[i], stats.maxDayGrams)),
                  if (i != stats.days.length - 1) const SizedBox(width: 9),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var i = 0; i < stats.days.length; i++) ...[
                Expanded(
                  child: Text(
                    stats.days[i].label,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.muted,
                    ),
                  ),
                ),
                if (i != stats.days.length - 1) const SizedBox(width: 9),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// Tallest bar, plus room above it for the value label.
  static const double _maxBarHeight = 100;
  static const double _valueLineHeight = 16;
  static const double _plotHeight = _maxBarHeight + 4 + _valueLineHeight;

  /// One bar, bottom-aligned in the plot area. Day labels are drawn by the
  /// caller in a separate row, so nothing here can shift them.
  ///
  /// An unlogged day draws a flat neutral stub rather than a zero-height gap,
  /// so a day without an entry reads as "nothing recorded", not as a hole.
  Widget _bar(DayTotal day, int maxGrams) {
    final height = day.logged
        ? ((day.grams / maxGrams) * _maxBarHeight).clamp(6.0, _maxBarHeight)
        : 6.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Always rendered — an empty string on unlogged days — so every column
        // reserves the same space above its bar and the total can't exceed the
        // plot height.
        SizedBox(
          height: _valueLineHeight,
          child: Text(
            day.logged ? '${day.grams}' : '',
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.muted,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: height,
          decoration: BoxDecoration(
            color: day.logged ? AppColors.primary : AppColors.border,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(8),
              bottom: Radius.circular(5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _weekTotalCard(WeeklyProteinStats stats) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [AppTheme.cardShadow],
      ),
      child: Row(
        children: [
          const Icon(Icons.local_florist, size: 30, color: AppColors.primary),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${stats.weekTotal}g altogether',
                style: GoogleFonts.baloo2(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
              Text(
                'across the whole week',
                style: GoogleFonts.quicksand(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
