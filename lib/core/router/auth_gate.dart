import 'package:couples_space/core/firebase/firebase_providers.dart';
import 'package:couples_space/features/pairing/data/pairing_providers.dart';
import 'package:couples_space/features/profile/data/user_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthRoute { loading, signIn, pairing, home }

final authRouteProvider = Provider<AuthRoute>((ref) {
  final authAsync = ref.watch(authStateChangesProvider);
  final authUser = authAsync.asData?.value;
  if (authAsync.isLoading) return AuthRoute.loading;
  if (authUser == null) return AuthRoute.signIn;

  final profileAsync = ref.watch(currentUserProfileProvider);
  final profile = profileAsync.asData?.value;
  if (profileAsync.isLoading) return AuthRoute.loading;
  if (profile == null) return AuthRoute.loading;

  if (profile.coupleId != null) return AuthRoute.home;

  final backfill = ref.watch(coupleBackfillProvider);
  return backfill.maybeWhen(
    data: (foundCoupleId) =>
        foundCoupleId == null ? AuthRoute.pairing : AuthRoute.home,
    orElse: () => AuthRoute.loading,
  );
});

final coupleBackfillProvider = StreamProvider<String?>((ref) async* {
  final authUser = ref.watch(authStateChangesProvider).asData?.value;
  if (authUser == null) { yield null; return; }
  final couples = ref.watch(coupleRepositoryProvider);
  final users = ref.watch(userRepositoryProvider);
  await for (final couple in couples.watchCoupleForUser(authUser.uid)) {
    if (couple == null) { yield null; continue; }
    await users.setCoupleId(authUser.uid, couple.id);
    yield couple.id;
  }
});
