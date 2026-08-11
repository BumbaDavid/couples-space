import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_snack.dart';
import '../../auth/data/auth_providers.dart';
import '../../pairing/data/pairing_providers.dart';
import '../data/user_profile.dart';
import '../data/user_providers.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameController = TextEditingController();
  bool _nameDirty = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentUserProfileProvider);
    return profileAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (profile) {
        if (profile == null) {
          return const Scaffold(body: Center(child: Text('Not signed in')));
        }
        if (!_nameDirty) _nameController.text = profile.displayName;
        return Scaffold(
          appBar: AppBar(title: const Text('Profile')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Display name',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: () {
                      final name = _nameController.text.trim();
                      if (name.isEmpty) return;
                      final messenger = ScaffoldMessenger.of(context);
                      // Clear the dirty flag straight away: the write is
                      // applied locally at once, and awaiting server ack left
                      // the field looking unsaved on a slow connection.
                      setState(() => _nameDirty = false);
                      ref
                          .read(userRepositoryProvider)
                          .updateDisplayName(profile.id, name)
                          .then((_) =>
                              AppSnack.showOn(messenger, 'Display name saved'))
                          .catchError((_) {
                        if (mounted) setState(() => _nameDirty = true);
                        AppSnack.errorOn(
                          messenger,
                          "Couldn't save your display name.",
                        );
                      });
                    },
                  ),
                ),
                onChanged: (_) => setState(() => _nameDirty = true),
              ),
              const SizedBox(height: 24),
              Text('Theme', style: Theme.of(context).textTheme.titleMedium),
              RadioGroup<AppThemeMode>(
                groupValue: profile.themeMode,
                onChanged: (m) => _setMode(profile.id, m!),
                child: Column(
                  children: [
                    RadioListTile<AppThemeMode>(
                      title: const Text('System'),
                      value: AppThemeMode.system,
                    ),
                    RadioListTile<AppThemeMode>(
                      title: const Text('Light'),
                      value: AppThemeMode.light,
                    ),
                    RadioListTile<AppThemeMode>(
                      title: const Text('Dark'),
                      value: AppThemeMode.dark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _PartnerTile(profile: profile),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text('Sign out'),
                onPressed: () => ref.read(authControllerProvider).signOut(),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _setMode(String userId, AppThemeMode mode) async {
    await ref.read(userRepositoryProvider).updateThemeMode(userId, mode);
  }
}

class _PartnerTile extends ConsumerWidget {
  const _PartnerTile({required this.profile});
  final UserProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coupleId = profile.coupleId;
    if (coupleId == null) {
      return const ListTile(title: Text('Not paired'));
    }
    final coupleAsync = ref.watch(_coupleProvider(coupleId));
    return coupleAsync.when(
      loading: () => const ListTile(title: Text('Loading partner...')),
      error: (e, _) => ListTile(title: Text('Couple error: $e')),
      data: (couple) {
        if (couple == null) return const ListTile(title: Text('Not paired'));
        final partnerId = couple.memberIds.firstWhere((id) => id != profile.id);
        final partnerAsync = ref.watch(userByIdProvider(partnerId));
        return ListTile(
          leading: const Icon(Icons.favorite),
          title: const Text('Paired with'),
          subtitle:
              Text(partnerAsync.asData?.value?.displayName ?? 'Loading...'),
        );
      },
    );
  }
}

final _coupleProvider = StreamProvider.family((ref, String coupleId) {
  return ref.watch(coupleRepositoryProvider).watchCoupleById(coupleId);
});
