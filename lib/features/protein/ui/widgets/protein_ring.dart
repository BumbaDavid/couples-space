import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/theme.dart';

/// The hero progress ring: a 196px dial that fills toward the daily target.
///
/// Deliberately unremarkable at both extremes — nothing scolds at 0g and
/// nothing celebrates above target. It just sits empty, part-full, or
/// overfilled.
class ProteinRing extends StatelessWidget {
  const ProteinRing({
    super.key,
    required this.total,
    required this.target,
    required this.loggedLabel,
  });

  final int total;
  final int target;

  /// "logged today" / "logged yesterday" / "logged that day".
  final String loggedLabel;

  @override
  Widget build(BuildContext context) {
    final safeTarget = target <= 0 ? 1 : target;
    final fill = math.min(1.0, total / safeTarget);
    final over = ((total - safeTarget) / safeTarget).clamp(0.0, 1.0);

    return SizedBox(
      width: 196,
      height: 196,
      child: CustomPaint(
        painter: _RingPainter(fill: fill, over: over),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$total',
                    style: GoogleFonts.baloo2(
                      fontSize: 52,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    'g',
                    style: GoogleFonts.baloo2(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
              Text(
                loggedLabel,
                style: GoogleFonts.quicksand(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.fill, required this.over});

  /// 0..1 of the target that has been logged.
  final double fill;

  /// 0..1 of a second lap beyond the target.
  final double over;

  static const _stroke = 17.0;
  static const _radius = 82.0;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: _radius);
    // Start at 12 o'clock rather than 3 o'clock.
    const startAngle = -math.pi / 2;

    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..color = AppColors.primarySoft;
    canvas.drawCircle(center, _radius, track);

    // A round stroke cap paints a visible dot even at zero sweep. At 0g that
    // would leave a coral mark on an "empty" ring, and on any non-overfilled
    // day the overfill dot would darken the fill's start cap. So skip drawing
    // an arc entirely when its fraction is zero.
    if (fill > 0) {
      canvas.drawArc(
        rect,
        startAngle,
        2 * math.pi * fill,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = _stroke
          ..strokeCap = StrokeCap.round
          ..color = AppColors.primary,
      );
    }

    if (over > 0) {
      canvas.drawArc(
        rect,
        startAngle,
        2 * math.pi * over,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = _stroke
          ..strokeCap = StrokeCap.round
          ..color = AppColors.overfill,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.fill != fill || old.over != over;
}
