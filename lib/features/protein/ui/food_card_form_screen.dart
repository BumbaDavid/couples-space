import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_snack.dart';
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

  /// Pops first — the card write reaches the local cache immediately, so the
  /// catalog already shows it; the Future only waits on server ack.
  void _save() {
    if (_saving) return;
    final coupleId = ref.read(proteinCoupleIdProvider);
    if (coupleId == null) {
      AppSnack.error(context, 'Pair with your partner first to share food cards.');
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    // Read the field before popping — the controller is disposed on the way out.
    final name = _name.text.trim().isEmpty ? 'New food' : _name.text.trim();
    final grams = _grams;
    final icon = _icon;
    final editing = _isEditing;
    final existing = widget.card;
    final repo = ref.read(proteinRepositoryProvider);

    setState(() => _saving = true);
    Navigator.of(context).pop();

    final write = editing
        ? repo.updateFood(
            coupleId,
            existing!.copyWith(name: name, proteinGrams: grams, icon: icon),
          )
        : repo.createFood(
            coupleId,
            name: name,
            proteinGrams: grams,
            icon: icon,
          );

    write
        .then((_) => AppSnack.showOn(
              messenger,
              editing ? '$name updated' : '$name added',
            ))
        .catchError((Object e) {
      AppSnack.errorOn(
        messenger,
        e is ProteinException ? e.message : 'Could not save that card.',
      );
    });
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
    if (confirmed != true || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final name = widget.card!.name;
    final id = widget.card!.id;
    final repo = ref.read(proteinRepositoryProvider);

    Navigator.of(context).pop();

    repo
        .deleteFood(coupleId, id)
        .then((_) => AppSnack.showOn(messenger, '$name removed'))
        .catchError((Object e) {
      AppSnack.errorOn(
        messenger,
        e is ProteinException ? e.message : 'Could not remove that card.',
      );
    });
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
