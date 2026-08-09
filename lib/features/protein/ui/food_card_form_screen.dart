import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/theme.dart';
import '../data/food_card.dart';
import '../data/protein_icons.dart';
import '../data/protein_repository.dart';
import '../providers/protein_providers.dart';
import 'widgets/protein_common.dart';

/// S3b — add or edit a food card. Editing never rewrites history: entries
/// snapshot their name and grams at log time.
class FoodCardFormScreen extends ConsumerStatefulWidget {
  const FoodCardFormScreen({super.key, this.card, this.index = 0});

  final FoodCard? card;
  final int index;

  @override
  ConsumerState<FoodCardFormScreen> createState() => _FoodCardFormScreenState();
}

class _FoodCardFormScreenState extends ConsumerState<FoodCardFormScreen> {
  late final TextEditingController _name;
  late int _grams;
  late String _icon;
  bool _saving = false;

  bool get _isEditing => widget.card != null;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.card?.name ?? '');
    _grams = widget.card?.proteinGrams ?? 20;
    _icon = widget.card?.icon ?? ProteinIcons.names.first;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    final coupleId = ref.read(proteinCoupleIdProvider);
    if (coupleId == null) {
      _showMessage('Pair with your partner first to share food cards.');
      return;
    }
    setState(() => _saving = true);
    final repo = ref.read(proteinRepositoryProvider);
    try {
      if (_isEditing) {
        await repo.updateFood(
          coupleId,
          widget.card!.copyWith(
            name: _name.text,
            proteinGrams: _grams,
            icon: _icon,
          ),
        );
      } else {
        await repo.createFood(
          coupleId,
          name: _name.text,
          proteinGrams: _grams,
          icon: _icon,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } on ProteinException catch (e) {
      _showMessage(e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final coupleId = ref.read(proteinCoupleIdProvider);
    if (coupleId == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(26),
        ),
        title: Text(
          'Remove this card?',
          style: GoogleFonts.baloo2(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        content: Text(
          'Anything you already logged with it stays exactly as it is.',
          style: GoogleFonts.quicksand(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.muted,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Keep it',
              style: GoogleFonts.quicksand(
                fontWeight: FontWeight.w800,
                color: AppColors.muted,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Remove',
              style: GoogleFonts.quicksand(
                fontWeight: FontWeight.w800,
                color: AppColors.chipText,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref
          .read(proteinRepositoryProvider)
          .deleteFood(coupleId, widget.card!.id);
      if (mounted) Navigator.of(context).pop();
    } on ProteinException catch (e) {
      _showMessage(e.message);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.quicksand(fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tile = tileFor(widget.index);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.text),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    // Deliberately not red. Removing a card is a correction,
                    // not a failure.
                    if (_isEditing)
                      TextButton.icon(
                        onPressed: _delete,
                        icon: const Icon(
                          Icons.delete,
                          size: 19,
                          color: AppColors.chipText,
                        ),
                        label: Text(
                          'Delete',
                          style: GoogleFonts.quicksand(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.chipText,
                          ),
                        ),
                      ),
                  ],
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(22, 6, 22, 130),
                    children: [
                      Text(
                        _isEditing ? 'Edit card' : 'New food card',
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
                            ProteinIcons.forName(_icon),
                            color: tile.iconColor,
                            size: 46,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      const Eyebrow('Name'),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: const [AppTheme.cardShadow],
                        ),
                        child: TextField(
                          controller: _name,
                          style: GoogleFonts.baloo2(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: AppColors.text,
                          ),
                          decoration: InputDecoration(
                            hintText: 'e.g. Whey shake',
                            hintStyle: GoogleFonts.baloo2(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: AppColors.muted,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Eyebrow('Protein'),
                      const SizedBox(height: 10),
                      StepperCard(
                        value: _grams,
                        min: 1,
                        max: 120,
                        onChanged: (v) => setState(() => _grams = v),
                      ),
                      const SizedBox(height: 24),
                      const Eyebrow('Icon'),
                      const SizedBox(height: 10),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: ProteinIcons.names.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          crossAxisSpacing: 9,
                          mainAxisSpacing: 9,
                        ),
                        itemBuilder: (context, i) {
                          final name = ProteinIcons.names[i];
                          final selected = name == _icon;
                          return GestureDetector(
                            onTap: () => setState(() => _icon = name),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.chipBg,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: selected
                                    ? const [AppTheme.buttonShadow]
                                    : null,
                              ),
                              child: Icon(
                                ProteinIcons.forName(name),
                                size: 24,
                                color: selected
                                    ? AppColors.onPrimary
                                    : AppColors.chipText,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BottomAction(
                label: _isEditing ? 'Save changes' : 'Create card',
                busy: _saving,
                onTap: _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
