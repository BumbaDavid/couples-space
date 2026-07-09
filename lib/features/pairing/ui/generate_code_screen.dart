import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../data/invite_code.dart';
import '../data/pairing_providers.dart';

class GenerateCodeScreen extends ConsumerStatefulWidget {
  const GenerateCodeScreen({super.key});

  @override
  ConsumerState<GenerateCodeScreen> createState() =>
      _GenerateCodeScreenState();
}

class _GenerateCodeScreenState extends ConsumerState<GenerateCodeScreen> {
  String? _code;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _generate());
  }

  Future<void> _generate() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final user = ref.read(firebaseAuthProvider).currentUser!;
      final repo = ref.read(inviteCodeRepositoryProvider);
      final code = repo.generateCode();
      final now = DateTime.now();
      await repo.create(InviteCode(
        code: code,
        createdBy: user.uid,
        createdAt: now,
        expiresAt: now.add(const Duration(hours: 24)),
      ));
      setState(() => _code = code);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your invite code')),
      body: Center(
        child: _busy
            ? const CircularProgressIndicator()
            : _error != null
                ? Text(_error!)
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Send this code to your partner. It expires in 24h.'),
                      const SizedBox(height: 16),
                      SelectableText(
                        _code!,
                        style: const TextStyle(
                          fontSize: 48,
                          fontFeatures: [FontFeature.tabularFigures()],
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton.icon(
                        icon: const Icon(Icons.share),
                        label: const Text('Share'),
                        onPressed: () => SharePlus.instance.share(
                          ShareParams(
                            text: 'Join me on Couples Notes — my invite code is $_code',
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
