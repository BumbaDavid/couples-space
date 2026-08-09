import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/theme.dart';

/// Tile colour for the card at [index] in the catalog, cycling the shared
/// 5-colour pastel palette so a food keeps its colour on every screen.
({Color background, Color iconColor}) tileFor(int index) =>
    AppColors.tilePalette[index.abs() % AppColors.tilePalette.length];

/// Small uppercase section label, e.g. "LOG INTO", "TODAY'S LOG".
class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: GoogleFonts.quicksand(
      fontSize: 12,
      fontWeight: FontWeight.w800,
      color: AppColors.muted,
      letterSpacing: 1.6,
    ),
  );
}

/// Square chevron button used for day and week navigation.
///
/// When [enabled] is false it dims and stops responding — this is how the
/// future is made unreachable, rather than hiding the control and shifting
/// the layout.
class ArrowButton extends StatelessWidget {
  const ArrowButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.35,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.chipBg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, size: 21, color: AppColors.chipText),
        ),
      ),
    );
  }
}

/// Two-segment pill switcher used inside the Protein tab (Protein | Progress).
/// The bottom nav stays visible beneath it, so there is no "Home" segment.
class PillSwitcher extends StatelessWidget {
  const PillSwitcher({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.switcherTrack,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onSelected(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: i == selectedIndex
                        ? AppColors.surface
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: i == selectedIndex
                        ? const [AppTheme.switcherShadow]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      labels[i],
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: i == selectedIndex
                            ? AppColors.text
                            : AppColors.muted,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// −/+ stepper card. Used for card grams, entry amount, serving count, and the
/// daily target, which differ only in geometry and range.
///
/// The number itself is tappable: tapping it swaps in a numeric field with the
/// current value selected, so a value far from the current one can be typed
/// instead of stepped to. Commits on submit or when focus leaves.
class StepperCard extends StatefulWidget {
  const StepperCard({
    super.key,
    required this.value,
    required this.onChanged,
    required this.min,
    required this.max,
    this.step = 1,
    this.suffix = 'g',
    this.prefix = '',
    this.large = false,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final int step;
  final String suffix;
  final String prefix;
  final bool large;

  @override
  State<StepperCard> createState() => _StepperCardState();
}

class _StepperCardState extends State<StepperCard> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      // Commit when focus leaves, so tapping elsewhere doesn't discard input.
      if (!_focus.hasFocus && _editing) _commit();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _startEditing() {
    _controller.text = '${widget.value}';
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _controller.text.length,
    );
    setState(() => _editing = true);
    _focus.requestFocus();
  }

  void _commit() {
    final parsed = int.tryParse(_controller.text.trim());
    setState(() => _editing = false);
    // An empty or unparseable entry leaves the value untouched rather than
    // snapping to a number the user never chose.
    if (parsed == null) return;
    final clamped = parsed.clamp(widget.min, widget.max);
    if (clamped != widget.value) widget.onChanged(clamped);
  }

  @override
  Widget build(BuildContext context) {
    final button = widget.large ? 52.0 : 46.0;
    final radius = widget.large ? 18.0 : 16.0;
    final valueSize = widget.large ? 52.0 : 40.0;
    final valueStyle = GoogleFonts.baloo2(
      fontSize: valueSize,
      fontWeight: FontWeight.w700,
      color: AppColors.text,
    );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: widget.large ? 24 : 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(widget.large ? 26 : 18),
        boxShadow: const [AppTheme.cardShadow],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _StepButton(
            icon: Icons.remove,
            size: button,
            radius: radius,
            background: AppColors.chipBg,
            foreground: AppColors.chipText,
            onTap: widget.value > widget.min
                ? () => widget.onChanged(
                    (widget.value - widget.step).clamp(widget.min, widget.max),
                  )
                : null,
          ),
          Expanded(
            child: _editing
                ? _field(valueStyle)
                : GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _startEditing,
                    child: SizedBox(
                      height: valueSize * 1.2,
                      child: FittedBox(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text('${widget.prefix}${widget.value}',
                                style: valueStyle),
                            if (widget.suffix.isNotEmpty)
                              Text(
                                widget.suffix,
                                style: GoogleFonts.baloo2(
                                  fontSize: valueSize * 0.42,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.muted,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
          _StepButton(
            icon: Icons.add,
            size: button,
            radius: radius,
            background: AppColors.primary,
            foreground: AppColors.onPrimary,
            onTap: widget.value < widget.max
                ? () => widget.onChanged(
                    (widget.value + widget.step).clamp(widget.min, widget.max),
                  )
                : null,
          ),
        ],
      ),
    );
  }

  Widget _field(TextStyle valueStyle) {
    return TextField(
      controller: _controller,
      focusNode: _focus,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(3),
      ],
      textAlign: TextAlign.center,
      style: valueStyle,
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        isDense: true,
        filled: false,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        suffixText: widget.suffix.isEmpty ? null : widget.suffix,
        suffixStyle: GoogleFonts.baloo2(
          fontSize: valueStyle.fontSize! * 0.42,
          fontWeight: FontWeight.w600,
          color: AppColors.muted,
        ),
      ),
      onSubmitted: (_) => _commit(),
      onTapOutside: (_) => _focus.unfocus(),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.size,
    required this.radius,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final IconData icon;
  final double size;
  final double radius;
  final Color background;
  final Color foreground;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.4 : 1,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(radius),
          ),
          child: Icon(icon, color: foreground, size: 24),
        ),
      ),
    );
  }
}

/// Fixed bottom primary action with a fade so content scrolls under it.
class BottomAction extends StatelessWidget {
  const BottomAction({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.busy = false,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.bg.withValues(alpha: 0), AppColors.bg],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 20),
      child: GestureDetector(
        onTap: busy ? null : onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [AppTheme.buttonShadow],
          ),
          child: Center(
            child: busy
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: AppColors.onPrimary,
                      strokeWidth: 2,
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: AppColors.onPrimary, size: 22),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        label,
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

/// Calm empty state. Copy here is load-bearing: it must never imply the user
/// has fallen short, only that there is nothing here yet.
class ProteinEmptyState extends StatelessWidget {
  const ProteinEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.iconColor = AppColors.subtle,
    this.iconSize = 40,
    this.action,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color iconColor;
  final double iconSize;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 12),
      child: Column(
        children: [
          Icon(icon, size: iconSize, color: iconColor),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.baloo2(
              fontSize: 19,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.muted,
            ),
          ),
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    );
  }
}
