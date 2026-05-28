import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:couples_space/core/firebase/converters.dart';

import 'note.dart';

class SharedNotesRepository {
  SharedNotesRepository(this._firestore, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final FirebaseFirestore _firestore;
  final DateTime Function() _now;
  static const _timeFields = ['createdAt', 'updatedAt'];

  CollectionReference<Map<String, dynamic>> _col(String coupleId) =>
      _firestore.collection('couples').doc(coupleId).collection('sharedNotes');

  Stream<List<Note>> watchNotes(String coupleId) {
    return _col(coupleId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(_decode).toList());
  }

  Future<String> createNote({
    required String coupleId,
    required String title,
    required String body,
    required String authorId,
  }) async {
    final now = _now();
    final doc = _col(coupleId).doc();
    final data = dateTimesToTimestamps({
      'title': title,
      'body': body,
      'authorId': authorId,
      'createdAt': now.toUtc().toIso8601String(),
      'updatedAt': now.toUtc().toIso8601String(),
    }, _timeFields);

    await doc.set(data);
    return doc.id;
  }

  Future<void> updateNote({
    required String coupleId,
    required String noteId,
    required String title,
    required String body,
  }) {
    return _col(coupleId).doc(noteId).update({
      'title': title,
      'body': body,
      'updatedAt': Timestamp.fromDate(_now()),
    });
  }

  Future<void> deleteNote({required String coupleId, required String noteId}) {
    return _col(coupleId).doc(noteId).delete();
  }

  Note _decode(QueryDocumentSnapshot<Map<String, dynamic>> snap) {
    final converted = timestampsToDateTimes(snap.data(), _timeFields);
    return Note.fromJson({...converted, 'id': snap.id});
  }
}
