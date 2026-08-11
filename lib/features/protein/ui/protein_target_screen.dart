import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/theme.dart';
import '../../../core/widgets/app_snack.dart';
import '../data/protein_repository.dart';
import '../providers/protein_providers.dart';
import 'widgets/protein_common.dart';

/// The daily target editor. Per-user, and it lives here rather than in Profile
/// so it sits next to the ring it fills.
class ProteinTargetScreen extends ConsumerStatefulWidget {
  const ProteinTargetScreen({super.key});

  @override
  ConsumerState<ProteinTargetScreen> createState() =>
      _ProteinTargetScreenState();
}

class _ProteinTargetScreenState extends ConsumerState<ProteinTargetScreen> {
  int? _target;
  bool _saving = false;

  /// Pops first: `setTarget` lands in the local cache immediately, so the ring
  /// already reflects the new target, but its Future waits on server ack.
  void _save() {
    if (_saving) return;
    final messenger = ScaffoldMessenger.of(context);
    final int target = _target ?? ref.read(proteinTargetProvider);
    final repo = ref.read(proteinRepositoryProvider);

    setState(() => _saving = true);
    Navigator.of(context).pop();

    repo
        .setTarget(target)
        .then((_) => AppSnack.showOn(messenger, 'Target set to ${target}g'))
        .catchError((Object e) {
      AppSnack.errorOn(
        messenger,
        e is ProteinException ? e.message : 'Could not save your target.',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final int target = _target ?? ref.watch(proteinTargetProvider);

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
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(22, 6, 22, 130),
                    children: [
                      Text(
                        'Daily target',
                        style: GoogleFonts.baloo2(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Just a marker for the ring to fill toward. '
                        'Yours only — change it whenever you like.',
                        style: GoogleFonts.quicksand(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 28),
                      StepperCard(
                        value: target,
                        min: 20,
                        max: 300,
                        large: true,
                        onChanged: (v) => setState(() => _target = v),
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
                label: 'Save target',
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
