import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../../profile/data/user_providers.dart';
import 'note.dart';
import 'shared_notes_repository.dart';

final sharedNotesRepositoryProvider = Provider<SharedNotesRepository>((ref) {
  return SharedNotesRepository(ref.watch(firestoreProvider));
});

final sharedNotesProvider = StreamProvider<List<Note>>((ref) {
  final profile = ref.watch(currentUserProfileProvider).asData?.value;
  final coupleId = profile?.coupleId;
  if (coupleId == null) return Stream.value(<Note>[]);
  return ref.watch(sharedNotesRepositoryProvider).watchNotes(coupleId);
});
