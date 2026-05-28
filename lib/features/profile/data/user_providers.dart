import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import 'user_profile.dart';
import 'user_repository.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.watch(firestoreProvider));
});

final currentUserProfileProvider = StreamProvider<UserProfile?>((ref) {
  final authUser = ref.watch(authStateChangesProvider).asData?.value;
  if (authUser == null) return Stream.value(null);
  return ref.watch(userRepositoryProvider).watchUser(authUser.uid);
});
