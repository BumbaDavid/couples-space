import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PairingScreen extends StatelessWidget {
  const PairingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pair with your partner")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton(
              onPressed: () => context.go("/pairing/generate"),
              child: const Text("Show invite code"),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => context.push('pairing/enter'),
              child: const Text("Enter partner's code"),
            ),
          ],
        ),
      ),
    );
  }
}
