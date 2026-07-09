import 'package:couples_space/core/router/router.dart';
import 'package:couples_space/core/theme/theme.dart';
import 'package:couples_space/features/profile/data/user_profile.dart';
import 'package:couples_space/features/profile/data/user_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CouplesNotesApp extends ConsumerWidget {
  const CouplesNotesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentUserProfileProvider).asData?.value;
    final mode = AppTheme.toThemeMode(
      profile?.themeMode ?? AppThemeMode.system,
    );

    return MaterialApp.router(
      title: 'Couples Notes',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: mode,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
