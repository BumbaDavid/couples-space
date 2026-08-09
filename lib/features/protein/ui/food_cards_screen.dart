import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/theme.dart';
import '../data/food_card.dart';
import '../data/protein_icons.dart';
import '../providers/protein_providers.dart';
import 'food_card_form_screen.dart';
import 'widgets/protein_common.dart';

/// S3 — the shared food catalog. Both partners maintain one list.
class FoodCardsScreen extends ConsumerWidget {
  const FoodCardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(foodCardsProvider).asData?.value ?? const <FoodCard>[];

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.text),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(22, 6, 22, 120),
                    children: [
                      Text(
                        'Food cards',
                        style: GoogleFonts.baloo2(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                      Text(
                        'Shared between you both.',
                        style: GoogleFonts.quicksand(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (cards.isEmpty)
                        const ProteinEmptyState(
                          icon: Icons.restaurant,
                          iconColor: AppColors.primary,
                          iconSize: 42,
                          title: 'No cards yet',
                          body: 'Start with something you eat most days.',
                        )
                      else
                        for (var i = 0; i < cards.length; i++)
                          _row(context, cards[i], i),
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
                label: 'New card',
                icon: Icons.add,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const FoodCardFormScreen(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, FoodCard card, int index) {
    final tile = tileFor(index);
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => FoodCardFormScreen(card: card, index: index),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [AppTheme.cardShadow],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: tile.background,
                shape: BoxShape.circle,
              ),
              child: Icon(
                ProteinIcons.forName(card.icon),
                color: tile.iconColor,
                size: 25,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.baloo2(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                  Text(
                    '${card.proteinGrams}g protein',
                    style: GoogleFonts.quicksand(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.edit, size: 22, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}
