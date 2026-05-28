import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:couples_space/features/shared_notes/data/shared_notes_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late SharedNotesRepository repo;
  const coupleId = 'couple-1';

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repo = SharedNotesRepository(firestore);
  });

  test('createNote then watchNotes emits it', () async {
    final id = await repo.createNote(
      coupleId: coupleId,
      title: 'Groceries',
      body: 'Milk',
      authorId: 'user-A',
    );
    final notes = await repo.watchNotes(coupleId).first;
    expect(notes.length, 1);
    expect(notes.single.id, id);
    expect(notes.single.title, 'Groceries');
    expect(notes.single.authorId, 'user-A');
  });

  test('updateNote changes title and body', () async {
    final id = await repo.createNote(
      coupleId: coupleId,
      title: 't',
      body: 'b',
      authorId: 'user-A',
    );
    await repo.updateNote(
      coupleId: coupleId,
      noteId: id,
      title: 't2',
      body: 'b2',
    );
    final notes = await repo.watchNotes(coupleId).first;
    expect(notes.single.title, 't2');
    expect(notes.single.body, 'b2');
  });

  test('deleteNote removes the note', () async {
    final id = await repo.createNote(
      coupleId: coupleId,
      title: 't',
      body: 'b',
      authorId: 'user-A',
    );
    await repo.deleteNote(coupleId: coupleId, noteId: id);
    final notes = await repo.watchNotes(coupleId).first;
    expect(notes, isEmpty);
  });

  test('watchNotes orders by updatedAt descending', () async {
    final id1 = await repo.createNote(
      coupleId: coupleId,
      title: 'first',
      body: 'b',
      authorId: 'user-A',
    );
    await Future<void>.delayed(const Duration(milliseconds: 5));
    final id2 = await repo.createNote(
      coupleId: coupleId,
      title: 'second',
      body: 'b',
      authorId: 'user-A',
    );
    final notes = await repo.watchNotes(coupleId).first;
    expect(notes.map((n) => n.id).toList(), [id2, id1]);
  });
}
