import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:couples_space/features/private_notes/data/private_notes_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late PrivateNotesRepository repo;
  const userId = 'user-A';

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repo = PrivateNotesRepository(firestore);
  });

  test('createNote and watchNotes round-trip', () async {
    final id = await repo.createNote(userId: userId, title: 't', body: 'b');
    final notes = await repo.watchNotes(userId).first;
    expect(notes.length, 1);
    expect(notes.single.id, id);
    expect(notes.single.authorId, userId);
  });

  test('updateNote changes content', () async {
    final id = await repo.createNote(userId: userId, title: 't', body: 'b');
    await repo.updateNote(userId: userId, noteId: id, title: 'T', body: 'B');
    final note = (await repo.watchNotes(userId).first).single;
    expect(note.title, 'T');
    expect(note.body, 'B');
  });

  test('deleteNote removes the note', () async {
    final id = await repo.createNote(userId: userId, title: 't', body: 'b');
    await repo.deleteNote(userId: userId, noteId: id);
    expect(await repo.watchNotes(userId).first, isEmpty);
  });
}
