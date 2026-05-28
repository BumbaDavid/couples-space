import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../../shared_notes/data/note.dart';
import 'private_notes_repository.dart';

final privateNotesRepositoryProvider = Provider<PrivateNotesRepository>((ref) {
  return PrivateNotesRepository(ref.watch(firestoreProvider));
});

final privateNotesProvider = StreamProvider.family<List<Note>, String>((
  ref,
  userId,
) {
  return ref.watch(privateNotesRepositoryProvider).watchNotes(userId);
});
