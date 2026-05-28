import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import 'couple_repository.dart';
import 'invite_code_repository.dart';

final inviteCodeRepositoryProvider = Provider<InviteCodeRepository>((ref) {
  return InviteCodeRepository(ref.watch(firestoreProvider));
});

final coupleRepositoryProvider = Provider<CoupleRepository>((ref) {
  return CoupleRepository(ref.watch(firestoreProvider));
});
