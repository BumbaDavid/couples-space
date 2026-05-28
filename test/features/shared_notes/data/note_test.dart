import 'package:couples_space/features/shared_notes/data/note.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Note round-trips through JSON', () {
    final created = DateTime.utc(2026, 1, 1, 12);
    final updated = DateTime.utc(2026, 1, 2, 9);

    final note = Note(
      id: 'note-1',
      title: 'Groceries',
      body: 'Milk, eggs',
      authorId: 'user-A',
      createdAt: created,
      updatedAt: updated,
    );

    final json = note.toJson();
    final decoded = Note.fromJson({...json, 'id': 'note-1'});

    expect(decoded, equals(note));
  });
}
