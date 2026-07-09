import 'package:couples_space/core/router/auth_gate.dart';
import 'package:couples_space/core/widgets/home_shell.dart';
import 'package:couples_space/features/auth/ui/auth_screen.dart';
import 'package:couples_space/features/pairing/ui/enter_code_screen.dart';
import 'package:couples_space/features/pairing/ui/generate_code_screen.dart';
import 'package:couples_space/features/pairing/ui/pairing_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = _AuthRouteListenable(ref);

  return GoRouter(
    refreshListenable: notifier,
    initialLocation: '/',
    redirect: (context, state) {
      final route = ref.read(authRouteProvider);
      final path = state.uri.path;
      switch (route) {
        case AuthRoute.loading:
          return path == '/loading' ? null : '/loading';
        case AuthRoute.signIn:
          return path == '/auth' ? null : '/auth';
        case AuthRoute.pairing:
          return path.startsWith('/pairing') ? null : '/pairing';
        case AuthRoute.home:
          return path.startsWith('/home') ? null : '/home';
      }
    },
    routes: [
      GoRoute(path: '/', builder: (_, _) => const _Loading()),
      GoRoute(path: '/loading', builder: (_, _) => const _Loading()),
      GoRoute(path: '/auth', builder: (_, _) => const AuthScreen()),
      GoRoute(
        path: '/pairing',
        builder: (_, _) => const PairingScreen(),
        routes: [
          GoRoute(
            path: 'generate',
            builder: (_, _) => const GenerateCodeScreen(),
          ),
          GoRoute(
            path: 'enter',
            builder: (_, _) => const EnterCodeScreen(),
          ),
        ],
      ),
      GoRoute(path: '/home', builder: (_, _) => const HomeShell()),
    ],
  );
});

class _AuthRouteListenable extends ChangeNotifier {
  _AuthRouteListenable(this._ref) {
    _sub = _ref.listen<AuthRoute>(
      authRouteProvider,
      (_, _) => notifyListeners(),
    );
  }

  final Ref _ref;
  late final ProviderSubscription<AuthRoute> _sub;

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }
}

class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}

